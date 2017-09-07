PROJECT_NAME:=exec-helper
SOURCE_DIR:=../$(PROJECT_NAME)
BUILD_DIR:=build

CHANGELOG:=$(PROJECT_NAME).changelog
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

PKG_FILE:=PKGBUILD
PKG_IN:=$(PKG_FILE).in
PKG_TEMP_TEMPLATE:=$(PKG_FILE).tmp
PKG_TEMP:=$(shell mktemp --dry-run $(PKG_TEMP_TEMPLATE).XXX)

GIT_DESCRIBE:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) log -n1 --pretty=format:g%h)
VERSION:=$(subst -,_,$(GIT_DESCRIBE))
COMMIT:=$(shell git -C $(SOURCE_DIR) log -n1 --pretty=format:%H)

CURDIR:=$(shell pwd)

all: build

prepare-build-dir:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(CHANGELOG): prepare-build-dir
	cd $(SOURCE_DIR) && make --quiet print-changelog > $(CURDIR)/$(BUILD_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	mv $(BUILD_DIR)/$(CHANGELOG_TEMP) $(BUILD_DIR)/$(CHANGELOG)

$(BUILD_DIR)/$(PKG_FILE): prepare-build-dir $(PKG_IN)
	cp $(PKG_IN) $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@GIT_REF@/commit=$(COMMIT)/g" $(BUILD_DIR)/$(PKG_TEMP)
	sed -i "s/@CHANGELOG@/$(CHANGELOG)/g" $(BUILD_DIR)/$(PKG_TEMP)
	mv $(BUILD_DIR)/$(PKG_TEMP) $(BUILD_DIR)/$(PKG_FILE)

pkgbuild:: $(BUILD_DIR)/$(PKG_FILE) $(BUILD_DIR)/$(CHANGELOG)
	sed -i "s/@PACKAGE@/exec-helper/g" $(BUILD_DIR)/$(PKG_FILE)

pkgbuild-git:: $(BUILD_DIR)/$(PKG_FILE) $(BUILD_DIR)/$(CHANGELOG)
	sed -i "s/@PACKAGE@/exec-helper-git/g" $(BUILD_DIR)/$(PKG_FILE)

prepare: pkgbuild
prepare-git: pkgbuild-git

build: prepare
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

build-git: prepare-git
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

clean:
	rm -rf $(BUILD_DIR)

.PHONY: prepare-build-dir prepare-version prepare-commit prepare-common pkgbuild pkgbuild-git build build-git clean all
