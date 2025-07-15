#---------------- Network Module ---------------------
module "network" {
  source                    = "git::https://github.com/iamKimlong/Deploying-AWS-webapp-with-Terraform-GitHub-Actions.git//Terraform/networking"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_1_cidr      = var.public_subnet_1_cidr
  public_subnet_2_cidr      = var.public_subnet_2_cidr
  private_app_subnet_1_cidr = var.private_app_subnet_1_cidr
  private_app_subnet_2_cidr = var.private_app_subnet_2_cidr
  private_db_subnet_1_cidr  = var.private_db_subnet_1_cidr
  private_db_subnet_2_cidr  = var.private_db_subnet_2_cidr
  region                    = var.region
}
