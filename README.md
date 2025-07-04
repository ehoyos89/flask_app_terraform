# Infraestructura AWS con Terraform

Este repositorio contiene el código Terraform para desplegar una infraestructura de aplicación web de múltiples capas en AWS, incluyendo VPC, subredes, grupos de seguridad, una base de datos RDS y un grupo de autoescalado (ASG) con un Application Load Balancer (ALB).

## Estructura del Proyecto

```
. 
├───.gitignore
├───main.tf
├───outputs.tf
├───variables.tf
├───environments/
│   ├───dev/
│   │   ├───main.tf
│   │   ├───terraform.tfvars
│   │   └───variables.tf
│   └───prod/
│       ├───main.tf
│       ├───terraform.tfvars
│       └───variables.tf
└───modules/
    ├───asg/
    ├───rds/
    ├───security_groups/
    └───vpc/
```

- `main.tf`, `outputs.tf`, `variables.tf`: Archivos principales de Terraform en la raíz del proyecto.
- `environments/`: Contiene configuraciones específicas para cada entorno (`dev` y `prod`). Cada subdirectorio tiene su propio `main.tf` (que llama a los módulos principales), `terraform.tfvars` (variables específicas del entorno) y `variables.tf`.
- `modules/`: Contiene módulos reutilizables de Terraform para componentes de infraestructura (VPC, RDS, ASG, Security Groups).

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado lo siguiente:

- [Terraform CLI](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales que tengan los permisos necesarios para crear recursos en AWS.

## Despliegue de la Infraestructura

Para desplegar la infraestructura en un entorno específico, sigue estos pasos:

1.  **Inicializar Terraform:**
    Navega al directorio raíz del proyecto y ejecuta `terraform init`. Esto descargará los proveedores y módulos necesarios.

    ```bash
    cd /directorio-del-proyecto/
    terraform init
    ```

2.  **Seleccionar el Entorno:**
    Cada entorno (`dev` y `prod`) tiene su propio archivo `terraform.tfvars` dentro de su subdirectorio (`environments/dev/terraform.tfvars` y `environments/prod/terraform.tfvars`). Estos archivos contienen las variables específicas para cada entorno.

    Para usar las variables de un entorno, debes especificar el archivo `terraform.tfvars` correspondiente al ejecutar los comandos `terraform plan` y `terraform apply`.

### Desplegar en el Entorno de Desarrollo (`dev`)

```bash
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Desplegar en el Entorno de Producción (`prod`)

```bash
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

**Nota de Seguridad:** Las contraseñas de la base de datos se generan aleatoriamente y se almacenan en AWS Secrets Manager. El módulo ASG está configurado para recuperar estas contraseñas de Secrets Manager utilizando roles de IAM, evitando que las credenciales se almacenen directamente en el código o en variables de entorno.

## Destruir la Infraestructura

Para destruir la infraestructura de un entorno específico, utiliza el comando `terraform destroy` con el archivo de variables correspondiente:

### Destruir el Entorno de Desarrollo (`dev`)

```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

### Destruir el Entorno de Producción (`prod`)

```bash
terraform destroy -var-file="environments/prod/terraform.tfvars"
```

**¡Advertencia!** El comando `terraform destroy` eliminará todos los recursos aprovisionados por Terraform para el entorno especificado. Asegúrate de que realmente deseas eliminar la infraestructura antes de ejecutarlo.