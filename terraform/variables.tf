variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "my_ip_cidr" {
  description = "Your IP in CIDR notation for SSH access"
  type        = string
}