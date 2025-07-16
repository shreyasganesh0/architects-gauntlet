# main.tf

provider "aws" {

	region = "us-east-1"

}

resource "random_string" "bucket_suffix" {

	length = 8
	special = false
	upper = false
}

resource "aws_s3_bucket" "uploads" {

	bucket = "architects-gauntlet-uploads-${random_string.bucket_suffix.result}"
	force_destroy = true 
	# would be false with proper lifecycle management
	# set as true for dev startup purposes
}

resource "aws_iam_role" "url_generator_role" {

	name = "url-generator-lambda-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Action = "sts:AssumeRole",
				Effect = "Allow",
				Principal = { 
					Service = "lambda:amazonaws.com"
				}
			}
		]
	})
}


resource "aws_iam_policy" "url_generator_policy" {

	name = "s3-upload-permissions-policy"
	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Action = "s3:PutObject",
				Effect = "Allow",
				Resource: "${aws_s3_bucket.uploads.arn}/*"
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "connect_policy_to_role" {
	
	role = aws_iam_role.url_generator_role.name
	policy_arn = aws_iam_policy.url_generator_policy.arn
}
	
