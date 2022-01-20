variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  default     = "hello_vpc"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "The AZs for the VPC"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "The private_subnets for the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "The public_subnets for the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "ssh_key_name" {
  default     = "rich@work-rackspace"
}

variable "image_id" {
  default     = "ami-00f7e5c52c0f43726"
}

variable "region" {
  default     = "us-west-2"
}

variable "environment" {
  default     = "prod"
}