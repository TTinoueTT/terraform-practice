# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc" {
  source          = "./modules/network/vpc"
  vpc_prefix      = var.vpc_prefix
  tag_name_prefix = var.tag_name_prefix
}

module "subnet" {
  source               = "./modules/network/subnet"
  public_subnet_prefix = var.public_subnet_prefix
  tag_name_prefix      = var.tag_name_prefix
  # ref another module parameter
  depends_on     = [module.vpc]
  vpc_id         = module.vpc.vpc_id
  route_table_id = module.vpc.route_table_id
}

module "security_group_http" {
  source          = "./modules/computing/ec2_sg"
  tag_name_prefix = var.tag_name_prefix
  protocol_name   = "http"
  # ref another module parameter
  depends_on = [module.vpc]
  vpc_id     = module.vpc.vpc_id
}
module "security_group_https" {
  source          = "./modules/computing/ec2_sg"
  tag_name_prefix = var.tag_name_prefix
  protocol_name   = "https"
  # ref another module parameter
  depends_on = [module.vpc]
  vpc_id     = module.vpc.vpc_id
}
module "security_group_ssh" {
  source          = "./modules/computing/ec2_sg"
  tag_name_prefix = var.tag_name_prefix
  protocol_name   = "ssh"
  # ref another module parameter
  depends_on = [module.vpc]
  vpc_id     = module.vpc.vpc_id
}
