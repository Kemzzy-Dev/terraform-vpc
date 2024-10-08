resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_list)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.public_subnet_list, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

# private subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_list)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.private_subnet_list, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

# Internet gateway 
resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-vpc-igw"
  }
}

# Route table
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }

  tags = {
    Name = "public_subnet_rt"
  }
}

# Public route table association
resource "aws_route_table_association" "main_vpc_rt_association" {
  count          = length(var.public_subnet_list)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet_rt.id
}

# Nat gateway
resource "aws_nat_gateway" "main_vpc_nat" {
  count         = length(var.public_subnet_list)
  allocation_id = aws_eip.main_vpc_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "main-vpc-nat${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.main_vpc_igw]
}

# Elastic IP
resource "aws_eip" "main_vpc_eip" {
  count  = length(var.public_subnet_list)
  domain = "vpc"

  tags = {
    Name = "main-vpc-eip${count.index + 1}"
  }
}