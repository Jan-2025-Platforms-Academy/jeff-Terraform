
# Create a VPC
resource "aws_vpc" "jeff_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.project_name}-${var.environment}-jeff-vpc"
  }
}

# add data source get all availability zones in region
data "aws_availability_zones" "available" { state = "available" }

# management subnet
resource "aws_subnet" "jeff_Tf_mgmt_subnet" {
  vpc_id                  = aws_vpc.jeff_vpc.id
  cidr_block              = var.management_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1a]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-lgtm-AZ_1"
  }
}

# create subnet in az1 public
resource "aws_subnet" "jeff_load_balancer_subnet1" {
  vpc_id                  = aws_vpc.jeff_vpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1a]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-LB_AZ_1"
  }
}

# create subnet in az2 public
resource "aws_subnet" "jeff_load_balancer_subnet2" {
  vpc_id                  = aws_vpc.jeff_vpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1b]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-LB_AZ_2"
  }
}

# create subnet in az3 private
resource "aws_subnet" "jeff_ec2_subnet3" {
  vpc_id            = aws_vpc.jeff_vpc.id
  cidr_block        = var.subnet3_cidr
  availability_zone = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1a]
  tags = {
    Name = "${var.project_name}-${var.environment}-private_ec2AZ_1"
  }
}

# create subnet in az4 private
resource "aws_subnet" "jeff_ec2_subnet4" {
  vpc_id            = aws_vpc.jeff_vpc.id
  cidr_block        = var.subnet4_cidr
  availability_zone = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1b]
  tags = {
    Name = "${var.project_name}-${var.environment}-private_ec2AZ_2"
  }
}


# create db  subnet in az5 private
resource "aws_subnet" "jeff_DB_subnet5" {
  vpc_id            = aws_vpc.jeff_vpc.id
  cidr_block        = var.subnet5_cidr
  availability_zone = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1a]
  tags = {
    Name = "${var.project_name}-${var.environment}-private_DB_AZ_1"
  }
}

# create db subnet in az6 private
resource "aws_subnet" "jeff_DB_subnet6" {
  vpc_id            = aws_vpc.jeff_vpc.id
  cidr_block        = var.subnet6_cidr
  availability_zone = data.aws_availability_zones.available.names[var.subnet_cidr.eu-west-1b]
  tags = {
    Name = "${var.project_name}-${var.environment}-private_DB_AZ_2"
  }
}


#add internet gateway
resource "aws_internet_gateway" "jeff_Tf_IGW" {
  vpc_id = aws_vpc.jeff_vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-jeff_IGW"
  }
}


# route to internet gateway
resource "aws_route_table" "jeff_Tf_RT" {
  vpc_id = aws_vpc.jeff_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jeff_Tf_IGW.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public_RT"
  }
}


#create route from management subnet to internet gateway
resource "aws_route_table_association" "jeff_Tf_RT_association_mgmt_subnet" {
  subnet_id      = aws_subnet.jeff_Tf_mgmt_subnet.id
  route_table_id = aws_route_table.jeff_Tf_RT.id
}

# create route table association for subnets
resource "aws_route_table_association" "jeff_Tf_RT_association_subnet1" {
  subnet_id      = aws_subnet.jeff_load_balancer_subnet1.id
  route_table_id = aws_route_table.jeff_Tf_RT.id
}
# create route table for public subnets 2
resource "aws_route_table_association" "jeff_Tf_RT_association_subnet2" {
  subnet_id      = aws_subnet.jeff_load_balancer_subnet2.id
  route_table_id = aws_route_table.jeff_Tf_RT.id
}