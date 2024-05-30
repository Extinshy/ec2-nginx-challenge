provider "aws" {
  region = var.region
}

resource "random_pet" "resources" {
  length = 1
  prefix = "challenge"
}

#MODULE NETWORK
module "networking" {
  source = "./modules/networking"

  cidr     = var.cidr
  region   = var.region
  vpc_cidr = var.vpc_range
}
#MODULE ec2

module "ec2" {
  source              = "./modules/ec2"
  instance_type       = var.instance_type
  random_pet          = random_pet.resources.id
  private_subnet      = module.networking.private_subnet_id
  security_gr_ec2     = module.networking.security_groups_ec2_id
  public_subnet       = module.networking.public_subnet_id
  security_gr_bastion = module.networking.security_groups_bastion_id
}

# MODULE LB

module "lb" {
  source         = "./modules/load balancer"
  random_pet     = random_pet.resources.id
  public_subnet  = module.networking.public_subnet_id
  security_gr    = module.networking.security_groups_lb_id
  private_subnet = module.networking.private_subnet_id
  vpc_id         = module.networking.vpc_id
  instance_id    = module.ec2.instance_id
}