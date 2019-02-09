PROJECT_NAME:=exec-helper
SOURCE_DIR:=../$(PROJECT_NAME)
BUILD_DIR:=build_package

CHANGELOG:=$(PROJECT_NAME).changelog
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

PKG_FILE:=PKGBUILD
PKG_IN:=$(PKG_FILE).in
TEST_PKG_IN:=$(PKG_FILE).test.in
PKG_TEMP_TEMPLATE:=$(PKG_FILE).tmp
PKG_TEMP:=$(shell mktemp --dry-run $(PKG_TEMP_TEMPLATE).XXX)

SRC_INFO_FILE_NAME:=.SRCINFO
SRC_INFO_FILE:=$(BUILD_DIR)/$(SRC_INFO_FILE_NAME)

GIT_DESCRIBE:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) log -n1 --pretty=format:g%h)
VERSION:=$(subst -,_,$(GIT_DESCRIBE))
COMMIT:=$(shell git -C $(SOURCE_DIR) log -n1 --pretty=format:%H)

CURDIR:=$(shell pwd)

PREFIX:=package

all: build

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(CHANGELOG): $(BUILD_DIR)
	make --directory "$(SOURCE_DIR)" CHANGELOG_OUTPUT="$(CURDIR)/$(BUILD_DIR)/$(CHANGELOG_TEMP)" print-changelog
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	mv $(BUILD_DIR)/$(CHANGELOG_TEMP) $(BUILD_DIR)/$(CHANGELOG)

$(BUILD_DIR)/$(PKG_FILE): $(BUILD_DIR) $(PKG_IN)
	cp $(PKG_IN) $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@VERSION@/$(VERSION)/g" $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@GIT_REF@/commit=$(COMMIT)/g" $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@CHANGELOG@/$(CHANGELOG)/g" $(BUILD_DIR)/$(PKG_TEMP)
	mv $(BUILD_DIR)/$(PKG_TEMP) $(BUILD_DIR)/$(PKG_FILE)

pkgbuild:: $(BUILD_DIR)/$(PKG_FILE) $(BUILD_DIR)/$(CHANGELOG)
	sed -i "s/@PACKAGE@/exec-helper/g" $(BUILD_DIR)/$(PKG_FILE)

pkgbuild-git:: $(BUILD_DIR)/$(PKG_FILE) $(BUILD_DIR)/$(CHANGELOG)
	sed -i "s/@PACKAGE@/exec-helper-git/g" $(BUILD_DIR)/$(PKG_FILE)

$(SRC_INFO_FILE): $(PKGBUILD) $(BUILD_DIR)
	cd $(BUILD_DIR) && makepkg --printsrcinfo > $(SRC_INFO_FILE_NAME)

prepare: pkgbuild $(SRC_INFO_FILE)
prepare-git: pkgbuild-git $(SRC_INFO_FILE)
prepare-test: prepare

source: prepare

build: prepare
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

build-git: prepare-git
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

build-test: prepare-test
	cd $(BUILD_DIR) && makepkg --check --noconfirm --needed --syncdeps --force

$(PREFIX):
	mkdir -p $(PREFIX)

install: $(PREFIX)
	cp $(BUILD_DIR)/$(SRC_INFO_FILE_NAME) $(PREFIX)/
	cp $(BUILD_DIR)/$(PKG_FILE) $(PREFIX)/
	cp $(BUILD_DIR)/$(CHANGELOG) $(PREFIX)/

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(TEST_BUILD_DIR)
	rm -rf $(PREFIX)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: prepare-build-dir prepare-version prepare-commit prepare-test pkgbuild pkgbuild-git pkgbuild-test build build-git build-test clean all
