# Stage 0
# Build binary file
FROM golang:1.11.5-alpine as builder

ARG PROJECT_ORG=github.com/tef-novum
ARG PROJECT_NAME=beanstalkd_exporter
ARG PROJECT_SLUG=${PROJECT_ORG}/${PROJECT_NAME}
ARG PROJECT_TAG=metric_namespace

RUN apk add --update git make curl
RUN curl https://glide.sh/get | sh

RUN mkdir -p src/${PROJECT_SLUG}

WORKDIR /go/src/${PROJECT_ORG}
RUN git clone https://${PROJECT_SLUG}.git
WORKDIR  /go/src/${PROJECT_SLUG}
RUN git checkout ${PROJECT_TAG}
RUN glide init --non-interactive && glide install
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/${PROJECT_NAME} -v

# Stage 1
# Build actual docker image
FROM alpine:3.8
ARG PROJECT_SLUG=github.com/tef-novum/beanstalkd_exporter
LABEL maintainer="sre@tuenti.com"
COPY --from=builder /go/src/$PROJECT_SLUG/build/beanstalkd_exporter /beanstalkd_exporter
ENTRYPOINT ["/beanstalkd_exporter"]
