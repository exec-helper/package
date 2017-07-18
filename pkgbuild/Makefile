PROJECT_NAME:=exec-helper
SOURCE_DIR:=../$(PROJECT_NAME)
BUILD_DIR:=build
CHANGELOG:=$(PROJECT_NAME).changelog

PKG_FILE:=PKGBUILD
PKG_IN:=$(PKG_FILE).in
PKG_TEMP_TEMPLATE:=$(PKG_FILE).tmp
PKG_TEMP:=$(shell mktemp --dry-run $(PKG_TEMP_TEMPLATE).XXX)

GIT_DESCRIBE:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
VERSION:=$(subst -,_,$(GIT_DESCRIBE))
COMMIT:=$(shell git -C $(SOURCE_DIR) log -n1 --pretty=format:%H)

all: build

prepare-build-dir:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(CHANGELOG): prepare-build-dir
	cd $(SOURCE_DIR) && GITCHANGELOG_CONFIG_FILENAME=$(pwd)/../gitchangelog.rc gitchangelog > $(pwd)/$(BUILD_DIR)/$(CHANGELOG)

$(BUILD_DIR)/$(PKG_FILE): prepare-build-dir $(PKG_IN)
	cp $(PKG_IN) $(PKG_TEMP)
	sed -i "s/@VERSION@/$(VERSION)/g" $(PKG_TEMP)
	sed -i "s/@GIT_REF@/commit=$(COMMIT)/g" $(PKG_TEMP)
	sed -i "s/@CHANGELOG@/$(CHANGELOG)/g" $(PKG_TEMP)
	mv $(PKG_TEMP) $(BUILD_DIR)/$(PKG_FILE)

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
	rm -f $(PKG_TEMP)
	rm -rf $(BUILD_DIR)

.PHONY: prepare-build-dir prepare-version prepare-commit prepare-common pkgbuild pkgbuild-git build build-git clean all
