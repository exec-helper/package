PROJECT_NAME?=exec-helper
BUILD_DIR?=prepare
SOURCE_DIR?=PROJECT_DIR
SOURCE_FILES?=SOURCE_FILES
VERSION?=VERSION
DISTRIBUTION?=DISTRIBUTION
DEBIAN_ARCHIVE?=DEBIAN_ARCHIVE
SOURCE_ARCHIVE?=SOURCE_ARCHIVE

DEBIAN_DIR:=debian
SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

CHANGELOG_FILE:=debian/changelog
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG_FILE).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

GITCHANGELOG_TEMPLATE:=debian-changelog.tpl
GITCHANGELOG_RC:=.gitchangelog.rc
GITCHANGELOG_RC_TEMP_TEMPLATE:=$(GITCHANGELOG_RC).tmp
GITCHANGELOG_RC_TEMP:=$(shell mktemp --dry-run $(GITCHANGELOG_RC_TEMP_TEMPLATE).XXX)

CONTROL_FILE:=debian/control
COMPAT_FILE:=debian/compat

CONTROL_IN:=debian/control.in

RULES_FILE:=debian/rules
RULES_IN:=debian/rules.in
RULES_TEMP_TEMPLATE:=$(RULES_FILE).tmp
RULES_TEMP:=$(shell mktemp --dry-run $(RULES_TEMP_TEMPLATE).XXX)

# Determine the target architecture
ARCHITECTURE:=$(shell $(CC) -dumpmachine | cut -d'-' -f1)
ifeq ($(ARCHITECTURE),x86_64)
ARCHITECTURE:=amd64
endif

default: all

$(BUILD_DIR)/$(COMPAT_FILE):
	@mkdir -p $(@D)
	cp -r $(DEBIAN_DIR) $(BUILD_DIR)/
	rm $(BUILD_DIR)/$(DEBIAN_DIR)/*.in

$(BUILD_DIR)/$(GITCHANGELOG_RC): $(SOURCE_DIR)/$(GITCHANGELOG_RC)
	@mkdir -p $(@D)
	cp $(SOURCE_DIR)/$(GITCHANGELOG_RC) $(BUILD_DIR)/$(GITCHANGELOG_RC_TEMP)
	sed -i 's@output_engine = .*$$@output_engine = makotemplate(\"$(CURDIR)/debian-changelog.tpl\")@g' $(BUILD_DIR)/$(GITCHANGELOG_RC_TEMP)
	mv $(BUILD_DIR)/$(GITCHANGELOG_RC_TEMP) $(BUILD_DIR)/$(GITCHANGELOG_RC)

$(BUILD_DIR)/$(CHANGELOG_FILE): $(GITCHANGELOG_TEMPLATE) $(BUILD_DIR)/$(GITCHANGELOG_RC) $(BUILD_DIR) $(BUILD_DIR)/$(COMPAT_FILE)
	make --directory "$(SOURCE_DIR)" CHANGELOG_CONFIG="$(CURDIR)/$(BUILD_DIR)/$(GITCHANGELOG_RC)" CHANGELOG_OUTPUT="$(CURDIR)/$(BUILD_DIR)/$(CHANGELOG_TEMP)" print-changelog
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@PACKAGE@/$(PROJECT_NAME)/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR@/maintainer/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR_EMAIL@/maintainer@exec-helper.xyz/g" $(BUILD_DIR)/$(CHANGELOG_TEMP)
	mv $(BUILD_DIR)/$(CHANGELOG_TEMP) $(BUILD_DIR)/$(CHANGELOG_FILE)

$(BUILD_DIR)/$(CONTROL_FILE): $(CONTROL_IN) $(BUILD_DIR)/$(COMPAT_FILE)
	@mkdir -p $(@D)
	cp $(CONTROL_IN) $(BUILD_DIR)/$(CONTROL_FILE)

$(BUILD_DIR)/$(RULES_FILE): $(RULES_IN) $(BUILD_DIR)/$(COMPAT_FILE)
	@mkdir -p $(@D)
	cp $(RULES_IN) $(BUILD_DIR)/$(RULES_TEMP)
	mv $(BUILD_DIR)/$(RULES_TEMP) $(BUILD_DIR)/$(RULES_FILE)

$(DEBIAN_ARCHIVE): $(BUILD_DIR)/$(CONTROL_FILE) $(BUILD_DIR)/$(CHANGELOG_FILE) $(BUILD_DIR)/$(RULES_FILE) $(BUILD_DIR)/$(COMPAT_FILE)
	tar -c --directory $(BUILD_DIR) --exclude=$(CONTROL_FILE)_*.in --exclude=$(CHANGELOG_IN) -af $(DEBIAN_ARCHIVE) debian

$(SOURCE_ARCHIVE): $(SOURCES)
	tar --directory=$(SOURCE_DIR) -c --exclude-vcs --exclude=.gitlab-ci.yml -af $(SOURCE_ARCHIVE) .

prepare:: $(DEBIAN_ARCHIVE) $(SOURCE_ARCHIVE)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(DEBIAN_ARCHIVE)
	rm -f $(SOURCE_ARCHIVE)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: prepare
.PHONY: all clean list
