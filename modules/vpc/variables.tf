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
}

# Variable para el CIDR de la VPC.
# Descripción: Bloque CIDR para la VPC.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Variable para las zonas de disponibilidad.
# Descripción: Valores de las zonas de disponibilidad a utilizar para las subredes.
variable "availability_zones" {
  description = "values of the availability zones to use for subnets"
  type        = list(string)
}

# Variable para los CIDR de las subredes públicas.
# Descripción: Lista de bloques CIDR para las subredes públicas.
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  
}

# Variable para los CIDR de las subredes privadas.
# Descripción: Lista de bloques CIDR para las subredes privadas.
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  
}

# Variable para habilitar/deshabilitar VPC Flow Logs.
# Descripción: Si es verdadero, habilita VPC Flow Logs.
variable "enable_flow_log" {
  description = "If true, enables VPC Flow Logs"
  type        = bool
  default     = false
}
