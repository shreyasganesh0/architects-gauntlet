# Terraform APIV2 Gateway Resource

## aws_apigatewayv2_api
- For http apis
```
resource "aws_apigatewayv2_api" "example" {
    name  = "http_protocol"
    protocol_type = "HTTP"
}
```
- arguments supported
    - body - OpenAPI specification
        - defines a set of routes 

## aws_apigatewayv2_integration
- integrate to different resources like Lambda
```
resource "aws_apigatewayv2_integration" "example" {
    api_id = aws_apigatewayv2_example.id
    integration_type = "AWS_PROXY"

    connection_type = "INTERNET"
    content_handling_strategy = "CONVERT_TO_TEXT"
    integration_method = "POST"
    integration_uri = aws_lambda_function.example.invoke_arn
    passthrough_behaviour = "WHEN_NO_MATCH"
}
```

## aws_apigatewayv2_route
- manage the route in the api gateway v2
```
resource "aws_apigatewayv2_route" "example" {

    api_id = aws_apigatewayv2_api.example.id
    route_key = "ANY /resource/path"

    target = "integrations/${aws_apigatewayv2_integration.example.id}"
}
```
- the route key is used to rout messages based on muxing the resource path and method
- target points to the integration resource id

## Lambda Enviorment Variables
- update behaviour without udpating code
- Using the SDK
    - UpdateFunctionConfiguration
    - GetFunctionConfiguration
    - CreateFunction
