# Variables
DOCKER=docker
IMAGE_NAME=port-api-dev
CONTAINER_NAME=port-api-container
OUTPUT_DIR=clients

# Help target to document other targets
.PHONY: help
help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Build Docker image
.PHONY: build
build: ## Build the Docker image
	$(DOCKER) build -t $(IMAGE_NAME) .

# Run Docker container and extract clients
.PHONY: run
run: build ## Run the Docker container and extract clients
	$(DOCKER) run --name $(CONTAINER_NAME) $(IMAGE_NAME)
	$(DOCKER) cp $(CONTAINER_NAME):/app/clients $(OUTPUT_DIR)
	$(DOCKER) rm $(CONTAINER_NAME)

# Clean up
.PHONY: clean
clean: ## Remove generated files and clean up
	$(DOCKER) rm -f $(CONTAINER_NAME)
	$(DOCKER) rmi -f $(IMAGE_NAME)
	rm -rf $(OUTPUT_DIR)
