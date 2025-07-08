# Variable para el nombre del proyecto.
# Descripción: El nombre del proyecto.
variable "project_name" {
  description = "The name of the project"
  type        = string
  default = "flask_app"
}

# Variable para la región de AWS.
# Descripción: La región de AWS en la que se desplegarán los recursos.
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Variable para el nombre del par de claves SSH.
# Descripción: Nombre del par de claves SSH a utilizar para las instancias EC2.
variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

# Variable para el nombre de la base de datos RDS.
# Descripción: Nombre de la base de datos RDS.
variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "flaskdb"
}

# Variable para el nombre de usuario de la base de datos RDS.
# Descripción: Nombre de usuario para la base de datos RDS.
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}


#Variable para la dirección de correo electrónico para notificaciones de escalado.
# Descripción: Dirección de correo electrónico para recibir notificaciones de escalado del ASG.
# Si no se proporciona, no se enviarán notificaciones.
variable "notification_email" {
  description = "The email address for ASG scaling notifications. If not provided, no notifications will be sent."
  type        = string
  default     = ""
  
}

# Variable para habilitar los registros de flujo de la VPC.
# Descripción: Habilita los registros de flujo de la VPC para monitoreo y análisis de tráfico.
variable "enable_flow_log" {
  description = "Enable VPC flow logs for monitoring and traffic analysis"
  type        = bool
  default     = false
}


