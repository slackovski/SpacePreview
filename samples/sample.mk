# Common Makefile fragment (.mk)
# Include with: include scripts/common.mk

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Detect OS
OS := $(shell uname -s)
ifeq ($(OS),Darwin)
    SED := gsed
    OPEN := open
else
    SED := sed
    OPEN := xdg-open
endif

# Colors
RED   := \033[0;31m
GREEN := \033[0;32m
RESET := \033[0m

define log_ok
	@printf "$(GREEN)✓ $(1)$(RESET)\n"
endef

define log_err
	@printf "$(RED)✗ $(1)$(RESET)\n"
endef

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
