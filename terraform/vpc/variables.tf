variable "aws_region" {
  type    = string
  default = "us-east-1"

}

variable "eks_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

}

variable "eks_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]

}

variable "eks_public_subnets" {
  type    = list(string)
  default = ["10.0.100.0/24", "10.0.200.0/24"]

}

