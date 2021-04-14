VERSION ?= v0.0.1
BUNDLE_IMG ?= quay.io/skupper/skupper-operator-bundle:$(VERSION)
INDEX_IMG ?= quay.io/skupper/skupper-operator-index:$(VERSION)
OPM := $(or $(shell which opm 2> /dev/null),./opm)
CONTAINER_TOOL := podman

all: index-build

.PHONY: bundle-build ## Build the bundle image.
bundle-build:
	@echo Building bundle image
	$(CONTAINER_TOOL) build -f bundle.Dockerfile -t $(BUNDLE_IMG) .
	$(CONTAINER_TOOL) push $(BUNDLE_IMG)

.PHONY: opm-download
opm-download:
	@echo Checking if $(OPM) is available
ifeq (,$(wildcard $(OPM)))
	wget --quiet https://github.com/operator-framework/operator-registry/releases/latest/download/linux-amd64-opm -O ./opm && chmod +x ./opm
endif

.PHONY: index-build ## Build the index image.
index-build: bundle-build opm-download
	@echo Building index image
	$(info Using OPM Tool: $(OPM))
	$(OPM) index add --bundles $(BUNDLE_IMG) --tag $(INDEX_IMG)

.PHONY: push ## Push the image to quay
	$(CONTAINER_TOOL) push $(INDEX_IMG)

