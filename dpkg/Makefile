PROJECT_NAME:=exec-helper
MAINTAINER?=maintainer
MAINTAINER_EMAIL?=maintainer@exec-helper.xyz

SOURCE_DIR:=../$(PROJECT_NAME)
GIT_VERSION:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
SOURCE_VERSION:=$(shell echo $(GIT_VERSION) | sed -E 's@([^-]*)-.*$$@\1@g')
GIT_REVISION:=$(shell echo $(GIT_VERSION) | sed -E 's@[^-]*-([^-])*-.*$$@\1@g')
DEBIAN_REVISION:=$(shell echo $$(($(GIT_REVISION)+1)))
GIT_COMMIT:=$(shell git -C $(SOURCE_DIR) log --format=%h -n1)

YEAR:=$(shell date +'%Y')

ifeq ($(DEBIAN_REVISION),1)
# For some reasons the Debian tools thread the first debian revision differently
VERSION:=$(SOURCE_VERSION)~git$(GIT_COMMIT)
SHORT_VERSION:=$(SOURCE_VERSION)
SOURCE_CHANGES_FILE:=$(PROJECT_NAME)_$(SOURCE_VERSION)-$(DEBIAN_REVISION)_source.changes
else
VERSION:=$(SOURCE_VERSION)~git$(GIT_COMMIT)-$(DEBIAN_REVISION)
SHORT_VERSION:=$(SOURCE_VERSION)-$(DEBIAN_REVISION)
SOURCE_CHANGES_FILE:=$(PROJECT_NAME)_$(SHORT_VERSION)_source.changes
endif

DISTRIBUTION:=$(shell lsb_release --codename --short)
SYSTEM_DESCRIPTION:=$(shell lsb_release --description --short)

BUILD_DIR:=build
PACKAGE_DIR:=package

DEBIAN_ARCHIVE=debian.tar.xz
SOURCE_ARCHIVE:=$(PROJECT_NAME)_$(SHORT_VERSION).orig.tar.xz
SOURCE_FILES:=CMakeLists.txt

PREPARE_MAKEFILE:=prepare.Makefile
SOURCE_MAKEFILE:=source.Makefile
BUILD_MAKEFILE:=build.Makefile

all: prepare

prepare:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/prepare DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_DIR=$(SOURCE_DIR) SOURCE_FILES=$(SOURCE_FILES) VERSION=$(VERSION) DISTRIBUTION=$(DISTRIBUTION) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) "SYSTEM_DESCRIPTION=$(SYSTEM_DESCRIPTION)" YEAR=$(YEAR) "MAINTAINER=$(MAINTAINER)" "MAINTAINER_EMAIL=$(MAINTAINER_EMAIL)"

source: prepare
	$(MAKE) --makefile=$(SOURCE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/source PACKAGE_DIR=$(PACKAGE_DIR)/source DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_FILES=$(SOURCE_FILES) CHANGES_FILE=$(SOURCE_CHANGES_FILE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE)

build: prepare
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR)/binary PACKAGE_DIR=$(PACKAGE_DIR)/binary

prepare-test:
	$(MAKE) --directory test prepare

build-test:
	$(MAKE) --directory test build

clean:
	$(MAKE) --makefile=$(PREPARE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/prepare DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_DIR=$(SOURCE_DIR) SOURCE_FILES=$(SOURCE_FILES) "VERSION=$(VERSION)" DISTRIBUTION=$(DISTRIBUTION) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) clean
	$(MAKE) --makefile=$(SOURCE_MAKEFILE) PROJECT_NAME=$(PROJECT_NAME) BUILD_DIR=$(BUILD_DIR)/source PACKAGE_DIR=$(PACKAGE_DIR)/source DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_FILES=$(SOURCE_FILES) CHANGES_FILE=$(SOURCE_CHANGES_FILE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) clean
	$(MAKE) --makefile=$(BUILD_MAKEFILE) DEBIAN_ARCHIVE=$(DEBIAN_ARCHIVE) SOURCE_ARCHIVE=$(SOURCE_ARCHIVE) BUILD_DIR=$(BUILD_DIR)/binary PACKAGE_DIR=$(PACKAGE_DIR)/binary clean
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

	$(MAKE) --directory test clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: prepare source build prepare-test build-test clean all list
