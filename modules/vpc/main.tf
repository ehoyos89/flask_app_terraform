# VPC (Virtual Private Cloud)
# Crea la red principal.
resource "aws_vpc" "main" {
  cidr_block                  = var.vpc_cidr
  enable_dns_hostnames        = true
  enable_dns_support          = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Internet Gateway
# Permite la comunicación entre la VPC e Internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Elastic IP para NAT Gateway
# Asigna una IP pública estática a la NAT Gateway.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# Subredes Públicas
# Subredes con acceso directo a Internet.
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    type = "public"
  }
}

# Subredes Privadas
# Subredes sin acceso directo a Internet.
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    type = "private"
  }
}

# NAT Gateway
# Permite a las instancias en subredes privadas acceder a Internet.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.main]
}
# Tabla de Rutas para Subredes Públicas
# Dirige el tráfico de las subredes públicas a Internet a través del Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

# Tabla de Rutas para Subredes Privadas
# Dirige el tráfico de las subredes privadas a Internet a través de la NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# Asociaciones de Tablas de Rutas
# Asocia las tablas de rutas con sus respectivas subredes.
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id

}

# CloudWatch Log Group para VPC Flow Logs
# Almacena los registros de flujo de la VPC.
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_log ? 1 : 0
  name  = "/aws/vpc/${var.project_name}-${var.environment}-flow-logs"

  tags = {
    Name = "${var.project_name}-${var.environment}-flow-logs"
  }
}

# Rol de IAM para VPC Flow Logs
# Permite a VPC Flow Logs publicar en CloudWatch.
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_log ? 1 : 0
  name  = "${var.project_name}-${var.environment}-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-flow-logs-role"
  }
}

# Política de IAM para VPC Flow Logs
# Define los permisos para que el rol de Flow Logs pueda escribir en CloudWatch.
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_log ? 1 : 0
  name  = "${var.project_name}-${var.environment}-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# VPC Flow Log
# Habilita el registro de tráfico para las subredes públicas.
resource "aws_flow_log" "public_subnets" {
  count = var.enable_flow_log ? length(aws_subnet.public) : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  subnet_id       = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-flow-log-public-${count.index + 1}"
  }

  depends_on = [aws_iam_role_policy.flow_logs]
}

