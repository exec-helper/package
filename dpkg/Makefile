PROJECT_NAME:=exec-helper

SOURCE_DIR:=../$(PROJECT_NAME)
SOURCE_FILES:=CMakeLists.txt
SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

VERSION:=$(shell git -C $(SOURCE_DIR) describe --exact-match "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
DPKG_VERSION:=$(shell echo "$(VERSION)" | sed 's/-[^-]*//2g')
VENDOR:=$(shell lsb_release --id --short)
DISTRIBUTION:=$(shell lsb_release --codename --short)

PREPARE_DIR=dpkg_prepare
BUILD_DIR=dpkg_build

CHANGELOG_FILE=debian/changelog
CHANGELOG_IN:=$(CHANGELOG_FILE).in
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG_FILE).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

GITCHANGELOG_TEMPLATE:=debian-changelog.tpl
GITCHANGELOG_RC:=.gitchangelog.rc
GITCHANGELOG_RC_TEMP_TEMPLATE:=$(GITCHANGELOG_RC).tmp
GITCHANGELOG_RC_TEMP:=$(shell mktemp --dry-run $(GITCHANGELOG_RC_TEMP_TEMPLATE).XXX)

CONTROL_FILE:=debian/control

CONTROL_IN:=debian/control.in
# Hack for Ubuntu xenial until zesty. From Aartvark onwards, the Debian workflow can be followed (though it will stil generate .ddeb packages)
ifeq ($(DISTRIBUTION),$(filter $(DISTRIBUTION),xenial yakkety zesty))
CONTROL_IN:=debian/control_ubuntu_legacy.in
endif

RULES_FILE:=debian/rules
RULES_IN:=debian/rules.in
RULES_TEMP_TEMPLATE:=$(RULES_FILE).tmp
RULES_TEMP:=$(shell mktemp --dry-run $(RULES_TEMP_TEMPLATE).XXX)

DEBIAN_ARCHIVE:=debian.tar.xz
SOURCE_ARCHIVE:=$(PROJECT_NAME)_$(DPKG_VERSION).orig.tar.xz

DEBIAN_FILES:=$(CHANGELOG_FILE)
SOURCE_FILES:=CMakeLists.txt

# Package name used for installing the build dependencies with mk-build-deps
BUILD_DEPS_PACKAGE:=$(PROJECT_NAME)-build-deps_$(VERSION)_all.deb

# Determine the target architecture
ARCHITECTURE:=$(shell $(CC) -dumpmachine | cut -d'-' -f1)
ifeq ($(ARCHITECTURE),x86_64)
ARCHITECTURE:=amd64
endif

PACKAGE_DIR=package
CHANGES_FILE:=$(PROJECT_NAME)_$(VERSION)_$(ARCHITECTURE).changes

CURDIR:=$(shell pwd)

all: build

$(PREPARE_DIR):
	mkdir -p $(PREPARE_DIR)
	cp -r debian $(PREPARE_DIR)/

$(PREPARE_DIR)/$(GITCHANGELOG_RC): $(SOURCE_DIR)/$(GITCHANGELOG_RC) $(PREPARE_DIR)
	cp $(SOURCE_DIR)/$(GITCHANGELOG_RC) $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP)
	sed -i 's@output_engine = .*$$@output_engine = makotemplate(\"$(CURDIR)/debian-changelog.tpl\")@g' $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP)
	mv $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP) $(PREPARE_DIR)/$(GITCHANGELOG_RC)

$(PREPARE_DIR)/$(CHANGELOG_FILE): $(GITCHANGELOG_TEMPLATE) $(PREPARE_DIR)/$(GITCHANGELOG_RC) $(PREPARE_DIR)
	make --directory "$(SOURCE_DIR)" CHANGELOG_CONFIG="$(CURDIR)/$(PREPARE_DIR)/$(GITCHANGELOG_RC)" CHANGELOG_OUTPUT="$(CURDIR)/$(PREPARE_DIR)/$(CHANGELOG_TEMP)" print-changelog
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@PACKAGE@/$(PROJECT_NAME)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR@/maintainer/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR_EMAIL@/maintainer@exec-helper.xyz/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	mv $(PREPARE_DIR)/$(CHANGELOG_TEMP) $(PREPARE_DIR)/$(CHANGELOG_FILE)

$(PREPARE_DIR)/$(CONTROL_FILE): $(CONTROL_IN) $(PREPARE_DIR)
	cp $(CONTROL_IN) $(PREPARE_DIR)/$(CONTROL_FILE)

$(PREPARE_DIR)/$(RULES_FILE): $(RULES_IN) $(PREPARE_DIR)
	cp $(RULES_IN) $(PREPARE_DIR)/$(RULES_TEMP)
	# Hack for Ubuntu xenial until zesty. From Aartvark onwards, the Debian workflow can be followed (though it will stil generate .ddeb packages)
ifeq ($(DISTRIBUTION),$(filter $(DISTRIBUTION),xenial yakkety zesty))
	echo "" >> $(PREPARE_DIR)/$(RULES_TEMP)
	echo "override_dh_strip:" >> $(PREPARE_DIR)/$(RULES_TEMP)
	echo "	dh_strip --dbg-package=exec-helper-dbgsym" >> $(PREPARE_DIR)/$(RULES_TEMP)
endif
	mv $(PREPARE_DIR)/$(RULES_TEMP) $(PREPARE_DIR)/$(RULES_FILE)

$(DEBIAN_ARCHIVE): $(PREPARE_DIR)/$(CONTROL_FILE) $(PREPARE_DIR)/$(CHANGELOG_FILE) $(PREPARE_DIR)/$(RULES_FILE)
	tar -c --directory $(PREPARE_DIR) --exclude=$(CONTROL_FILE)_*.in --exclude=$(CHANGELOG_IN) -af $(DEBIAN_ARCHIVE) debian

$(SOURCE_ARCHIVE): $(SOURCES)
	tar --directory=$(SOURCE_DIR) -c --exclude-vcs --exclude-vcs-ignores --exclude=.gitlab-ci.yml -af $(SOURCE_ARCHIVE) .

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PACKAGE_DIR):
	mkdir -p $(PACKAGE_DIR)

$(BUILD_DIR)/$(DEBIAN_FILES): $(BUILD_DIR) $(DEBIAN_ARCHIVE)
	tar -C $(BUILD_DIR) -xf $(DEBIAN_ARCHIVE)

$(BUILD_DIR)/$(SOURCE_FILES): $(BUILD_DIR) $(SOURCE_ARCHIVE)
	tar -C $(BUILD_DIR) -xf $(SOURCE_ARCHIVE)

deploy-archives:: $(BUILD_DIR)/$(DEBIAN_FILES) $(BUILD_DIR)/$(SOURCE_FILES)

$(BUILD_DEPS_PACKAGE): $(BUILD_DIR)/$(DEBIAN_FILES)
	cd $(BUILD_DIR) && yes | sudo mk-build-deps --install --remove
	# Fake the package so we know that the build dependencies have been installed
	touch $(BUILD_DEPS_PACKAGE)

install-build-deps: $(BUILD_DEPS_PACKAGE)

prepare:: $(DEBIAN_ARCHIVE) $(SOURCE_ARCHIVE)

prepare-test:
	$(MAKE) --directory test prepare

build:: deploy-archives install-build-deps
	cd $(BUILD_DIR) && dpkg-buildpackage -jauto -us -uc
	mkdir -p $(PACKAGE_DIR)
	mv $$(sed -n '/Files:/,$$p' $(CHANGES_FILE) | grep -E "\.dsc$$|\.tar.xz$$|\.tar.gz$$|\.deb$$|\.ddeb$$|\.buildinfo$$" | sed 's/.* //' | xargs) $(PACKAGE_DIR)/
	mv $(CHANGES_FILE) $(PACKAGE_DIR)/

build-test:
	$(MAKE) --directory test build

clean:
	rm -f $(DEBIAN_ARCHIVE)
	rm -f $(SOURCE_ARCHIVE)
	rm -f $(BUILD_DEPS_PACKAGE)
	rm -rf $(PREPARE_DIR)
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)
	$(MAKE) --directory test clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: deploy-archives install-build-deps prepare build clean all list
