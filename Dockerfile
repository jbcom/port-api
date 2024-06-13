# Stage 1: Base image with openapi-generator-cli
FROM openapitools/openapi-generator-cli as base

# Stage 2: Download and run the new OpenAPI generation script
FROM golang:latest AS downloader
WORKDIR /app
COPY scripts/generate_openapi_30_from_31.go /app/generate_openapi_30_from_31.go
RUN go mod init generate && go get github.com/getkin/kin-openapi/openapi3 && go build -o generate_openapi_30_from_31 generate_openapi_30_from_31.go

# Download the OpenAPI 3.1 specification
RUN curl -o input_openapi_31.json https://api.getport.io/json

# Run the script to generate OpenAPI 3.0.3 specification
RUN ./generate_openapi_30_from_31 input_openapi_31.json openapi.json

# Stage 3: Generate clients for JavaScript
FROM base AS javascript
WORKDIR /app
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/javascript.yaml /app/languages/javascript.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/javascript && \
    docker-entrypoint.sh generate -i /app/openapi.json -g javascript -o /app/clients/javascript

# Stage 4: Generate clients for TypeScript
FROM base AS typescript
WORKDIR /app
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/typescript-node.yaml /app/languages/typescript-node.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/typescript && \
    docker-entrypoint.sh generate -i /app/openapi.json -g typescript-node -o /app/clients/typescript

# Stage 5: Generate clients for Python
FROM python:latest AS python
WORKDIR /app
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/python.yaml /app/languages/python.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/python && \
    openapi-generator-cli generate -i /app/openapi.json -g python -o /app/clients/python

# Stage 6: Generate clients for Java
FROM base AS java
WORKDIR /app
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/java.yaml /app/languages/java.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/java && \
    docker-entrypoint.sh generate -i /app/openapi.json -g java -o /app/clients/java

# Stage 7: Generate clients for Go
FROM golang:latest AS go
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-cli-generator
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/go.yaml /app/languages/go.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
ENV PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_HOME="/opt/java/openjdk"
RUN mkdir -p /app/clients/go && \
    openapi-cli-generator generate -i /app/openapi.json -g go -o /app/clients/go

# Stage 8: Generate clients for Bash
FROM base AS bash
WORKDIR /app
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/bash.yaml /app/languages/bash.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
RUN mkdir -p /app/clients/bash && \
    docker-entrypoint.sh generate -i /app/openapi.json -g bash -o /app/clients/bash

# Stage 9: Generate clients for R
FROM r-base:latest AS r
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-cli-generator
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/r.yaml /app/languages/r.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
ENV PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_HOME="/opt/java/openjdk"
RUN mkdir -p /app/clients/r && \
    openapi-cli-generator generate -i /app/openapi.json -g r -o /app/clients/r

# Stage 10: Generate clients for Ruby
FROM ruby:latest AS ruby
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-cli-generator
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/ruby.yaml /app/languages/ruby.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
ENV PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_HOME="/opt/java/openjdk"
RUN mkdir -p /app/clients/ruby && \
    openapi-cli-generator generate -i /app/openapi.json -g ruby -o /app/clients/ruby

# Stage 11: Generate clients for PHP
FROM php:latest AS php
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-cli-generator
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/php.yaml /app/languages/php.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
ENV PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_HOME="/opt/java/openjdk"
RUN mkdir -p /app/clients/php && \
    openapi-cli-generator generate -i /app/openapi.json -g php -o /app/clients/php

# Stage 12: Generate clients for Rust
FROM rust:latest AS rust
WORKDIR /app
COPY --from=base /opt/java /opt/java
COPY --from=base /opt/openapi-generator /opt/openapi-generator
COPY --from=base /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-cli-generator
COPY --from=downloader /app/openapi.json /app/openapi.json
COPY languages/rust.yaml /app/languages/rust.yaml
COPY languages/shared/common.yaml /app/languages/shared/common.yaml
ENV PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_HOME="/opt/java/openjdk"
RUN mkdir -p /app/clients/rust && \
    openapi-cli-generator generate -i /app/openapi.json -g rust -o /app/clients/rust

# Stage 13: Final stage to gather all clients
FROM base AS final
WORKDIR /app
COPY --from=javascript /app/clients/javascript /app/clients/javascript
COPY --from=typescript /app/clients/typescript /app/clients/typescript
COPY --from=python /app/clients/python /app/clients/python
COPY --from=java /app/clients/java /app/clients/java
COPY --from=go /app/clients/go /app/clients/go
COPY --from=bash /app/clients/bash /app/clients/bash
COPY --from=r /app/clients/r /app/clients/r
COPY --from=ruby /app/clients/ruby /app/clients/ruby
COPY --from=php /app/clients/php /app/clients/php
COPY --from=rust /app/clients/rust /app/clients/rust

CMD ["bash"]
