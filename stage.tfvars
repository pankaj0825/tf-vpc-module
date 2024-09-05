region = "ap-south-1"
internet-gw-tag = "stage-vpc-igw"

vpc = {
  cidr_block = "172.31.0.0/16"
  tags = {
    "name" = "stage-vpc"
    "env" = "staging"
  }
}

public-subnet = {
  availability_zone = [ "ap-south-1a" ]
  cidr_block = [ "172.31.0.0/24" ]
  tags = {
    "name" = "stage-public"
    "env" = "staging"
  }
}

private-subnet = {
  availability_zone = [ "ap-south-1b", "ap-south-1c" ]
  cidr_block = [ "172.31.16.0/20", "172.31.32.0/20" ]
  tags = {
    "name" = "stage-private"
    "env" = "staging"
  }
}

public-rt = {
  cidr = "0.0.0.0/0"
  tags = {
    "name" = "stage-public-rt"
    "env" = "staging"
  }
}

private-rt = {
  cidr = "172.31.0.0/16"
  tags = {
    "name" = "stage-private-rt"
    "env" = "staging"
  }
}