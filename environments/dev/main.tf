# Módulo principal de la infraestructura para el entorno de desarrollo.
# Este módulo despliega la infraestructura de la aplicación Flask en el entorno de desarrollo.
module "flask_infraestructure" {
  source = "../.." # Hace referencia al módulo raíz del proyecto.

  project_name = var.project_name
  environment = "dev"
  aws_region = var.aws_region

  # Configuración de la VPC (Virtual Private Cloud).
  # Define los bloques CIDR para la VPC y las subredes públicas y privadas.
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  # Configuración de las instancias EC2.
  # Define el tipo de instancia, el nombre de la clave SSH y la configuración del Auto Scaling Group.
  instance_type = "t2.micro"
  key_name = var.key_name
  asg_min_size = 1
  asg_max_size = 2
  asg_desired_capacity = 1

  # Configuración de la base de datos RDS.
  # Define la clase de instancia, el almacenamiento, el nombre de la base de datos y el nombre de usuario.
  db_instance_class = "db.t4g.micro"
  db_allocated_storage = 20
  db_name = var.db_name
  db_username = var.db_username
  #photos_bucket = module.s3.photos_bucket_name
}