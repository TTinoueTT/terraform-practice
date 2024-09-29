# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc" {
  source               = "./modules/network/vpc"
  vpc_prefix           = var.vpc_prefix
  public_subnet_prefix = var.public_subnet_prefix
  tag_name_prefix      = var.tag_name_prefix
}

# module "subnet" {
#   source          = "./modules/network/vpc"
#   vpc_prefix      = var.vpc_prefix
#   public_subnet_prefix   = var.public_subnet_prefix
#   tag_name_prefix = var.tag_name_prefix
# }
