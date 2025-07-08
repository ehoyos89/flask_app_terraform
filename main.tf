# Bloque de configuración de Terraform.
# Define la versión de Terraform requerida y los proveedores necesarios.
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuración del proveedor de AWS.
# Define la región de AWS y las etiquetas por defecto para todos los recursos.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy  = "Terraform"
    }
  }
}

# Fuentes de datos (Data Sources).
# Obtiene las zonas de disponibilidad disponibles en la región de AWS configurada.
data "aws_availability_zones" "available" {
  state = "available"
}

# Módulo de VPC (Virtual Private Cloud).
# Crea la red principal, incluyendo subredes públicas y privadas.
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_flow_log = var.enable_flow_log
}

# Módulo de grupos de seguridad.
# Define las reglas de firewall para los recursos de la VPC.
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# Módulo de RDS (Relational Database Service).
# Crea la base de datos de la aplicación.
module "rds" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_security_group_id
  db_instance_class = var.db_instance_class
  db_name = var.db_name
  db_username = var.db_username
  db_allocated_storage = var.db_allocated_storage
  multi_az = var.environment == "production" ? true : false
}

# Módulo de S3 (Simple Storage Service).
# Crea un bucket de S3 para almacenar archivos.
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# Módulo de Auto Scaling Group (ASG).
# Crea un grupo de autoescalado para las instancias EC2 de la aplicación.
module "asg" {
  source = "./modules/asg"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.ec2_security_group_id
  alb_security_group_id = module.security_groups.alb_security_group_id
  instance_type = var.instance_type
  key_name = var.key_name
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  db_endpoint = module.rds.db_endpoint
  db_name = var.db_name
  db_password_secret_arn = module.rds.db_password_secret_arn
  db_username_secret_arn = module.rds.db_username_secret_arn
  flask_secret_key_secret_arn = module.rds.flask_secret_key_secret_arn
  photos_bucket = module.s3.photos_bucket_name
  notification_email = var.notification_email
}