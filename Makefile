SHELL=/bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --silent
###################################
include .env
LAST_ALPINE_VER != grep -oP '^FROM alpine:\K[\d\.]+' Dockerfile | head -1
###############################################
# https://github.com/commonmark/cmark/releases
###############################################
.PHONY: build
build:
	@#export DOCKER_BUILDKIT=1;
	@echo 'LAST ALPINE VERSION: $(LAST_ALPINE_VER) '
	@if [[ '$(LAST_ALPINE_VER)' = '$(FROM_ALPINE_TAG)' ]] ; then \
 echo 'FROM_ALPINE_TAG: $(FROM_ALPINE_TAG) ' ; else \
 echo ' - updating Dockerfile to Alpine tag: $(FROM_ALPINE_TAG) ' && \
 sed -i 's/alpine:$(LAST_ALPINE_VER)/alpine:$(FROM_ALPINE_TAG)/g' Dockerfile && \
 docker pull alpine:$(FROM_ALPINE_TAG) ; fi
	@docker buildx build --output "type=image,push=false" \
  --tag docker.pkg.github.com/$(REPO_OWNER)/$(REPO_NAME)/$(PKG_NAME):$(CMARK_VER) \
  --build-arg CMARK_VER='$(CMARK_VER)' \
.

.PHONY: run
run:
	@echo 'hello world' | docker run --rm --interactive \
  docker.pkg.github.com/$(REPO_OWNER)/$(REPO_NAME)/$(PKG_NAME):$(CMARK_VER)

