ALL_PACKAGES=$(shell go list ./... | grep -v "vendor")

#Go parameters
GOCMD=go
GOINSTALL=$(GOCMD) install
GOTEST=$(GOCMD) test
DEP=dep
.PHONY : all install vet fmt test lint build

all: build test fmt lint vet

setup: install
	@go get -u golang.org/x/lint/golint

install: 
	@$(DEP) ensure

build: 
	@go build ./...

test: build
	@$(GOTEST) -v $(ALL_PACKAGES)

vet:
	@go vet $(ALL_PACKAGES)

fmt:
	@go fmt $(ALL_PACKAGES)

lint:
	@golint -set_exit_status $(ALL_PACKAGES)

precommit: build test fmt lint vet

test-coverage:
	@echo "mode: count" > coverage-all.out

	$(foreach pkg, $(ALL_PACKAGES),\
	go test -coverprofile=coverage.out -covermode=count $(pkg);\
	tail -n +2 coverage.out >> coverage-all.out;)
	@go tool cover -html=coverage-all.out -o coverage.html