PROJECT_NAME:=exec-helper

SOURCE_DIR:=../$(PROJECT_NAME)
SOURCE_FILES:=CMakeLists.txt
SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

VERSION:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
DPKG_VERSION:=$(shell echo "$(VERSION)" | sed 's/-[^-]*//2g')
VENDOR:=$(shell lsb_release --id --short)
DISTRIBUTION:=$(shell lsb_release --codename --short)

BUILD_DIR=dpkg_build

CHANGELOG_FILE=debian/changelog
CHANGELOG_IN:=$(CHANGELOG_FILE).in
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG_FILE).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

GITCHANGELOG_TEMPLATE:=debian-changelog.tpl

CONTROL_FILE:=debian/control
CONTROL_IN:=debian/control_$(VENDOR).in

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
PACKAGES = 	$(PROJECT_NAME)_$(VERSION).dsc \
			$(PROJECT_NAME)_$(VERSION).debian.tar.xz \
			$(SOURCE_ARCHIVE) \
			$(PROJECT_NAME)_$(VERSION)_$(ARCHITECTURE).changes \
			$(PROJECT_NAME)_$(VERSION)_$(ARCHITECTURE).deb \
			$(PROJECT_NAME)-docs_$(VERSION)_all.deb \
			$(PROJECT_NAME)-dbgsym_$(VERSION)_$(ARCHITECTURE).deb

BUILD_INFO_FILE=$(PROJECT_NAME)_$(VERSION)*.buildinfo

CURDIR:=$(shell pwd)

all: build

$(CHANGELOG_FILE): $(GITCHANGELOG_TEMPLATE)
	cp $(GITCHANGELOG_TEMPLATE) $(SOURCE_DIR)/$(GITCHANGELOG_TEMPLATE)
	cd $(SOURCE_DIR) && GITCHANGELOG_CONFIG_FILENAME=$(CURDIR)/gitchangelog.rc gitchangelog > $(CURDIR)/$(CHANGELOG_TEMP)
	sed -i "s/@VERSION@/$(VERSION)/g" $(CHANGELOG_TEMP)
	sed -i "s/@PACKAGE@/$(PROJECT_NAME)/g" $(CHANGELOG_TEMP)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR@/maintainer/g" $(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR_EMAIL@/maintainer@exec-helper.xyz/g" $(CHANGELOG_TEMP)
	rm $(SOURCE_DIR)/$(GITCHANGELOG_TEMPLATE)
	mv $(CHANGELOG_TEMP) $(CHANGELOG_FILE)

$(CONTROL_FILE): $(CONTROL_IN)
	cp $(CONTROL_IN) $(CONTROL_FILE)

$(RULES_FILE): $(RULES_IN)
	cp $(RULES_IN) $(RULES_TEMP)
ifeq ($(VENDOR),Ubuntu)
	echo "" >> $(RULES_TEMP)
	echo "override_dh_strip:" >> $(RULES_TEMP)
	echo "	dh_strip --dbg-package=exec-helper-dbgsym" >> $(RULES_TEMP)
endif
	mv $(RULES_TEMP) $(RULES_FILE)

$(DEBIAN_ARCHIVE): $(CONTROL_FILE) $(CHANGELOG_FILE) $(RULES_FILE)
	tar -c --exclude=$(CONTROL_FILE)_*.in --exclude=$(CHANGELOG_IN) -af $(DEBIAN_ARCHIVE) debian

$(SOURCE_ARCHIVE): $(SOURCE_DIR)/$(SOURCES)
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

build:: deploy-archives install-build-deps
	cd $(BUILD_DIR) && dpkg-buildpackage -jauto -us -uc
	mkdir -p $(PACKAGE_DIR)
	cp $(PACKAGES) $(PACKAGE_DIR)/

	# Some systems do not generate a build info file
	test -f $(BUILD_INFO_FILE) && cp $(BUILD_INFO_FILE) $(PACKAGE_DIR)/ || true

clean:
	rm -f $(CONTROL_FILE)
	rm -f $(CHANGELOG_FILE)
	rm -f $(RULES_FILE)
	rm -f $(CHANGELOG_TEMP_TEMPLATE)*
	rm -f $(DEBIAN_ARCHIVE)
	rm -f $(SOURCE_ARCHIVE)
	rm -f $(BUILD_DEPS_PACKAGE)
	rm -f $(PACKAGES)
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: deploy-archives install-build-deps prepare build clean all list
