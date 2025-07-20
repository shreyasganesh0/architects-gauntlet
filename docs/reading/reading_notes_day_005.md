# AWS Lambda Messages APIGatewayV2

## Structure
github.com/aws/aws-lambda-go/events

- the entry path is usally a request sent to the APIGatewayV2HTTPRequest
- the lambda functions gets events as its inputs
    - these events can be sent via different triggers like s3, sqs, apigateway
- for our intents and purposes we will be getting requests from the api gateway trigger
- works in a similar fashion the the http request and response model
    - its as if we are writing a http server handler and the lambda function
      acts like the http server
    - we parse the request and then send a response
