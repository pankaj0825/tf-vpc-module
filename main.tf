resource "aws_vpc" "dev-vpc" {
  cidr_block       = var.vpc.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc.tags["name"]
    env = var.vpc.tags["env"]
  }
}

resource "aws_internet_gateway" "dev-vpc-gw" {
  count = var.igw == true ? 1 : 0
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = var.internet-gw-tag
  }
}

resource "aws_subnet" "public" {
  count = var.public_subnet_rt == true ? length(var.public-subnet.cidr_block) : 0
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.public-subnet.cidr_block[count.index]
  availability_zone = var.public-subnet.availability_zone[count.index]

  tags = {
    Name = "${var.public-subnet.tags["name"]}-${count.index}"
    env = var.public-subnet.tags["env"]
  }
}

resource "aws_subnet" "private" {
  count = var.private_subnet_rt == true ? length(var.private-subnet.cidr_block) : 0
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.private-subnet.cidr_block[count.index]
  availability_zone = var.private-subnet.availability_zone[count.index]

  tags = {
    Name = "${var.private-subnet.tags["name"]}-${count.index}"
    env = var.private-subnet.tags["env"]
  }
}

resource "aws_eip" "main" {
  count = var.nat ? 1 : 0
  tags = {
    name = var.eip.tags["name"]
    env = var.eip.tags["env"]
  }
}

resource "aws_nat_gateway" "main" {
  count = var.nat ? 1 : 0
  allocation_id = aws_eip.main[0].id
  subnet_id = aws_subnet.public[0].id
  tags = {
    name = var.natgateway.tags["name"]
    env = var.natgateway.tags["env"]
  }
}

resource "aws_route_table" "public-rt" {
  count = var.public_subnet_rt == true ? 1 : 0
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = var.vpc.cidr_block
    gateway_id = "local"
  }

   route {
    cidr_block = var.public-rt.cidr
    gateway_id = aws_internet_gateway.dev-vpc-gw[count.index].id
  } 

  tags = {
    Name = var.public-rt.tags["name"]
    env = var.public-rt.tags["env"]
  }
}

resource "aws_route_table" "private-rt" {
  count = var.private_subnet_rt == true ? 1 : 0
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = var.private-rt.cidr
    gateway_id = "local"
  }

  dynamic "route" {
    for_each = var.nat == true ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = {
    Name = var.private-rt.tags["name"]
    env = var.private-rt.tags["env"]
  }
}

resource "aws_route_table_association" "public" {
  count = var.public_subnet_rt == true ? length(var.public-subnet.cidr_block) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt[count.index].id
}

resource "aws_route_table_association" "private" {
  count = var.private_subnet_rt == true ? length(var.private-subnet.cidr_block) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt[0].id
}