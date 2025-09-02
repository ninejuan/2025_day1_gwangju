locals {
  amazon_cloudwatch_observability_config = file("${path.module}/configs/container_insights.json")
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]

  tags = {
    Name = "${var.project}-eks-cluster"
  }
}

# OIDC Identity Provider for EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.project}-eks-oidc-provider"
  }
}



# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachments for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# KMS Key for EKS
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project}-eks-kms-key"
  }
}

# Security Group for EKS Cluster and Node Groups
resource "aws_security_group" "eks" {
  name_prefix = "${var.project}-eks-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
    description = "Allow EKS cluster and nodes to communicate"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-eks-sg"
  }
}

# IAM Role for Node Groups
resource "aws_iam_role" "eks_node_group" {
  name = "${var.project}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachments for Node Groups
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Application Node Group
resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project}-eks-app-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.app_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  labels = {
    "skills" = "app"
  }

  tags = {
    Name = "${var.project}-eks-app-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Node Group이 완전히 생성될 때까지 대기
      aws eks wait nodegroup-active --cluster-name ${aws_eks_cluster.main.name} --nodegroup-name ${var.project}-eks-app-nodegroup
      
      # Auto Scaling Group의 인스턴스들에 태그 설정
      ASG_NAME=$(aws eks describe-nodegroup --cluster-name ${aws_eks_cluster.main.name} --nodegroup-name ${var.project}-eks-app-nodegroup --query 'nodegroup.resources.autoScalingGroups[0].name' --output text)
      
      if [ ! -z "$ASG_NAME" ] && [ "$ASG_NAME" != "None" ]; then
        INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME --query 'AutoScalingGroups[0].Instances[].InstanceId' --output text)
        
        for INSTANCE_ID in $INSTANCE_IDS; do
          aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=${var.project}-eks-app-node
        done
      fi
    EOT
  }
}

# Addon Node Group
resource "aws_eks_node_group" "addon" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project}-eks-addon-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.addon_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  labels = {
    "skills" = "addon"
  }

  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "${var.project}-eks-addon-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Node Group이 완전히 생성될 때까지 대기
      aws eks wait nodegroup-active --cluster-name ${aws_eks_cluster.main.name} --nodegroup-name ${var.project}-eks-addon-nodegroup
      
      # Auto Scaling Group의 인스턴스들에 태그 설정
      ASG_NAME=$(aws eks describe-nodegroup --cluster-name ${aws_eks_cluster.main.name} --nodegroup-name ${var.project}-eks-addon-nodegroup --query 'nodegroup.resources.autoScalingGroups[0].name' --output text)
      
      if [ ! -z "$ASG_NAME" ] && [ "$ASG_NAME" != "None" ]; then
        INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME --query 'AutoScalingGroups[0].Instances[].InstanceId' --output text)
        
        for INSTANCE_ID in $INSTANCE_IDS; do
          aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=${var.project}-eks-addon-node
        done
      fi
    EOT
  }
}

resource "aws_eks_addon" "container_insights" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "amazon-cloudwatch-observability"

  configuration_values = local.amazon_cloudwatch_observability_config

  depends_on = [
    aws_eks_node_group.app,
    aws_eks_node_group.addon
  ]

  tags = {
    Name = "${var.project}-container-insights"
  }
}