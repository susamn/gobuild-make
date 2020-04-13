NAME := gobuild-make
DESC := Your build needs for golang 
PREFIX ?= usr/local
COMMIT_SHA := $(shell git rev-parse --short HEAD)
GOVERSION := $(shell go version)
BUILDTIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILDER := $(shell echo "`git config user.name` <`git config user.email`>")
PROJECT_URL := "https://github.com/susamn/gobuild-make"
GO111MODULES=on
LDFLAGS := -X 'main.version=$(COMMIT_SHA)' \
		   -X 'main.buildTime=$(BUILDTIME)' \
		   -X 'main.builder=$(BUILDER)' \
		   -X 'main.goversion=$(GOVERSION)'


.PHONY: fmt
## fmt: Formats sources
fmt:
	@echo "Formatting..."
	go fmt ./... -v

.PHONY: build
## build: Builds locally, invokes build-local
build: build-local

.PHONY: build-docker
## build-docker: Builds docker image
build-docker: build-linux
	@echo "Building docker image..."
	docker build -t ${NAME}:${COMMIT_SHA} --build-arg APP_NAME=${NAME} .

.PHONY: build-local
## build-local: Builds according to current machine architecture
build-local: clean
	@echo "Building for local target"
	mkdir -p build/local/bin && CGO_ENABLED=0 \
	go build -ldflags "$(LDFLAGS)" -o build/local/bin/${NAME} main.go

.PHONY: build-linux
## build-linux: Builds according to linux-amd64 architecture
build-linux: clean
	@echo "Building for linux target"
	mkdir -p build/linux/bin && \
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
	go build -ldflags "$(LDFLAGS)" -o build/linux/bin/${NAME} main.go

.PHONY: run
## run: runs go run main.go
run:
	go run -race main.go

.PHONY: clean
## clean: cleans the binary
clean:
	@echo "Cleaning"
	@go clean
	rm -rf build

.PHONY: test
## test: runs go test with default values
test:
	go test -v -count=1 -race ./...

.PHONY: setup
## setup: setup go modules
setup:
	@go mod init \
		&& go mod tidy \
		&& go mod vendor

.PHONY: docker-push
## docker-push: pushes the stringifier docker image to registry
docker-push: build-docker
	docker push ${REGISTRY}/${NAME}:${COMMIT_SHA}

.PHONY: help
## help: Prints this help message
help:
	@echo "Usage: \n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column
