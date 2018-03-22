MAKEFILE_PATH:= $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_ROOT:= $(dir $(MAKEFILE_PATH))

PRE_COMMIT:=$(shell command -v pre-commit 2>/dev/null)

ifndef PRE_COMMIT
$(error pre-commit is not installed. Please install pre-commit first - http://pre-commit.com/#install)
endif

.DEFAULT_GOAL := help
.PHONY: help
help:
    @awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort -k2,2

.PHONY: dev-init
dev-init: tf_prerequisites tf_clean ## Initiate development tools
    $(info ... pre-commit hooks installing)
    @$(PRE_COMMIT) install
