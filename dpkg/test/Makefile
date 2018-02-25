DEBIAN_ARCHIVE:=debian.tar.xz

PREPARE_DIR=dpkg_prepare
BUILD_DIR:=dpkg_build
PACKAGE_DIR:=package

PREPARE_MAKEFILE:=prepare.Makefile
BUILD_MAKEFILE:=build.Makefile

all: prepare

prepare:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PREPARE_DIR=$(PREPARE_DIR)

build: prepare
	$(eval SOURCE_ARCHIVE := $(shell ls *.orig.tar.xz))
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR) PACKAGE_DIR=$(PACKAGE_DIR)

clean:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PREPARE_DIR=$(PREPARE_DIR) clean
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR) PACKAGE_DIR=$(PACKAGE_DIR) clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: prepare build prepare-test build-test clean all list
