provider "aws" {
  region     = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "tfstate3246234623456245742572457"
    key    = "prod.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-lock2"
  }
}

resource "aws_eip" "nat" {
  count = 2

  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "v2.33.0"
  name = var.vpc_name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway  = true
  single_nat_gateway  = true
  reuse_nat_ips       = false                    # <= Skip creation of EIPs for the NAT Gateways
  # external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
  # enable_vpn_gateway = true
}

module "sg_bastion" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ssh-all"
  description = "Security group for bastion-server with SSH port open to all"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "sg_web" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-80"
  description = "Security group for web-server with http port open to all"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion"

  ami                    = "ami-00f7e5c52c0f43726"
  instance_type          = "t3.micro"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [ module.sg_bastion.security_group_id ]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}