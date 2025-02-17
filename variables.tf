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

variable "profile" {
  type = string
}


variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}