
# vpcモジュールを呼び出す
module "vpc" {
  source      = "./module/vpc"
  system      = var.system
  env         = var.env
  cidr_vpc    = var.vpc_cidr
  cidr_public = var.cidr_public
}

# ec2モジュールを呼び出す
module "ec2" {
  source       = "./module/ec2"
  system       = var.system
  env          = var.env
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.subnets
  myip         = var.myip
  instance_cnt = var.instance_cnt
  ami          = var.ami
  type         = var.type
  key_name     = var.key_name
}
