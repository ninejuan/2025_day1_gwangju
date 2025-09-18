resource "aws_vpc" "hub" {
  cidr_block           = var.vpc_cidr_blocks.hub
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-hub-vpc"
  }
}

resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_blocks.app
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-app-vpc"
  }
}

resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "${var.project}-hub-igw"
  }
}

resource "aws_eip" "app_nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-app-nat-eip"
  }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.app_nat.id
  subnet_id     = aws_subnet.app_public_a.id

  tags = {
    Name = "${var.project}-app-nat"
  }

  depends_on = [aws_internet_gateway.app]
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.project}-app-igw"
  }
}

resource "aws_subnet" "hub_public_a" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = var.subnet_cidr_blocks.hub.public_a
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-hub-public-subnet-a"
    Type = "Public"
  }
}

resource "aws_subnet" "hub_public_b" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = var.subnet_cidr_blocks.hub.public_b
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-hub-public-subnet-b"
    Type = "Public"
  }
}

resource "aws_subnet" "hub_private_a" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.subnet_cidr_blocks.hub.private_a
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-hub-private-subnet-a"
    Type = "Private"
  }
}

resource "aws_subnet" "hub_private_b" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.subnet_cidr_blocks.hub.private_b
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project}-hub-private-subnet-b"
    Type = "Private"
  }
}

resource "aws_subnet" "hub_firewall" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.subnet_cidr_blocks.hub.firewall
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-hub-firewall-subnet"
    Type = "Firewall"
  }
}

resource "aws_subnet" "app_private_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.private_a
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-app-private-subnet-a"
    Type = "Private"
  }
}

resource "aws_subnet" "app_private_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.private_b
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project}-app-private-subnet-b"
    Type = "Private"
  }
}

resource "aws_subnet" "app_public_a" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "192.168.4.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-app-public-subnet-a"
    Type = "Public"
  }
}

resource "aws_subnet" "app_public_b" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "192.168.5.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-app-public-subnet-b"
    Type = "Public"
  }
}

resource "aws_subnet" "app_data_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.data_a
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-app-data-subnet-a"
    Type = "Data"
  }
}

resource "aws_subnet" "app_data_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.data_b
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project}-app-data-subnet-b"
    Type = "Data"
  }
}

resource "aws_subnet" "app_firewall_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.firewall_a
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-app-firewall-subnet-a"
    Type = "Firewall"
  }
}

resource "aws_subnet" "app_firewall_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.subnet_cidr_blocks.app.firewall_b
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project}-app-firewall-subnet-b"
    Type = "Firewall"
  }
}

resource "aws_route_table" "hub_public" {
  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub.id
  }

  tags = {
    Name = "${var.project}-hub-public-rtb"
  }
}

resource "aws_route_table" "hub_private_a" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "${var.project}-hub-private-rtb-a"
  }
}

resource "aws_route_table" "hub_private_b" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "${var.project}-hub-private-rtb-b"
  }
}

resource "aws_route_table" "hub_firewall" {
  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hub.id
  }

  tags = {
    Name = "${var.project}-hub-firewall-rtb"
  }
}

resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "${var.project}-app-public-rtb"
  }
}

resource "aws_route_table" "app_private_a" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app.id
  }

  tags = {
    Name = "${var.project}-app-private-rtb-a"
  }
}

resource "aws_route_table" "app_private_b" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app.id
  }

  tags = {
    Name = "${var.project}-app-private-rtb-b"
  }
}

resource "aws_route_table" "app_data_a" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.project}-app-data-rtb-a"
  }
}

resource "aws_route_table" "app_data_b" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.project}-app-data-rtb-b"
  }
}

resource "aws_route_table_association" "hub_public_a" {
  subnet_id      = aws_subnet.hub_public_a.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_public_b" {
  subnet_id      = aws_subnet.hub_public_b.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_private_a" {
  subnet_id      = aws_subnet.hub_private_a.id
  route_table_id = aws_route_table.hub_private_a.id
}

resource "aws_route_table_association" "hub_private_b" {
  subnet_id      = aws_subnet.hub_private_b.id
  route_table_id = aws_route_table.hub_private_b.id
}

resource "aws_route_table_association" "app_private_a" {
  subnet_id      = aws_subnet.app_private_a.id
  route_table_id = aws_route_table.app_private_a.id
}

resource "aws_route_table_association" "app_private_b" {
  subnet_id      = aws_subnet.app_private_b.id
  route_table_id = aws_route_table.app_private_b.id
}

resource "aws_route_table_association" "app_data_a" {
  subnet_id      = aws_subnet.app_data_a.id
  route_table_id = aws_route_table.app_data_a.id
}

resource "aws_route_table_association" "app_data_b" {
  subnet_id      = aws_subnet.app_data_b.id
  route_table_id = aws_route_table.app_data_b.id
}

resource "aws_route_table_association" "app_public_a" {
  subnet_id      = aws_subnet.app_public_a.id
  route_table_id = aws_route_table.app_public.id
}

resource "aws_route_table_association" "app_public_b" {
  subnet_id      = aws_subnet.app_public_b.id
  route_table_id = aws_route_table.app_public.id
} 
data "aws_region" "current" {} 

resource "aws_eip" "hub_nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-hub-nat-eip"
  }
}

resource "aws_nat_gateway" "hub" {
  allocation_id = aws_eip.hub_nat.id
  subnet_id     = aws_subnet.hub_public_a.id

  tags = {
    Name = "${var.project}-hub-ngw"
  }

  depends_on = [aws_internet_gateway.hub]
} 

resource "aws_route_table_association" "hub_firewall" {
  subnet_id      = aws_subnet.hub_firewall.id
  route_table_id = aws_route_table.hub_firewall.id
} 