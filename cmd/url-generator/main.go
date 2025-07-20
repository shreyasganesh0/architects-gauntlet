package main

import (
	"log"
	"context"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/events"
)

func handlerFunc(ctx context.Context, r events.APIGatewayV2HTTPRequest) (string, error) {

	log.Printf("Recieved event from HTTP API Gateway: %+v\n", r); 
	
	return "Request recieved and logged", nil
}

func main() {
	lambda.Start(handlerFunc);
}
