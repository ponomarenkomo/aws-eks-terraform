variable "aws_region" {
  type    = string
  default = "us-east-1"

}

variable "state_bucket" {
  type    = string
  default = "aws-terraform-remote-state-bucket"

}
