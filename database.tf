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


