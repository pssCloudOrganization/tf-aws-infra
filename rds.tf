resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "custom-mysql-parameters"
  family = var.db_family

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  tags = {
    Name = "Custom DB Parameter Group"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  engine_version         = var.db_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_storage_size
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false

  tags = {
    Name = "RDS Instance"
  }
}
