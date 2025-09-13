terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  project            = var.project
  vpc_cidr_blocks    = var.vpc_cidr_blocks
  subnet_cidr_blocks = var.subnet_cidr_blocks
  availability_zones = var.availability_zones
}

module "transit_gateway" {
  source = "./modules/transit_gateway"

  project        = var.project
  hub_vpc_id     = module.vpc.hub_vpc_id
  app_vpc_id     = module.vpc.app_vpc_id
  hub_subnet_ids = module.vpc.hub_private_subnet_ids
  app_subnet_ids = module.vpc.app_private_subnet_ids
  depends_on     = [module.vpc]
}

module "vpc_routing" {
  source = "./modules/vpc_routing"

  transit_gateway_id           = module.transit_gateway.transit_gateway_id
  hub_private_a_route_table_id = module.vpc.hub_private_a_route_table_id
  hub_private_b_route_table_id = module.vpc.hub_private_b_route_table_id
  app_private_a_route_table_id = module.vpc.app_private_a_route_table_id
  app_private_b_route_table_id = module.vpc.app_private_b_route_table_id
  depends_on                   = [module.vpc, module.transit_gateway]
}

module "network_firewall" {
  source = "./modules/network_firewall"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.hub_vpc_id
  firewall_subnet_id = module.vpc.hub_firewall_subnet_id
  availability_zones = var.availability_zones
}

module "bastion" {
  source = "./modules/bastion"

  project    = var.project
  vpc_id     = module.vpc.hub_vpc_id
  subnet_id  = module.vpc.hub_public_subnet_a_id
  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"

  project                    = var.project
  vpc_id                     = module.vpc.app_vpc_id
  data_subnet_ids            = module.vpc.app_data_subnet_ids
  private_subnet_ids         = module.vpc.app_private_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  depends_on                 = [module.vpc, module.eks]
}

module "ecr" {
  source = "./modules/ecr"

  project     = var.project
  environment = var.environment
  repositories = {
    red   = {}
    green = {}
  }
}

module "eks" {
  source = "./modules/eks"

  project            = var.project
  vpc_id             = module.vpc.app_vpc_id
  private_subnet_ids = module.vpc.app_private_subnet_ids
  depends_on         = [module.vpc, module.ecr]
}

module "load_balancers" {
  source = "./modules/load_balancers"

  project                = var.project
  app_private_subnet_ids = module.vpc.app_private_subnet_ids
  app_public_subnet_ids  = module.vpc.app_public_subnet_ids
  hub_public_subnet_ids  = module.vpc.hub_public_subnet_ids
  app_vpc_id             = module.vpc.app_vpc_id
  hub_vpc_id             = module.vpc.hub_vpc_id
  depends_on             = [module.vpc]
}

module "app_secrets" {
  source = "./modules/secrets"

  project     = var.project
  environment = var.environment
  secret_name = "${var.project}-eks-cluster-catalog-secret"
  secrets = {
    DB_USER     = "admin"
    DB_PASSWORD = "Skills53#$%"
    DB_URL      = "${module.rds.db_endpoint}"
  }
  depends_on = [module.rds]
}

module "github_token" {
  source = "./modules/secrets"

  project     = var.project
  environment = var.environment
  secret_name = "${var.project}-github-token"
  secrets = {
    token = var.github_token
  }
}

module "iam" {
  source = "./modules/iam"

  project      = var.project
  account_id   = data.aws_caller_identity.current.account_id
  oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  secret_arns  = [
    module.app_secrets.secret_arn,
    module.github_token.secret_arn
  ]
  kms_key_arns = [
    module.app_secrets.kms_key_arn,
    module.github_token.kms_key_arn
  ]

  depends_on = [module.eks]
}

data "aws_caller_identity" "current" {}

module "codebuild_red" {
  source = "./modules/codebuild"

  project              = var.project
  app_name             = "red"
  ecr_repository_url   = module.ecr.repository_urls["red"]
  ecr_repository_arn   = module.ecr.repository_arns["red"]
  github_token_arn     = module.github_token.secret_arn
  artifacts_bucket_arn = module.s3.red_artifacts_bucket_arn
  github_username      = var.github_username
  github_token_kms_key_arn = module.github_token.kms_key_arn
  depends_on           = [module.ecr, module.github_token, module.s3]
}

module "codebuild_green" {
  source = "./modules/codebuild"

  project              = var.project
  app_name             = "green"
  ecr_repository_url   = module.ecr.repository_urls["green"]
  ecr_repository_arn   = module.ecr.repository_arns["green"]
  github_token_arn     = module.github_token.secret_arn
  artifacts_bucket_arn = module.s3.green_artifacts_bucket_arn
  github_username      = var.github_username
  github_token_kms_key_arn = module.github_token.kms_key_arn
  depends_on           = [module.ecr, module.github_token, module.s3]
}

module "codepipeline_red" {
  source = "./modules/codepipeline"

  project                = var.project
  app_name               = "red"
  artifact_bucket_arn    = module.s3.red_artifacts_bucket_arn
  artifact_bucket_name   = module.s3.red_artifacts_bucket_name
  repository_id          = var.repository_id
  source_branch          = "app-red"
  codebuild_project_name = module.codebuild_red.codebuild_project_name
  github_token           = var.github_token
  github_username        = var.github_username
  depends_on             = [module.codebuild_red, module.s3]
}

module "codepipeline_green" {
  source = "./modules/codepipeline"

  project                = var.project
  app_name               = "green"
  artifact_bucket_arn    = module.s3.green_artifacts_bucket_arn
  artifact_bucket_name   = module.s3.green_artifacts_bucket_name
  repository_id          = var.repository_id
  source_branch          = "app-green"
  codebuild_project_name = module.codebuild_green.codebuild_project_name
  github_token           = var.github_token
  github_username        = var.github_username
  depends_on             = [module.codebuild_green, module.s3]
}

module "s3" {
  source = "./modules/s3"

  project = var.project
}
