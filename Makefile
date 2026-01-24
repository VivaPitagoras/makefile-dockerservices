# -----------------------
# Phony targets
# -----------------------
.PHONY: up down update default

# -----------------------
# Configuration variables
# -----------------------
# Root folder where all service directories are located
SERVICES_DIR := $(HOME)/services

# List of service names (subdirectories of SERVICES_DIR)
SERVICES := $(notdir $(wildcard $(SERVICES_DIR)/*))

# Compose file name (default: compose.yml, can be overridden)
COMPOSE_FILE ?= compose.yml

# -----------------------
# Pattern rules for individual services
# -----------------------

# Start a service in detached mode
# Usage: make <service>.up
%.up:
	cd $(SERVICES_DIR)/$* && docker compose up -d

# Stop a service
# Usage: make <service>.down
%.down:
	cd $(SERVICES_DIR)/$* && docker compose down

# Reload a service (stop then start)
# Usage: make <service>.reload
%.reload:
	cd $(SERVICES_DIR)/$* && docker compose down
	cd $(SERVICES_DIR)/$* && docker compose up -d

# Open the compose file for a service in the nano editor
# Usage: make <service>.edit
%.edit:
	nano $(SERVICES_DIR)/$*/$(COMPOSE_FILE)

# Pull latest images and restart a service, then optionally prune unused Docker images
# Usage: make <service>.update
%.update:
	cd $(SERVICES_DIR)/$* && docker compose pull
	cd $(SERVICES_DIR)/$* && docker compose up -d
	@read -p "Prune unused Docker images? [y/N] " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		docker image prune -a -f; \
		echo "Pruned unused Docker images"; \
	else \
		echo "Skipped pruning"; \
	fi

# Create a new service directory, create an empty compose file, then open it
# Usage: make <service>.new
%.new:
	mkdir -p $(SERVICES_DIR)/$*
	touch $(SERVICES_DIR)/$*/$(COMPOSE_FILE)
	$(MAKE) $*.edit

# Delete a service directory and all its contents (destructive!)
# Usage: make <service>.del
# Prompts for confirmation before deleting to prevent accidents
%.del:
	@read -p "Are you sure you want to delete $(SERVICES_DIR)/$* ? [y/N] " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		rm -rf $(SERVICES_DIR)/$*; \
		echo "Deleted $(SERVICES_DIR)/$*"; \
		else \
		echo "Aborted"; \
	fi

# -----------------------
# Aggregate targets for all services
# -----------------------

# Start all services
up: $(addsuffix .up,$(SERVICES))

# Stop all services
down: $(addsuffix .down,$(SERVICES))

# Update all services
update: $(addsuffix .update,$(SERVICES))

# -----------------------
# Default target (safe behavior)
# -----------------------
# Running `make` with no arguments does nothing harmful
# Prints a helpful message listing available targets
default:
	@echo "No target specified. Nothing will happen."
	@echo "Available targets:"
	@echo "  up, down, update"
	@echo "  <service>.[up|down|reload|edit|update|new|del]"

# Set the default goal to `default`, so `make` alone is safe
.DEFAULT_GOAL := default
