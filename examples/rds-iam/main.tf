provider "aws" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow traffic for RDS"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_rds_cluster" "default" {
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "mydb"
  db_cluster_instance_class = "db.r6g.large"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.1"
  iam_database_authentication_enabled = true
  master_username         = "foo"
  master_password         = "bar"
  vpc_security_group_ids = [aws_security_group.allow_rds.id]
}
