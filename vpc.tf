resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_list[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "public_subnet"
  }
}

# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_list[1]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "private_subnet"
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
resource "aws_route_table" "main_vpc_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }
  tags = {
    Name = "main-vpc-rt"
  }
}

# Route table association
resource "aws_route_table_association" "main_vpc_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main_vpc_rt.id
}