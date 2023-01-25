variable "aws_region" {
  type    = string
  default = "us-east-1"

}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]

}

variable "cluster_service_ipv4_cidr" {
  type    = string
  default = "172.20.0.0/16"

}

variable "cluster_version" {
  type    = string
  default = "1.24"


}
