# Obtiene la última AMI de Amazon Linux 2.
# Busca la imagen de máquina de Amazon más reciente para las instancias EC2.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners     = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Rol de IAM para las instancias EC2.
# Define un rol que permite a las instancias EC2 interactuar con otros servicios de AWS.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
  
}

# Política de IAM para acceder a Secrets Manager y S3.
# Define los permisos para que las instancias EC2 puedan leer secretos y acceder al bucket de S3.
resource "aws_iam_policy" "secrets_policy" {
  name = "${var.project_name}-${var.environment}-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = [
          var.db_password_secret_arn,
          var.db_username_secret_arn,
          var.flask_secret_key_secret_arn
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.photos_bucket}",
          "arn:aws:s3:::${var.photos_bucket}/*"
        ]
      }
    ]
  })
  
}

# Asocia la política al rol.
# Adjunta la política de IAM al rol de EC2.
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

# Perfil de instancia de IAM para las instancias EC2.
# Permite pasar el rol de IAM a las instancias EC2.
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Script de datos de usuario para instalar dependencias y configurar la aplicación.
# Prepara el script que se ejecutará en las instancias EC2 al iniciarse.
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name                = var.project_name
    aws_region                  = data.aws_region.current.name
    db_username_secret_arn      = var.db_username_secret_arn
    db_password_secret_arn      = var.db_password_secret_arn
    flask_secret_key_secret_arn = var.flask_secret_key_secret_arn
    db_endpoint                 = var.db_endpoint
    db_host_only                = split(":", var.db_endpoint)[0]
    photos_bucket               = var.photos_bucket
    db_name                     = var.db_name
  }))
}

# Obtiene la región de AWS actual.
data "aws_region" "current" {}

# Plantilla de lanzamiento para el grupo de Auto Scaling.
# Define la configuración de las instancias EC2 que se lanzarán.
resource "aws_launch_template" "main" {
  name_prefix = "${var.project_name}-${var.environment}-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name = var.key_name

  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = local.user_data
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-instance"
    }
  }
}

# Application Load Balancer.
# Distribuye el tráfico entrante entre las instancias EC2.
resource "aws_lb" "main" {
  name               = "${replace(var.project_name, "_", "-")}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}
  
# Grupo de destino para el grupo de Auto Scaling.
# Define el grupo de instancias que recibirán tráfico del ALB.
resource "aws_lb_target_group" "main" {
  name     = "${replace(var.project_name, "_", "-")}-${var.environment}-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path                = "/"
    interval            = 300
    timeout             = 120
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

# Listener del ALB.
# Escucha el tráfico entrante en el puerto 80 y lo reenvía al grupo de destino.
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Grupo de Auto Scaling.
# Ajusta automáticamente el número de instancias EC2 según la demanda.
resource "aws_autoscaling_group" "main" {
  name = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns = [aws_lb_target_group.main.arn]
  health_check_type = "ELB"
  health_check_grace_period = 600

  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

# Política de Auto Scaling para escalar hacia arriba.
# Define la política para agregar instancias cuando aumenta la carga.
resource "aws_autoscaling_policy" "scale_up" {
  name                  = "${var.project_name}-${var.environment}-scale-up"
  scaling_adjustment      = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Política de Auto Scaling para escalar hacia abajo.
# Define la política para eliminar instancias cuando disminuye la carga.
resource "aws_autoscaling_policy" "scale_down" {
  name                  = "${var.project_name}-${var.environment}-scale-down"
  scaling_adjustment      = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Alarmas de CloudWatch para el escalado.
# Dispara las políticas de escalado basadas en la utilización de la CPU.
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80% for 5 minutes"
  alarm_actions      = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

}

# Alarma de CloudWatch para el escalado hacia abajo.
# Dispara la política de escalado hacia abajo cuando la utilización de la CPU es baja.
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU is below 70% for 5 minutes"
  alarm_actions      = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
}