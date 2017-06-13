BUILD_DIR=build
PKG_FILE=$(BUILD_DIR)/PKGBUILD
COMMIT=$(shell git submodule | sed "s/[- ]\([0-9a-f]*\) .*$$/\1/g")
VERSION=$(shell git describe 2>/dev/null || echo "UNKNOWN")

prepare-build-dir:
	mkdir -p $(BUILD_DIR)

$(PKG_FILE): prepare-build-dir
	cp PKGBUILD.in $(PKG_FILE)

prepare-version: $(PKG_FILE)
	sed -i "s/@VERSION@/$(VERSION)/g" $(PKG_FILE)

prepare-commit: $(PKG_FILE)
	sed -i "s/@GIT_REF@/commit=$(COMMIT)/g" $(PKG_FILE)

prepare: prepare-commit prepare-version

prepare-pkg-file: prepare
	sed -i "s/@PACKAGE@/exec-helper/g" $(PKG_FILE)

prepare-pkg-file-git: prepare
	sed -i "s/@PACKAGE@/exec-helper-git/g" $(PKG_FILE)

pkgbuild: prepare-pkg-file
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

pkgbuild-git: prepare-pkg-file-git
	cd $(BUILD_DIR) && makepkg --noconfirm --needed --syncdeps --force

all: pkgbuild

clean:
	rm -rf $(BUILD_DIR)

.PHONY: prepare-build-dir prepare-pkg-file prepare-pkg-file-git pkgbuild pkgbuild-git clean all
