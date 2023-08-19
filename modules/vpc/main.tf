# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.VPC_CIDR
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink   = false

  enable_classiclink_dns_support = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.PROJECT_NAME}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {
  state = "available"
}

# create public subnet pub-sub-1-a
resource "aws_subnet" "pub-sub-1-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PUB_SUB_1_A_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "pub-sub-1-a"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

# create public subnet pub-sub-2-b
resource "aws_subnet" "pub-sub-2-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PUB_SUB_2_B_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "pub-sub-2-b"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# associate public subnet pub-sub-1-a to "public route table"
resource "aws_route_table_association" "pub-sub-1-a_route_table_association" {
  subnet_id      = aws_subnet.pub-sub-1-a.id
  route_table_id = aws_route_table.public_route_table.id
}

# associate public subnet az2 to "public route table"
resource "aws_route_table_association" "pub-sub-2-b_route_table_association" {
  subnet_id      = aws_subnet.pub-sub-2-b.id
  route_table_id = aws_route_table.public_route_table.id
}

# create private app subnet pri-sub-3-a
resource "aws_subnet" "pri-sub-3-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PRI_SUB_3_A_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "pri-sub-3-a"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

# create private app pri-sub-4-b
resource "aws_subnet" "pri-sub-4-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PRI_SUB_4_B_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "pri-sub-4-b"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

# This eip will be used for the nat-gateway in the public subnet pub-sub-1-a
resource "aws_eip" "EIP-NAT-GW-A" {
  vpc = true

  tags = {
    Name = "NAT-GW-EIP-A"
  }
}

# This eip will be used for the nat-gateway in the public subnet pub-sub-2-b
resource "aws_eip" "EIP-NAT-GW-B" {
  vpc = true

  tags = {
    Name = "NAT-GW-EIP-B"
  }
}


# create nat gateway in public subnet pub-sub-1-a
resource "aws_nat_gateway" "NAT-GW-A" {
  allocation_id = aws_eip.EIP-NAT-GW-A.id
  subnet_id     = aws_subnet.pub-sub-1-a.id

  tags = {
    Name = "NAT-GW-A"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.internet_gateway]
}

# create nat gateway in public subnet pub-sub-2-b
resource "aws_nat_gateway" "NAT-GW-B" {
  allocation_id = aws_eip.EIP-NAT-GW-B.id
  subnet_id     = aws_subnet.pub-sub-2-b.id

  tags = {
    Name = "NAT-GW-B"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.internet_gateway]
}

# create private route table Pri-RT-A and add route through NAT-GW-A
resource "aws_route_table" "Pri-RT-A" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW-A.id
  }

  tags = {
    Name = "Pri-RT-A"
  }
}

# associate private subnet pri-sub-3-a with private route table Pri-RT-A
resource "aws_route_table_association" "pri-sub-3-a-with-Pri-RT-A" {
  subnet_id      = aws_subnet.pri-sub-3-a.id
  route_table_id = aws_route_table.Pri-RT-A.id
}

# create private route table Pri-RT-B and add route through NAT-GW-B
resource "aws_route_table" "Pri-RT-B" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW-B.id
  }

  tags = {
    Name = "Pri-RT-B"
  }
}

# associate private subnet pri-sub-4-b with private route Pri-RT-B
resource "aws_route_table_association" "pri-sub-5-a-with-Pri-RT-B" {
  subnet_id      = aws_subnet.pri-sub-4-b.id
  route_table_id = aws_route_table.Pri-RT-B.id
}