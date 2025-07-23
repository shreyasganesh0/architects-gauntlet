# JWT Authorization of API Gateway

## Terraform
```
resource aws_apigatewayv2_authorizer" "example" {
    api_id = aws_apigatewayv2_api.example.id
    authorizer_type = "REQUEST"
    authorizer_uri = aws_lambda_function.example.invoke_arn
    identity_source = ["$request.header.Authorization"]
    name = "my-autho"
    authorizer_payload_format_version = "2.0"
    jwt_configuration {
        audience
        issuer
    }
}
```
- authorizer type JWT 
    - uses jwt_configuration
    - need to specify audience and issuer claims in the jwt
        - audience: recipients of the JWT
        - issuer: domain of identity provider
            - usually a cognito identity provider in AWS

## Cognito
- using the CLI to configure user pools and authenticate users
- API, OIDC and managed login pages
    - user pools can do auth using
        - by acting as relying parties to exeternal IDP(identity providers)
        - by acting as a IDP to apps that implment OICD SDKs
        - by acting as issuers of JWTs in API methods that are a part of the SDK
