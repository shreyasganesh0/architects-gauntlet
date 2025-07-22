package main

import (
	"os"
	"fmt"
	"log"
	"time"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/config"
)

type SuccessResponse struct {
	URL string `json:"url"`
}

func handlerFunc(ctx context.Context, r events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	log.Printf("Recieved event from HTTP API Gateway: %+v\n", r); 
	err_resp := events.APIGatewayV2HTTPResponse{

			StatusCode: 500,

			Headers: map[string]string{
				"Content-Type": "plain/text",
			},

			Body: "server error",
	}

	cfg, err := config.LoadDefaultConfig(context.TODO());
	if err != nil {

		log.Println("Failed to load config")
		return err_resp, err;
	}
	
	s3Client := s3.NewFromConfig(cfg)

	presignClient := s3.NewPresignClient(s3Client, func(options *s3.PresignOptions) {

		options.Expires = 300 * time.Second
	});

	//build bucket file path
	fileName := r.QueryStringParameters["fileName"]
	if fileName == "" {

		return err_resp, fmt.Errorf("Failed to get filename from request")
	}

	userId := r.RequestContext.Authorizer.JWT.Claims["sub"]
	if userId == "" {
		
		return err_resp, fmt.Errorf("Failed to get sub from request")
	}
	// -----

	//Create bucket params and put object
	s3Key := fmt.Sprintf("uploads/%s/%s", userId, fileName)
	bucket := os.Getenv("UPLOAD_BUCKET") 
	if bucket == "" {

		return err_resp, fmt.Errorf("Failed to get bucket name from env")
	}
	//expiry := 15 * time.Minute + time.Now;

	params := &s3.PutObjectInput {
		Bucket:  &bucket,

		Key:     &s3Key,
	}
	presignReq, err := presignClient.PresignPutObject(context.TODO(), params); 
	// ----

	response := SuccessResponse {
		URL: presignReq.URL, 
	}

	resp_byts, err := json.Marshal(response)
	if err != nil {

		return err_resp, err;
	}

	return events.APIGatewayV2HTTPResponse {

		StatusCode: 200,

		Headers: map[string]string{
			"Content-Type": "application/json",
		},

		Body: string(resp_byts),

	}, nil
}

func main() {
	lambda.Start(handlerFunc);
}
