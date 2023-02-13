variable "token" {
  description = "Auth token for GitHub"
  type        = string
  sensitive   = true


}

variable "hosted_zone" {
  default = "nipo.in.net"
  type    = string

}

variable "aws_region" {
  type    = string
  default = "us-east-1"

}
