# - First Build
FROM golang:1.19-alpine as build

## Environment
WORKDIR /usr/local/go/src/ocr
ARG GITHUB_USER
ARG GITHUB_PASSWORD
ENV GOROOT /usr/local/go
ENV GOPRIVATE github.com/viven-inc

## Download Go Package 
RUN go env -w GO111MODULE=on 
RUN apk add git && \
    git config --global url."https://github.com/viven-inc".insteadof "ssh://git@github.com/viven-inc"
RUN echo "machine github.com login $GITHUB_USER password $GITHUB_PASSWORD" > ~/.netrc
COPY go.mod go.mod 
COPY go.sum go.sum
RUN go mod download

## Build ocr App and HealthCheck to Binary file.
COPY ./ /usr/local/go/src/ocr/
RUN go build -o app

# - Second Build
FROM alpine
WORKDIR /app/build 

## Copy Binary File from Build 
COPY --from=build /usr/local/go/src/ocr/app ./app 

RUN echo "$GITHUB_USER"
RUN echo "$GITHUB_PASSWORD"