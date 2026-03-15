.PHONY: build install clean test

# Variables
BIN_NAME := spacepreview
VERSION := 1.0.0
BUILD_FLAGS := -ldflags "-X main.Version=$(VERSION)"

build:
	@echo "Building $(BIN_NAME)..."
	go build $(BUILD_FLAGS) -o bin/$(BIN_NAME) ./cmd/main.go

install: build
	@echo "Installing $(BIN_NAME)..."
	cp bin/$(BIN_NAME) /usr/local/bin/

test:
	@echo "Running tests..."
	go test -v ./...

clean:
	@echo "Cleaning up..."
	rm -rf bin/ dist/
