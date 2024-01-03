# syntax=docker/dockerfile:1

# Build the application from source
FROM golang:latest AS build-stage

WORKDIR /go-app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-goApp


# Deploy the application binary into a lean image
FROM  alpine:latest AS build-release-stage

WORKDIR /go-app
COPY templates ./templates/
RUN mkdir ./files

COPY --from=build-stage /docker-goApp ./docker-goApp

EXPOSE 9110 80

USER root:root
ARG LOKI_URL=null
ENV LOKI_URL=${LOKI_URL}

ENTRYPOINT ./docker-goApp -html ./files/index.html -l $LOKI_URL
