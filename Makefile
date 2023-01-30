#!/bin/bash
IMAGE_NAME ?= feisky/winservercore
TAG ?= v1.0
BASE ?= mcr.microsoft.com/windows/servercore
# OSVERSIONS := 1809 1903 1909 2004 20H2 ltsc2022
OSVERSIONS := 1809 ltsc2022
IMAGE := $(IMAGE_NAME):$(TAG)
ALL_IMAGES = $(foreach VER, ${OSVERSIONS}, $(IMAGE)-${VER})

export DOCKER_CLI_EXPERIMENTAL=enabled

.PHONY: all
all: build

buildx-setup:
	docker buildx inspect img-builder > /dev/null 2>&1 || docker buildx create --name img-builder --use
	# enable qemu for arm64 build
	# https://github.com/docker/buildx/issues/464#issuecomment-741507760
	docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-aarch64
	docker run --rm --privileged tonistiigi/binfmt --install all

build:
	# For Linux, it is simpler:
	# docker buildx build --platform linux/amd64,linux/arm64 --push --pull -t $(IMAGE) .
	# For Windows, we need to build each version separately below:
	for VERSION in $(OSVERSIONS); do \
		docker buildx build --platform windows/amd64 --push --pull --build-arg WINBASE=${BASE}:$${VERSION} -t "$(IMAGE)-$${VERSION}" .; \
	done
	docker manifest create --amend $(IMAGE) $(ALL_IMAGES)
	for VERSION in $(OSVERSIONS); do \
		full_version=`docker manifest inspect ${BASE}:$${VERSION} | jq -r '.manifests[0].platform["os.version"]'`; \
		docker manifest annotate --os-version $${full_version} --os windows --arch amd64 $(IMAGE) "$(IMAGE)-$${VERSION}"; \
	done
	docker manifest push --purge $(IMAGE)
