provider "aws" {
  region = "us-east-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "eureka-server-dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24"]
  vpc-private-subnet-cidr             = ["10.20.4.0/24","10.20.5.0/24"]
  vpc-database_subnets-cidr           = ["10.20.7.0/24", "10.20.8.0/24"]
}


module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "eureka-server"
  tcp_ports           = "22,80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "eureka-server"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "eureka-server-Ref"
  tcp_ports               = "22,80,443"
  ref_security_groups_ids = [module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default]
  security_group_name     = "eureka-server-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "eureka-server-eip" {
  source = "../../modules/eip/eureka-server"
  name                         = "eureka-server"
  instance                     = module.ec2-eureka-server.id[0]
}

module "ec2-eureka-server" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "eureka-server"
  key_name                      = "eureka-server"
  public_key                    = file("../../modules/secrets/eureka-server.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/eureka-server.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

module "eureka-shirts" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "eureka-shirts"
  key_name                      = "shirts"
  public_key                    = file("../../modules/secrets/shirts.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/eureka-shirts.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

module "eureka-shopping-cart" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "eureka-shopping-cart"
  key_name                      = "shopping-cart"
  public_key                    = file("../../modules/secrets/shopping-cart.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/eureka-shopping-cart.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}


module "eureka-shirts-plus-shopping-cart" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "eureka-multiple-services"
  key_name                      = "eureka-multiple-services"
  public_key                    = file("../../modules/secrets/eureka-multiple-services.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/eureka-shirts-plus-shopping-cart.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

