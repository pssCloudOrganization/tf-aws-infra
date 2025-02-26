variable "region" {
  type = string
}

variable "cidr" {
  type = string
}

variable "cidr_igw" {
  type = string
}

variable "vpc_name" {
  type = string
}

# variable "availability_zones" {
#   type = list(string)
# }
variable "ami_id" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "app_port" {
  type = string
}

variable "instance_type" {
  type = string
}