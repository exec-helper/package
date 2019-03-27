PROJECT_NAME?=exec-helper
BUILD_DIR?=dpkg_source
PACKAGE_DIR?=package_source
DEBIAN_ARCHIVE?=debian.tar.xz
SOURCE_ARCHIVE?=$(PROJECT_NAME)*.orig.tar.gz
SOURCE_FILES?=CMakeLists.txt
CHANGES_FILE?=*.changes

EXTRACT_DIR:=$(BUILD_DIR)/build

DEBIAN_DIR:=debian

default: all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(EXTRACT_DIR):
	mkdir -p $(EXTRACT_DIR)

$(PACKAGE_DIR):
	mkdir -p $(PACKAGE_DIR)

$(BUILD_DIR)/$(DEBIAN_ARCHIVE): $(BUILD_DIR)
	cp --reflink=auto $(DEBIAN_ARCHIVE) $(BUILD_DIR)/$(DEBIAN_ARCHIVE)

$(BUILD_DIR)/$(SOURCE_ARCHIVE): $(BUILD_DIR)
	cp --reflink=auto $(SOURCE_ARCHIVE) $(BUILD_DIR)/$(SOURCE_ARCHIVE)

$(EXTRACT_DIR)/$(DEBIAN_FOLDER):: $(BUILD_DIR)/$(DEBIAN_ARCHIVE) $(EXTRACT_DIR)
	tar -C $(EXTRACT_DIR) -xf $(BUILD_DIR)/$(DEBIAN_ARCHIVE)

$(EXTRACT_DIR)/$(SOURCE_FILES):: $(BUILD_DIR)/$(SOURCE_ARCHIVE) $(EXTRACT_DIR)
	tar -C $(EXTRACT_DIR) -xf $(BUILD_DIR)/$(SOURCE_ARCHIVE)

$(BUILD_DIR)/$(CHANGES_FILE):: $(EXTRACT_DIR)/$(DEBIAN_FOLDER) $(EXTRACT_DIR)/$(SOURCE_FILES)
	cd $(EXTRACT_DIR) && dpkg-buildpackage -j8 -us -uc --build=source

source:: $(BUILD_DIR)/$(CHANGES_FILE) $(PACKAGE_DIR)
	cd $(BUILD_DIR) && cp --reflink=auto $$(sed -n '/Files:/,$$p' $(CHANGES_FILE) | grep -E "\.dsc$$|\.tar.xz$$|\.tar.gz$$|\.deb$$|\.ddeb$$|\.buildinfo$$" | sed 's/.* //' | xargs) $(CURDIR)/$(PACKAGE_DIR)/
	cp --reflink=auto $(BUILD_DIR)/$(CHANGES_FILE) $(PACKAGE_DIR)/

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: source
.PHONY: all clean list
