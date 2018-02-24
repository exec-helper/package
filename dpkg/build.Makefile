BUILD_DIR?=build
PACKAGE_DIR?=package
DEBIAN_ARCHIVE?=DEBIAN.tar.xz
SOURCE_ARCHIVE?=SOURCE.orig.tar.xz

DEBIAN_FOLDER:=debian
SOURCE_FILES:=CMakeLists.txt
CHANGES_FILE:=*.changes

default: all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PACKAGE_DIR):
	mkdir -p $(PACKAGE_DIR)

$(BUILD_DIR)/$(DEBIAN_FOLDER): $(BUILD_DIR)
	tar -C $(BUILD_DIR) -xf $(DEBIAN_ARCHIVE)

$(BUILD_DIR)/$(SOURCE_FILES): $(BUILD_DIR)
	tar -C $(BUILD_DIR) -xf $(SOURCE_ARCHIVE)

deploy-archives:: $(BUILD_DIR)/$(DEBIAN_FOLDER) $(BUILD_DIR)/$(SOURCE_FILES)

build: deploy-archives
	cd $(BUILD_DIR) && dpkg-buildpackage -jauto -us -uc
	mkdir -p $(PACKAGE_DIR)
	mv $$(sed -n '/Files:/,$$p' $(CHANGES_FILE) | grep -E "\.dsc$$|\.tar.xz$$|\.tar.gz$$|\.deb$$|\.ddeb$$|\.buildinfo$$" | sed 's/.* //' | xargs) $(PACKAGE_DIR)/
	mv $(CHANGES_FILE) $(PACKAGE_DIR)/

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

all: build
