variable "token" {
  description = "Auth token for GitHub"
  type        = string
  sensitive   = true
  default     = ""

}

variable "hosted_zone" {
  default = "alpacked.click"
  type    = string

}

variable "aws_region" {
  type    = string
  default = "us-east-1"

}
