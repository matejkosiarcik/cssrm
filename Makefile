# This Makefile does not contain any build steps
# It only groups scripts to use in project

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/sh  # for compatibility (mainly with redhat distros)
.SHELLFLAGS := -ec
PROJECT_DIR := $(realpath $(dir $(abspath $(MAKEFILE_LIST))))

.POSIX:

.DEFAULT: all
.PHONY: all
all: bootstrap build

.PHONY: bootstrap
bootstrap:
	npm ci

.PHONY: lint
lint:
	npm run lint

.PHONY: fmt
fmt:
	npm run fmt

.PHONY: build
build:
	npm run build

.PHONY: test
test:
	npm test
