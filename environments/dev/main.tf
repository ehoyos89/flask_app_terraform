module "flask_infraestructure" {
  source = "../.."

  project_name = var.project_name
  environment = "dev"
  aws_region = var.aws_region

  # VPC configuration
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  # EC2 configuration
  instance_type = "t2.micro"
  key_name = var.key_name
  asg_min_size = 1
  asg_max_size = 2
  asg_desired_capacity = 1

  # RDS configuration
  db_instance_class = "db.t4g.micro"
  db_allocated_storage = 20
  db_name = var.db_name
  db_username = var.db_username
  photos_bucket = module.s3.photos_bucket_name
}