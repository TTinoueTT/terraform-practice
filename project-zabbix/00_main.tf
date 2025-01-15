
# vpcモジュールを呼び出す
module "vpc" {
  source      = "./module/vpc"
  env         = var.env
  system      = var.system
  cidr_vpc    = var.vpc_cidr
  cidr_public = var.cidr_public
}

# ec2モジュールを呼び出す
module "ec2" {
  source  = "./module/computing/ec2"
  env     = var.env
  system  = var.system
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.subnets
  # my_ip        = var.my_ip
  instance_cnt = var.instance_cnt
  # ami          = var.ami
  sg_ec2_id = module.security_group.sg_ec2_id
  type      = var.type
  key_name  = var.key_name
}

# attach sg for ec2 and elb
module "security_group" {
  source = "./module/computing/sg"
  env    = var.env
  system = var.system
  my_ip  = var.my_ip
  # ref another module parameter
  depends_on = [module.vpc]
  vpc_id     = module.vpc.vpc_id
}

module "sg_http" {
  source = "./module/computing/sg_rule"
  env    = var.env
  system = var.system
  sg_id  = module.security_group.sg_ec2_id
  ingress_rule = {
    cidr_ipv4   = "${var.my_ip}"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  # ref another module parameter
  depends_on = [module.security_group]
  vpc_id     = module.vpc.vpc_id
}

module "sg_https" {
  source = "./module/computing/sg_rule"
  env    = var.env
  system = var.system
  sg_id  = module.security_group.sg_ec2_id
  ingress_rule = {
    cidr_ipv4   = "${var.my_ip}"
    from_port   = 443
    ip_protocol = "tcp"
    to_port     = 443
  }
  # ref another module parameter
  depends_on = [module.security_group]
  vpc_id     = module.vpc.vpc_id
}

module "sg_ssh" {
  source = "./module/computing/sg_rule"
  env    = var.env
  system = var.system
  sg_id  = module.security_group.sg_ec2_id
  ingress_rule = {
    cidr_ipv4   = "${var.my_ip}"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
  # ref another module parameter
  depends_on = [module.security_group]
  vpc_id     = module.vpc.vpc_id
}

module "sg_icmp" {
  source = "./module/computing/sg_rule"
  env    = var.env
  system = var.system
  sg_id  = module.security_group.sg_ec2_id
  ingress_rule = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = -1
    ip_protocol = "icmp"
    to_port     = -1
  }
  # ref another module parameter
  depends_on = [module.security_group]
  vpc_id     = module.vpc.vpc_id
}
