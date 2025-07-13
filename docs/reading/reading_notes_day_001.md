# AWS Fundamentals

## Pre-Signed URLS
- Pre signed URLS are used for downloading and uploading objects to S3
- grants time-limited access to objects without changing policy
- the url creds belong to the user who generates it
- Useful for letting others upload a object to the S3 bucket
    - the third party will not need credentials to perform the upload
    - if the same key as the one specified by the URL exists in the bucket
      it will replace the existing object with the uploaded object.

- reusable until expiry

- Key Creation
    - security credentials
    - Amazon S3 bucket
    - object key (downloads: object key from S3 bucket
                  uploads: file name to upload)
    - HTTP method (GET -> downloading, PUT -> uploading, HEAD -> metadata)
    - expiration time interval

- Presigned URLS dont support data integrity checksum algos (CRC32, CRC32C, SHA1, SHA256)
    - for integrity need to provide a MD5 digest of the object while uploading

- Creation of Presigned URLs
    - Must be created by someone who has permissions on the object
      for the type of action being created on the URL
    - Access level
        - IAM instance profile - 6 hours
        - AWS Security Token Service - 36 hours or duration of the 
          credential service whichever ends first
        - IAM user - upto 7 days with AWS signature v4
          delegate the IAM user creds to the method used to create the 
          url

- Expiration time
    - console created keys have 1 minute to 12 hours
    - CLI and SDK created expiry can be as long as 7 days
    - URLs expire when the creds of the temporary cred used to create it 
      expires even if the expiry time of the URL is longer.
    - time is checked at the time of the HTTP request so it continues
      if the request was made right before the expiry

- URL permission
    - limited by the permissions of the user that created it.
    - to enforce pre signed url auth behaviour using AWS Signature Version 4(SigV4)
        - bucket policy can be set to deny urls based on signature age
            "Effect": "Deny",
            ...
            "Resource": "arn:aws:s3::s3_bucket_name/*";
            "Condition": {
                "NumericGreaterThan": {
                    "s3:signatureAge": 600000
                }
    - network path restriction
        - can be done using AWS identity and IAM policies
        - policy can be set on the IAM prinicpal that makes the call 
          or the S3 bucket or both.
        - the user who makes the request must be from a specified network
        - this will apply to all requests not just presigned URLs
        - aws:SourceIp for public endpoints and aws:SourceVPC or aws:SourceVpce
        "Condition": {
            "NotIpAddressIfExists": {"aws:SourceIp": "IP address range"},
            "BoolIfExists": {"aws:ViaAWSService": "false"}
        }

## API Gateway JWT Authorizers
- JSON Web Tokens can be part of OpenID Connect and OAuth2.0 framworks to 
  restrict client access to APIS
- Set JWT authorizer on a route of the API.
- API Gateway validates the JWT that clients submit.
-   - denies or allows based on the requests based on token validation
    - can also deny or allow based on scopes in the token.
        - if scopes for a route are defined atleast one of htem but be 
          included in the token

- JWT Authorizer
    - Check IdentitySource for token
    - Decode
    - Check the tokens algorithm and signture using the public key fetched from 
      issuers jwks_uri
        - only RSA based algos are supported
        - can cache public key for 2 hours (important when rotating keys 
          to allow both to be valid for that period)
    - Validate Claims
        - kid : token must have a header claim that matches key in the jwks_uri 
        - iss : must match issuer configured for authorizer
        - aud : one of the audience entries configured must be matched
                validates client_id if aud is not present
        - exp : must be after the current time in UTC
        - nbf : musb be before the current time in UTC
        - iat : must be before the current tiem in UTC
        - scope : one of the scopes in authoriationScopes must be included in token
    - backend resources can access the claims

## IAM JSON Policy
- JSON policy docs made up of elements
- order of elements doesnt matter
- Condtion elements are optional
- Some elements are mutually exclusive 
    - if you use one cant use the other eg. Action NotAction
- IAM can perform policy validation on JSON policy for effective policy creation
    - IAM Access Analyzer can make suggestions to policies
- List of Policy elements
    - Version
        - defines the version of the policy language
        - "Version": "2012-10-17"
        - "Version": "2008-10-17"
        - these are the two versions supported
    - Id
        - optinal identifier for the policy 
        - only allowed in resource based policies not identity based ones
        - usually UUID or GUID
    - Statement
        - "Statement": [ {},{},{}]
        - main element of the policy
        - used to contain subcategories of differnt resources and effects on them
    - Sid
        - optional statement id
        - present per statement {} in the Statement [] array
    - Effect
        - specify is the statement results in allow or deny
        - valid values are Allow , Deny
    - Prinicipal
        - used in resource based JSON
        - specify the principal that is allowed or denied access to the resource
        - example IAM resource based Principal used to say who can assume the role
          using id of the accounnt
    - NotPrincipal
        - Deny all but the one present in NonPrincipal
        - AWS STS federeated user prinicpal, IAM role, assumed role session
          AWS account, AWS service or any other principal type
        - Not recommended to be used just use aws:PrinicipalArn context key with
          ARN condition operators
    - Action
        - Describes actions that are allowed or denied
        - Must be included in a statement
        - Each service has its own set of actions for tasks
    - NotAction
        - Opposite of Action denies all but the Action
    - Resource
        - defines objects that the statement applies to
    - NotResource
        - opposite of Resource applies to nothing but that
    - Condition
        - Condition: {"{condition operator}": "{conditon-key}" : "{condition-value}"}}
        - optional element
        - build expressions to match context keys and values in the policy against 
          keys and values in the request context
    - Variables and tags
        - ${variable_name}
        -useful for reusable policies that extract values dynamically
        - ${aws:PrincipalTag/owner}
        - keys are case insensitive
    - data types
        - works with all JSON datatypes
        - Strings
        - Integer
        - Float
        - Boolean
        - Null
        - Date
        - IpAddress //RFC 4632
        - List //Array
        - Object

