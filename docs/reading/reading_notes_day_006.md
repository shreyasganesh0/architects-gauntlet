# Presigned S3 URLs

## Go Lib for Presigned URLS
github.com/aws/aws-sdk-go-v2/config
- Per usual we get a config using LoadDefaultConfig(ctx)
- we use the config to get a s3 client
    - s3.NewFromConfig(cfg)

github.com/aws/aws-sdk-go-v2/service
- We create a new PresignClient
    - s3.NewPresignClient(client, func(options *s3.PresignOptions) {
        options.Expires = 300 * time.Second
    }
- use the PresignClient to PresignPutObject(ctx, &params)
    - params can be anything usually a s3.PutObjectInput
    - gives us a v4.PresignedHTTPRequest
        - we can parse this request into a httpRequest 
            - to upload an image we set the http req param like header and body
            - make the client send this request to the url we got from the presigned 
              request
            - while doing this the content length member is set
        - once its sent we can check for the response to see if it was uploaded 
