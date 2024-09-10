resource "aws_vpc" "dev-vpc" {
  cidr_block       = var.vpc.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc.tags["name"]
    env = var.vpc.tags["env"]
  }
}

resource "aws_internet_gateway" "dev-vpc-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = var.internet-gw-tag
  }
}

resource "aws_subnet" "public" {
  count = length(var.public-subnet.cidr_block)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.public-subnet.cidr_block[count.index]
  availability_zone = var.public-subnet.availability_zone[count.index]

  tags = {
    Name = "${var.public-subnet.tags["name"]}-${count.index}"
    env = var.public-subnet.tags["env"]
  }
}

resource "aws_subnet" "private" {
  count = length(var.private-subnet.cidr_block)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.private-subnet.cidr_block[count.index]
  availability_zone = var.private-subnet.availability_zone[count.index]

  tags = {
    Name = "${var.private-subnet.tags["name"]}-${count.index}"
    env = var.private-subnet.tags["env"]
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = var.vpc.cidr_block
    gateway_id = "local"
  }

   route {
    cidr_block = var.public-rt.cidr
    gateway_id = aws_internet_gateway.dev-vpc-gw.id
  } 

  tags = {
    Name = var.public-rt.tags["name"]
    env = var.public-rt.tags["env"]
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = var.private-rt.cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = var.private-rt.tags["name"]
    env = var.private-rt.tags["env"]
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public-subnet.cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private-subnet.cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_eip" "main" {
  tags = {
    name = var.eip.tags["name"]
    env = var.eip.tags["env"]
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    name = var.natgateway.tags["name"]
    env = var.natgateway.tags["env"]
  }

  depends_on = [aws_internet_gateway.dev-vpc-gw]
}