module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  db_username  = var.db_username
  db_password  = var.db_password
}

module "ec2" {
  source = "./modules/ec2"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}


#Este archivo es el archivo principal de configuración de Terraform. Aquí se definen los módulos que se utilizarán para crear los recursos de infraestructura, como VPC, RDS y EC2. Los módulos permiten organizar y reutilizar configuraciones de Terraform.