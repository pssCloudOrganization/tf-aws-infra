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

variable "db_port" {
  type = number

}

variable "db_storage_size" {
  type = number
}
variable "db_password" {
  type        = string
  description = "Password for the RDS database"
  sensitive   = true
}

variable "db_identifier" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_version" {
  type = string
}
variable "db_instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_family" {
  type = string
}