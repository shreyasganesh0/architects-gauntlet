# Lambda Handlers

## Lambda Handler in Go
Handlers in lambda functions - the method in lambda function code
function runs till the handler returns, or timesout

### Setup Go Handler
go get github.com/aws/aws-lambda-go

for s3 client 
    - "github.com/aws/aws-sdk-go-v2/config"
    - config.LoadDefaultConfig(context.TODO())
    - s3Client := s3.NewFromConfig(cfg)
    - will load configuration of the s3 client from the aws config file
put s3 bucket
    - s3Client.PutObject(ctx, s3.PutObjectInput{

            Bucket: &bucketName
            Key: &key
            Body: &data
        }
### Handler Naming Conventions
- can be named anything
- referenced using the _HANDLER env variable
- if using a zip deployment package the executable must be named "bootstrap"
    - bootstrap file has to be at the root of the zip
- if using a contianer image to deploy you can name it anything

func handleRequest(ctx context.Context, even json.RawMessage) error

### Defining and Accessing the Input Event Object
- JSON is the most common format for input
- use Go struct to model the JSON
- pass the raw bytes of the json to the handler
    - deserialize it inside using Unmarshal

### Accessing the Lambda Context Object
ctx context.Context is optional
- required while 
    - loading default config from credential provider chain config.LoadDefaulConfig(ctx)
    - some SDK calls might need the context s3Client.PutObject(ctx, &s3.PutObjectInput

### Valid Signatures
- must be a function
- 0 to 2 args
    - if 2 then 1st must be context
- return 0 to 2 args
    - if 1 then it must be error
    - if 2 second must be error
### AWS SDK v2 for Go
AWS SDK for go v2 usually used to interface with other AWS resources
- config follows default credentail provider chain when called config.LoadDefaultConfig
    - the chain is 
        AWS access keys from a IAM user
        Federated web identity or OpenID Connect
        IAM Identitiy Center 
        Assume role credential provider
        Container credential provider (ECS) and (EKS)
        Process cred provider -external provider
        IMD5 cred provider - for code in EC2 containers
    - they attempt to renew creds automatically
    - multiple ways to assing setting values for each step in the chain

### Accessing Env Variables
- os.Getenv("VARIABLE_NAME")

### Using Global State
- declare using var outside of any fucntions to avoid creating multiple variables

### Best Practices
- use env varaibles to pass operational params like constants to function 
- Initialize connections and SDK clients outside the handler function and cache
  static assets in /tmp
- use keep alive to maintain persistent connections since lambda will purge them
  if idle
- consider seperate versions of functions per user if state is needed to be stored
  to avoid leaks


## Terraform Resource aws_lambda_function 
- Manage AWS lambda function
- create serveless functions that run code in response to events
```
 data "aws_iam_policy_document" "assume_role" {
     statement {
         effect = "Allow"

         principals {
             type = "Service"
             identifiers = ["lambda:amazonaws.com"]
         }

         actions = "sts:AssumeRole"
     }
} # create json policy

resource "aws_iam_role" "example" {
    name = "lambda_execution_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
} # this is the role

data "archive_file" "example" {
    type = "zip"
    source_file = "${path.module}/lambda/index.js"
    output_path = "${path.module}/lambda/function.zip"
} # package lambda function into zip

resource "aws_lambda_function" "example" {
    filename = data.archive_file.example.output_path
    function_name = "example_lambda_function"
    role = aws_iam_role.example.arn
    handler = "index.handler"
    source_code_hash = data.archive_file.example.output_base64sha256

    runtime = "nodejs20.x"

    enviornment {
        variable = {
            ENVIORNMENT = "prod"
            LOG_LEVEL = "info"
        }
    }
    tags = {
        Environment = "prod"
        Application = "example"
    }
}
```
- this sample file shows that to create a aws lambda using terraform
    - first create a policy
    - attach policy to the role
    - create a aws_lambda_function resource using a archivefile
        - filename
        - functionname
        - role
        - handler function name = name in file
        - source_code_hash = hash of the zip files base64sha256

