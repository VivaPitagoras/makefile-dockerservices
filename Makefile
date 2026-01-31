# -----------------------
# Phony targets
# -----------------------
.PHONY: up down update liste prune dry-clean clean default 


# -----------------------
# Configuration variables
# -----------------------
# Root folder where all service directories are located
SERVICES_DIR := $(HOME)/services

# Compose file name (default: compose.yml, can be overridden)
COMPOSE_FILE ?= compose.yml

# Set your prefered editor
EDITOR ?= nano

# List of service names (subdirectories of SERVICES_DIR that contains a compose.yml)
SERVICES := $(notdir $(shell for d in $(SERVICES_DIR)/*; do \
	if [ -f "$$d/compose.yml" ]; then echo "$$d"; fi; done))



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
	cd $(SERVICES_DIR)/$* && docker compose down && docker compose up -d

# Open the compose file for a service in the nano editor
# Usage: make <service>.edit
%.edit:
	$(EDITOR) $(SERVICES_DIR)/$*/$(COMPOSE_FILE)

# Create/edit the .env file
# Usage: make <service>.env
%.env:
	$(EDITOR) $(SERVICES_DIR)/$*/.env

# Pull latest images and restart a service, then optionally prune unused Docker images
# Usage: make <service>.update
%.update:
	cd $(SERVICES_DIR)/$* && docker compose pull && docker compose up -d

# Create a new service directory, create an empty compose file, then open it
# Usage: make <service>.new
%.new:
	mkdir -p $(SERVICES_DIR)/$*
	#touch $(SERVICES_DIR)/$*/$(COMPOSE_FILE)
	$(MAKE) $*.edit

# Delete a service directory and all its contents (destructive!)
# Usage: make <service>.del
# Prompts for confirmation before deleting to prevent accidents
%.del:
	@read -p "Are you sure you want to delete $(SERVICES_DIR)/$* ? [y/N] " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		rm -rf $(SERVICES_DIR)/$*; \
		@echo "Deleted $(SERVICES_DIR)/$*"; \
	else \
		@echo "Aborted"; \
	fi


# -----------------------
# Aggregate targets for all services
# -----------------------

# Start all services
up: $(addsuffix .up,$(SERVICES))

# Stop all services
down: $(addsuffix .down,$(SERVICES))

# Reload all services
reload: $(addsuffix .reload,$(SERVICES))

# Update all services
update:
	@for s in $(SERVICES); do \
		$(MAKE) $$s.update; \
		echo " - $$s updated"; \
	done
	$(MAKE) prune

# List all services (folders that have a compose.yml inside)
list:
	@echo "Detected stacks:"
	@for s in $(SERVICES); do \
		echo " - $$s"; \
	done

# Delete unused images
prune:
	@read -p "Prune unused Docker images? [y/N] " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		docker image prune -a -f; \
	else \
		echo "Skipped pruning"; \
	fi
	@echo "Pruned unused Docker images";

# It will show all the non-stack folders that can be deleted
dry-clean:
	@echo "Folders that would be removed:"
	@for d in $(SERVICES_DIR)/*; do \
		if [ -d "$$d" ] && [ ! -f "$$d/$(COMPOSE_FILE)" ]; then \
			echo " - $$d"; \
		fi; \
	done

# Delete folders that are not a docker sevice
# Prompts for confirmation before deleting to prevent accidents
clean:
	@read -p "Are you sure you want to delete all folders without $(COMPOSE_FILE)? [y/N] " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		echo "Cleaning non-stack folders in $(SERVICES_DIR)..."; \
		for d in $(SERVICES_DIR)/*; do \
			if [ -d "$$d" ] && [ ! -f "$$d/$(COMPOSE_FILE)" ]; then \
				echo "Removing $$d (no $(COMPOSE_FILE))"; \
				rm -rf "$$d"; \
			fi; \
		done; \
	else \
		echo "Skipping cleaning"; \
	fi


# -----------------------
# Default target (safe behavior)
# -----------------------
# Running `make` with no arguments does nothing harmful
# Prints a helpful message listing available targets
default:
	@echo "No target specified. Nothing will happen."
	@echo "Available targets:"
	@echo "  up, down, reload, update, list, prune, dry-clean, clean"
	@echo "  <service>.[up|down|reload|edit|update|new|.env|del]"

# Set the default goal to `default`, so `make` alone is safe
.DEFAULT_GOAL := default
