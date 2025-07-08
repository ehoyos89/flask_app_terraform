# Infraestructura AWS con Terraform

Este repositorio contiene el código Terraform para desplegar una infraestructura de aplicación web de múltiples capas en AWS, incluyendo VPC, subredes, grupos de seguridad, una base de datos RDS y un grupo de autoescalado (ASG) con un Application Load Balancer (ALB).

## Estructura del Proyecto

```
.
├───.gitignore
├───LICENSE
├───main.tf
├───outputs.tf
├───README.md
├───variables.tf
├───.git/...
├───.terraform/...
├───environments/
│   ├───dev/
│   │   ├───main.tf
│   │   └───variables.tf
│   └───prod/
│       ├───main.tf
│       └───variables.tf
└───modules/
    ├───asg/
    │   ├───main.tf
    │   ├───outputs.tf
    │   ├───user_data.sh
    │   └───variables.tf
    ├───rds/
    │   ├───main.tf
    │   ├───outputs.tf
    │   └───variables.tf
    ├───s3/
    │   ├───main.tf
    │   ├───outputs.tf
    │   └───variables.tf
    ├───security_groups/
    │   ├───main.tf
    │   ├───outputs.tf
    │   └───variables.tf
    └───vpc/
        ├───main.tf
        ├───outputs.tf
        └───variables.tf
```

- `main.tf`, `outputs.tf`, `variables.tf`: Archivos principales de Terraform en la raíz del proyecto.
- `environments/`: Contiene configuraciones específicas para cada entorno (`dev` y `prod`).
- `modules/`: Contiene módulos reutilizables de Terraform para componentes de infraestructura (VPC, RDS, ASG, Security Groups, S3).

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado lo siguiente:

- [Terraform CLI](https.www.terraform.io/downloads.html)
- [AWS CLI](https.aws.amazon.com/cli/) configurado con credenciales que tengan los permisos necesarios para crear recursos en AWS.

## Despliegue de la Infraestructura

Para desplegar la infraestructura en un entorno específico, sigue estos pasos:

1.  **Inicializar Terraform:**
    Navega al directorio del entorno que deseas desplegar y ejecuta `terraform init`.

    ```bash
    cd environments/dev
    terraform init
    ```

2.  **Planificar y Aplicar los Cambios:**
    Una vez inicializado, puedes ejecutar `terraform plan` para ver los cambios y `terraform apply` para desplegarlos.

    ```bash
    terraform plan
    terraform apply
    ```

**Nota de Seguridad:** Las contraseñas de la base de datos se generan aleatoriamente y se almacenan en AWS Secrets Manager. El módulo ASG está configurado para recuperar estas contraseñas de Secrets Manager utilizando roles de IAM, evitando que las credenciales se almacenen directamente en el código o en variables de entorno.

## Destruir la Infraestructura

Para destruir la infraestructura de un entorno específico, utiliza el comando `terraform destroy` desde el directorio del entorno correspondiente:

```bash
cd environments/dev
terraform destroy
```

**¡Advertencia!** El comando `terraform destroy` eliminará todos los recursos aprovisionados por Terraform para el entorno especificado. Asegúrate de que realmente deseas eliminar la infraestructura antes de ejecutarlo.