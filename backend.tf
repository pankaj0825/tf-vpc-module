terraform {
  backend "s3" {
    bucket = "backendstatefile-tf"
    key    = "vpc/dev/"
    region = "ap-south-1"
  }
}
