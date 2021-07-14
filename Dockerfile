ARG BUILDPLATFORM="linux/amd64"
ARG BUILDERIMAGE="golang:1.16"
# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
ARG BASEIMAGE="gcr.io/distroless/static:nonroot-amd64"

FROM --platform=$BUILDPLATFORM $BUILDERIMAGE as builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT}

WORKDIR /go/src/github.com/helayoty/canary-demo

COPY cmd/main.go main.go

COPY go.mod .
COPY go.sum .

RUN go mod download
RUN go build -o ./bin/canary-demo main.go

FROM $BASEIMAGE

WORKDIR /

COPY  --from=builder /go/src/github.com/helayoty/canary-demo/bin/canary-demo /canary-demo
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/canary-demo"]