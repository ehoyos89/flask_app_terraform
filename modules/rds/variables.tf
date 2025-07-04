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
# Descripción: Valor del ID de la VPC.
variable "vpc_id" {
  description = "value of the VPC ID"
  type        = string
}

# Variable para los IDs de las subredes privadas.
# Descripción: Lista de IDs de las subredes privadas.
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# Variable para el ID del grupo de seguridad.
# Descripción: ID del grupo de seguridad para RDS.
variable "security_group_id" {
  description = "ID of the security group for RDS"
  type        = string
}

# Variable para la clase de instancia de la base de datos.
# Descripción: Clase de instancia para la base de datos RDS.
variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
}

# Variable para el almacenamiento asignado de la base de datos.
# Descripción: Almacenamiento asignado para la base de datos RDS en GB.
variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
}

# Variable para el nombre de la base de datos.
# Descripción: Nombre de la base de datos RDS.
variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  
}

# Variable para el nombre de usuario de la base de datos.
# Descripción: Nombre de usuario para la base de datos RDS.
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

# Variable para Multi-AZ.
# Descripción: Habilita Multi-AZ para RDS.
variable "multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false 
}