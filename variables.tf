# Variable para la región de AWS.
# Descripción: La región de AWS en la que se desplegarán los recursos.
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Variable para el nombre del proyecto.
# Descripción: El nombre del proyecto.
variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Variable para el entorno.
# Descripción: El entorno para el despliegue (dev/prod).
variable "environment" {
  description = "The environment for the deployment (dev/prod)"
  type        = string

  validation {
    condition = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
  
}

# Variable para el CIDR de la VPC.
# Descripción: Bloque CIDR para la VPC.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Variable para los CIDR de las subredes públicas.
# Descripción: Valores para los CIDR de las subredes públicas.
variable "public_subnet_cidrs" {
  description = "values for public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Variable para los CIDR de las subredes privadas.
# Descripción: Valores para los CIDR de las subredes privadas.
variable "private_subnet_cidrs" {
  description = "values for private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Variable para el tipo de instancia.
# Descripción: Tipo de instancia para las instancias EC2.
variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

# Variable para el nombre del par de claves.
# Descripción: Nombre del par de claves SSH a utilizar para las instancias EC2.
variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

# Variable para el tamaño mínimo del ASG.
# Descripción: Tamaño mínimo del Auto Scaling Group.
variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling group"
  type        = number
  default     = 1
}

# Variable para el tamaño máximo del ASG.
# Descripción: Tamaño máximo del Auto Scaling Group.
variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling group"
  type        = number
  default     = 3
}

# Variable para la capacidad deseada del ASG.
# Descripción: Capacidad deseada del Auto Scaling Group.
variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling group"
  type        = number
  default     = 1
}

# Variable para la clase de instancia de la base de datos.
# Descripción: Clase de instancia para la base de datos RDS.
variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t4g.micro"
  
}

# Variable para el almacenamiento asignado de la base de datos.
# Descripción: Almacenamiento asignado para la base de datos RDS en GB.
variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
  default     = 20
}

# Variable para el nombre de la base de datos.
# Descripción: Nombre de la base de datos RDS.
variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "flaskappdb"
}

# Variable para el nombre de usuario de la base de datos.
# Descripción: Nombre de usuario para la base de datos RDS.
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

#Variable para la dirección de correo electrónico para notificaciones de escalado.
# Descripción: Dirección de correo electrónico para recibir notificaciones de escalado del ASG.
# Si no se proporciona, no se enviarán notificaciones.
variable "notification_email" {
  description = "The email address for ASG scaling notifications. If not provided, no notifications will be sent."
  type        = string
  default     = ""
  
}
