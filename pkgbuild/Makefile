CURDIR:=$(shell pwd)

PROJECT_NAME?=exec-helper
PREFIX?=$(CURDIR)/package
SOURCE_DIR?=$(CURDIR)/../exec-helper
PKG_IN?=$(CURDIR)/PKGBUILD.in

BUILD_DIR:=$(CURDIR)/build_package

all: source

# Stable version
prepare:
	$(MAKE) generate TARGET=prepare

source: prepare

build:
	$(MAKE) generate TARGET=build

install: source
	$(MAKE) generate TARGET=install

# Utility target
generate:
	$(MAKE) --directory pkgbuild-generator PROJECT_NAME=$(PROJECT_NAME) "SOURCE_DIR=$(SOURCE_DIR)" "PKG_IN=$(PKG_IN)" "GITCHANGELOG_RC=$(SOURCE_DIR)/.gitchangelog.rc" "BUILD_DIR=$(BUILD_DIR)" "PREFIX=$(PREFIX)" $(TARGET)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PREFIX)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: clean list generate all prepare source build install
