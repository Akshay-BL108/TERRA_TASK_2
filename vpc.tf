data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true 
   tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {

  cidr_block              = "${var.public_cidrs}" 
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${data.aws_availability_zones.available.names}"
  map_public_ip_on_launch = true
    tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "privet_subnet" {
  count = 2
  cidr_block              = "${var.private_cidrs[count.index]}" 
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
   tags = {
    Name = "privet_subnet-${count.index+1}"
  }
}

## internet gateway
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.vpc.id
}

## Route Table  Association
resource "aws_route_table_association" "public_route_association" {
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table_association" "privet_route_association" {
  count = 2
  route_table_id = aws_route_table.privet_route.id
  subnet_id      = aws_subnet.privet_subnet[count.index].id
}
 
 ## ROUTING   
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"    ## PUBLIC 
    gateway_id = aws_internet_gateway.Igw.id
  }
  tags = {
   Name = "public_route"
 }
}

resource "aws_route_table" "privet_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.my-test-nat-gateway.id  ## PRIVET
  }
   tags = {
   Name = "privet_route"
 }
}

## elastick ip
resource "aws_eip" "my-test-eip" {
  vpc = true
}

## nat getway for the privet subnet in PUBLIC SUBNET
resource "aws_nat_gateway" "my-test-nat-gateway" {
  allocation_id = "${aws_eip.my-test-eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
}