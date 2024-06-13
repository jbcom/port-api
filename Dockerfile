# Stage 1: Base image with openapi-generator-cli
FROM openapitools/openapi-generator-cli as base

# Stage 2: Download and run the new OpenAPI generation script
FROM golang:latest AS downloader
WORKDIR /app
COPY scripts/generate_openapi_30_from_31.go /app/generate_openapi_30_from_31.go
RUN go mod init generate && go get github.com/getkin/kin-openapi/openapi3 && go build -o generate_openapi_30_from_31 generate_openapi_30_from_31.go
RUN ./generate_openapi_30_from_31 input_openapi_31.json output_openapi_30.json

# Stage 3: Generate clients for JavaScript
FROM base AS javascript
WORKDIR /app
COPY --from=downloader /app/output_openapi_30.json /app/openapi.json
COPY languages/javascript.yaml /app/languages/javascript.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/javascript && \
    docker-entrypoint.sh generate -i /app/openapi.json -g javascript -o /app/clients/javascript

# Stage 4: Generate clients for TypeScript
FROM base AS typescript
WORKDIR /app
COPY --from=downloader /app/output_openapi_30.json /app/openapi.json
COPY languages/typescript-node.yaml /app/languages/typescript-node.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/typescript && \
    docker-entrypoint.sh generate -i /app/openapi.json -g typescript-node -o /app/clients/typescript

# Stage 5: Generate clients for Python
FROM python:latest AS python
WORKDIR /app
COPY --from=downloader /app/output_openapi_30.json /app/openapi.json
COPY languages/python.yaml /app/languages/python.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/python && \
    openapi-generator-cli generate -i /app/openapi.json -g python -o /app/clients/python

# Stage 6: Generate clients for Java
FROM base AS java
WORKDIR /app
COPY --from=downloader /app/output_openapi_30.json /app/openapi.json
COPY languages/java.yaml /app/languages/java.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/java && \
    docker-entrypoint.sh generate -i /app/openapi.json -g java -o /app/clients/java

# Stage 7: Generate clients for Go
FROM golang:latest AS go
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /
