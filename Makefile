
BINARY_NAME=url-generator
BINARY_PATH=bin/$(BINARY_PATH)
LAMBDA_PATH=bootstrap
LAMBDA_ZIP_PATH=aws/lambda

.PHONY: all build run

all: build

build:
	@echo "Building Binary..."
	@go build ./cmd/$(BINARY_NAME)/main.go -o $(BINARY_PATH)

run:
	@echo "Running..."
	@go run cmd/$(BINARY_NAME)/main.go

lambda:
	@echo "Building binary for linux x64 lambda deployment..."
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(LAMBDA_PATH) ./cmd/$(BINARY_NAME)/main.go
	@zip $(LAMBDA_ZIP_PATH)/function.zip $(LAMBDA_PATH)
	@echo "Zipped function to $(LAMBDA_ZIP_PATH)"

clean:
	@rm aws/lambda/*.zip
	@rm bin/* bootstrap
