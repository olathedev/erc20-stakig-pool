# Makefile for Foundry Deployment

# Variables
FOUNDRY_CMD = forge
DEPLOY_SCRIPT = scripts/deploy.s.sol
NETWORK = mainnet

# Default target
all: build deploy

# Build the project
build:
	$(FOUNDRY_CMD) build

# Deploy the project
deploy:
	$(FOUNDRY_CMD) script $(DEPLOY_SCRIPT) --broadcast --verify --network $(NETWORK)

# Clean the project
clean:
	$(FOUNDRY_CMD) clean

.PHONY: all build deploy clean