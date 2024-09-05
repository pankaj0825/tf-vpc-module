variable "region" {
  type = string
  default = "ap-south-1"
}

variable "internet-gw-tag" {
  type = string
  default = "dev-vpc-igw"
}

variable "public-rt" {
  type = object({
    cidr = string
    tags = map(string)
  })
  default = {
    cidr = "0.0.0.0/0"
    tags = {
      "name" = "dev-vpc-public-rt"
      "env" = "development"
    }
  }
}

variable "private-rt" {
  type = object({
    cidr = string
    tags = map(string)
  })
  default = {
    cidr = "172.31.0.0/16"
    tags = {
      "name" = "dev-vpc-private-rt"
      "env" = "development"
    }
  }
}

variable "vpc" {
  type = object({
    cidr_block = string
    tags = map(string)
  })
  default = {
    cidr_block = "172.31.0.0/16"
    tags = {
      "name" = "dev-vpc"
      "env" = "development"
    }
  }
}

variable "public-subnet" {
  type = object({
    availability_zone = list(string)
    cidr_block = list(string)
    tags = map(string)
  })
  default = {
    availability_zone = [ "ap-south-1a" ]
    cidr_block = [ "172.31.0.0/24" ]
    tags = {
      "name" = "dev-vpc-public"
      "env" = "development"
    }
  }
}

variable "private-subnet" {
  type = object({
    availability_zone = list(string)
    cidr_block = list(string)
    tags = map(string)
  })
  default = {
    availability_zone = ["ap-south-1b", "ap-south-1c"]
    cidr_block = [ "172.31.16.0/20", "172.31.32.0/20" ]
     tags = {
      "name" = "dev-vpc-private"
      "env" = "development"
    }
  }
}