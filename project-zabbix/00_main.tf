
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
  my_ip        = var.my_ip
  instance_cnt = var.instance_cnt
  ami          = var.ami
  type         = var.type
  key_name     = var.key_name
}

# data "aws_ami" "example" {
#   executable_users = ["self"]
#   most_recent      = true
#   name_regex       = "^myami-[0-9]{3}"
#   owners           = ["self"]

#   filter {
#     name   = "name"
#     values = ["myami-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# aws ec2 describe-images --owners amazon \
#   --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*24*" \
#   --query 'reverse(sort_by(Images, &CreationDate))' \
#   --output json >> output-imge-info.json

# aws ec2 describe-images --owners 099720109477 \
#   --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*24*" \
#   --query 'reverse(sort_by(Images, &CreationDate))' \
#   --output json >> output-imge-info.json
