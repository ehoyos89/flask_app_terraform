# Variable para el nombre del proyecto.
# Descripción: Nombre del proyecto.
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Variable para el entorno.
# Descripción: Entorno (dev/prod).
variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

# Variable para el ID de la VPC.
# Descripción: ID de la VPC.
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# Variable para los IDs de las subredes públicas.
# Descripción: Lista de IDs de las subredes públicas.
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  
}

# Variable para el ID del grupo de seguridad.
# Descripción: ID del grupo de seguridad para el grupo de Auto Scaling.
variable "security_group_id" {
  description = "ID of the security group for the Auto Scaling group"
  type        = string
  
}

# Variable para el tipo de instancia.
# Descripción: Tipo de instancia para el grupo de Auto Scaling.
variable "instance_type" {
  description = "Instance type for the Auto Scaling group"
  type        = string
}

# Variable para el nombre del par de claves.
# Descripción: Nombre del par de claves para las instancias EC2.
variable "key_name" {
  description = "Name of the key pair for the EC2 instances"
  type        = string
}

# Variable para el tamaño mínimo.
# Descripción: Tamaño mínimo del grupo de Auto Scaling.
variable "min_size" {
  description = "Minimum size of the Auto Scaling group"
  type        = number
}

# Variable para el tamaño máximo.
# Descripción: Tamaño máximo del grupo de Auto Scaling.
variable "max_size" {
  description = "Maximum size of the Auto Scaling group"
  type        = number
}

# Variable para la capacidad deseada.
# Descripción: Capacidad deseada del grupo de Auto Scaling.
variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling group"
  type        = number
}

# Variable para el endpoint de la base de datos.
# Descripción: Endpoint de la base de datos RDS.
variable "db_endpoint" {
  description = "Endpoint of the RDS database"
  type        = string  
}

# Variable para el nombre de la base de datos.
# Descripción: Nombre de la base de datos RDS.
variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

# Variable para el ARN del secreto de la contraseña de la base de datos.
# Descripción: ARN del secreto de AWS Secrets Manager que contiene la contraseña de la base de datos RDS.
variable "db_password_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the RDS database password"
  type        = string
}

# Variable para el ARN del secreto del nombre de usuario de la base de datos.
# Descripción: ARN del secreto para el nombre de usuario de la base de datos.
variable "db_username_secret_arn" {
  description = "ARN of the secret for the database username"
  type        = string
}

# Variable para el ARN del secreto de la clave secreta de Flask.
# Descripción: ARN del secreto para la clave secreta de Flask.
variable "flask_secret_key_secret_arn" {
  description = "ARN of the secret for the Flask secret key"
  type        = string
}

# Variable para el bucket de fotos.
# Descripción: Nombre del bucket de S3 para las fotos.
variable "photos_bucket" {
  description = "Name of the S3 bucket for photos"
  type        = string
}

# Variable para el ID del grupo de seguridad del ALB.
# Descripción: ID del grupo de seguridad del ALB.
variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

# Variable para la direccion de correo a usarse en la notificacion SNS.
# Descripción: Dirección de correo electrónico para las notificaciones de SNS.
variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = ""
}