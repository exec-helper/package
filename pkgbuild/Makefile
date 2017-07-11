SOURCE_DIR=../exec-helper
BUILD_DIR=build
PKG_FILE=$(BUILD_DIR)/PKGBUILD

GIT_DESCRIBE:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
VERSION:=$(subst -,_,$(GIT_DESCRIBE))
COMMIT:=$(shell git -C $(SOURCE_DIR) log -n1 --pretty=format:%H)

all: build

prepare-build-dir:
	mkdir -p $(BUILD_DIR)

$(PKG_FILE): prepare-build-dir
	cp PKGBUILD.in $(PKG_FILE)

prepare-version: $(PKG_FILE)
	sed -i "s/@VERSION@/$(VERSION)/g" $(PKG_FILE)

prepare-commit: $(PKG_FILE)
	sed -i "s/@GIT_REF@/commit=$(COMMIT)/g" $(PKG_FILE)

prepare-common: prepare-commit prepare-version

pkgbuild: prepare-common
	sed -i "s/@PACKAGE@/exec-helper/g" $(PKG_FILE)

pkgbuild-git: prepare-common
	sed -i "s/@PACKAGE@/exec-helper-git/g" $(PKG_FILE)

prepare: pkgbuild
prepare-git: pkgbuild-git

build: prepare
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

build-git: prepare-git
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

clean:
	rm -rf $(BUILD_DIR)

.PHONY: prepare-build-dir prepare-version prepare-commit prepare-common pkgbuild pkgbuild-git build build-git clean all
