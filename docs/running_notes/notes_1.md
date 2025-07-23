# AWS Cognito

## Instructions to setup test cognito user for JWT

```
aws cognito-idp sign-up --client-id "6igicend96avn3a2nq3to50h0q" --username "test@archgaunt.com" --password "TestingPassword1*"

 aws cognito-idp admin-confirm-sign-up --user-pool-id "us-east-1_o1mxk2LRF" --username "test@archgaunt.com"

# get the tokenId
 aws cognito-idp admin-initiate-auth --user-pool-id "us-east-1_o1mxk2LRF" --client-id "6igicend96avn3a2nq3to50h0q" --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME="test@archgaunt.com",PASSWORD="TestingPassword1*"
 ```
