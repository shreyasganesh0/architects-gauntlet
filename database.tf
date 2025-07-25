resource "aws_security_group" "lambda_sg" {

	name	    = "lambda-sg"
	description = "allow communications from lambd"
}

resource "aws_security_group" "database_sg" {

	name	    = "database-sg"
	description = "allow communications to database"
	
	ingress {
		from_port = 5432
		to_port   = 5432
		protocol  = "tcp"
		security_groups = [aws_security_group.lambda_sg.id]
	}
	
}

resource "random_password" "db_pass" {
	length = 16
	special = false
}

resource "aws_secretsmanager_secret" "database_master_password" {
	name = "database-master-password"
}

resource "aws_secretsmanager_secret_version" "database_password_version" {
	
	secret_id = aws_secretsmanager_secret.database_master_password.id
	secret_string = random_password.db_pass.result
}

data "aws_vpc" "def_vpc" {
	default = true
}

data "aws_subnets" "def_subnet" {

	filter {
		name   = "vpc-id"
		values = [data.aws_vpc.def_vpc.id]
	}
}

resource "aws_db_subnet_group" "default" {
	name = "main"
	subnet_ids = data.aws_subnets.def_subnet.ids
}

resource "aws_db_instance" "db_instance" {
	
	allocated_storage = 20
	instance_class = "db.t3.micro"
	
	engine = "postgres"
	engine_version = "16.9"

	db_subnet_group_name = aws_db_subnet_group.default.name

	vpc_security_group_ids = [aws_security_group.database_sg.id]
	
	username = "masteruser"
	password = random_password.db_pass.result

	skip_final_snapshot = true
	publicly_accessible = false
}

resource "aws_iam_role" "db_proxy" {
	
	name = "database-proxy-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Effect = "Allow",
				Action = "sts:AssumeRole",
				Principal = { 
					Service = "rds.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "attach_db_proxy_framework_policy" {
	role       = aws_iam_role.db_proxy.name
    policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSProxyFrameworkRolePolicy"
}

resource "aws_db_proxy" "master_db" {

	name = "master-db-proxy"
	engine_family = "POSTGRESQL"
	idle_client_timeout = 1800
	vpc_subnet_ids = data.aws_subnets.def_subnet.ids
	vpc_security_group_ids = [aws_security_group.database_sg.id]
	auth {
		auth_scheme = "SECRETS"
		description = "Auth for the database secrets"
		iam_auth = "DISABLED"
		secret_arn  = aws_secretsmanager_secret.database_master_password.arn
	}
	role_arn = aws_iam_role.db_proxy.arn
}

resource "aws_db_proxy_default_target_group" "master_db"  {
	db_proxy_name = aws_db_proxy.master_db.name
}

resource "aws_db_proxy_target" "master_db" {
	db_instance_identifier = aws_db_instance.db_instance.identifier
	db_proxy_name = aws_db_proxy.master_db.name
	target_group_name = aws_db_proxy_default_target_group.master_db.name
}
