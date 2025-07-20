package main

import (
	"log"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/events"
)

type SuccessResponse struct {
	URL string `json:"url"`
}

func handlerFunc(ctx context.Context, r events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	log.Printf("Recieved event from HTTP API Gateway: %+v\n", r); 


	response := SuccessResponse {
		URL: "https://sample.com/example",
	}

	resp_byts, err := json.Marshal(response)
	if err != nil {

		return events.APIGatewayV2HTTPResponse{

			StatusCode: 500,

			Headers: map[string]string{
				"Content-Type": "plain/text",
			},

			Body: "server error",
		}, err
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
