PROJECT_NAME:=exec-helper

SOURCE_DIR:=../$(PROJECT_NAME)
VERSION:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
SHORT_VERSION=$(shell echo $(VERSION) | sed 's@\(.*\)-[0-9a-z]*$$@\1@g')
DISTRIBUTION:=$(shell lsb_release --codename --short)

BUILD_DIR:=build
PACKAGE_DIR:=package

DEBIAN_ARCHIVE=debian.tar.xz
SOURCE_ARCHIVE:=$(PROJECT_NAME)_$(SHORT_VERSION).orig.tar.xz
SOURCE_FILES:=CMakeLists.txt
SOURCE_CHANGES_FILE:=$(PROJECT_NAME)_$(VERSION)_source.changes

PREPARE_MAKEFILE:=prepare.Makefile
SOURCE_MAKEFILE:=source.Makefile
BUILD_MAKEFILE:=build.Makefile

all: prepare

prepare:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/prepare DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_DIR=$(SOURCE_DIR) SOURCE_FILES=$(SOURCE_FILES) VERSION=$(VERSION) DISTRIBUTION=$(DISTRIBUTION) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE)

source: prepare
	$(MAKE) --makefile=$(SOURCE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/source PACKAGE_DIR=$(PACKAGE_DIR)/source DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_FILES=$(SOURCE_FILES) CHANGES_FILE=$(SOURCE_CHANGES_FILE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE)

build: prepare
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR)/binary PACKAGE_DIR=$(PACKAGE_DIR)/binary

prepare-test:
	$(MAKE) --directory test prepare

build-test:
	$(MAKE) --directory test build

clean:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/prepare DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_DIR=$(SOURCE_DIR) SOURCE_FILES=$(SOURCE_FILES) VERSION=$(VERSION) DISTRIBUTION=$(DISTRIBUTION) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) clean
	$(MAKE) --makefile=$(SOURCE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/source PACKAGE_DIR=$(PACKAGE_DIR)/source DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_FILES=$(SOURCE_FILES) CHANGES_FILE=$(SOURCE_CHANGES_FILE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) clean
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR)/binary PACKAGE_DIR=$(PACKAGE_DIR)/binary clean
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

	$(MAKE) --directory test clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: prepare source build prepare-test build-test clean all list
