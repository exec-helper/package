PROJECT_NAME:=exec-helper

PREPARE_DIR?=prepare
DEBIAN_ARCHIVE?=debian.tar.xz

DEBIAN_DIR:=debian

SOURCE_DIR:=../$(PROJECT_NAME)
SOURCE_FILES:=CMakeLists.txt
SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

VERSION:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:g%h)
DISTRIBUTION:=$(shell lsb_release --codename --short)

CHANGELOG_FILE=debian/changelog
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

$(PREPARE_DIR)/$(COMPAT_FILE):
	@mkdir -p $(@D)
	cp -r $(DEBIAN_DIR) $(PREPARE_DIR)/
	rm $(PREPARE_DIR)/$(DEBIAN_DIR)/*.in

$(PREPARE_DIR)/$(GITCHANGELOG_RC): $(SOURCE_DIR)/$(GITCHANGELOG_RC)
	@mkdir -p $(@D)
	cp $(SOURCE_DIR)/$(GITCHANGELOG_RC) $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP)
	sed -i 's@output_engine = .*$$@output_engine = makotemplate(\"$(CURDIR)/debian-changelog.tpl\")@g' $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP)
	mv $(PREPARE_DIR)/$(GITCHANGELOG_RC_TEMP) $(PREPARE_DIR)/$(GITCHANGELOG_RC)

$(PREPARE_DIR)/$(CHANGELOG_FILE): $(GITCHANGELOG_TEMPLATE) $(PREPARE_DIR)/$(GITCHANGELOG_RC) $(PREPARE_DIR) $(PREPARE_DIR)/$(COMPAT_FILE)
	make --directory "$(SOURCE_DIR)" CHANGELOG_CONFIG="$(CURDIR)/$(PREPARE_DIR)/$(GITCHANGELOG_RC)" CHANGELOG_OUTPUT="$(CURDIR)/$(PREPARE_DIR)/$(CHANGELOG_TEMP)" print-changelog
	sed -i "s/@UNRELEASED@/$(VERSION)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@PACKAGE@/$(PROJECT_NAME)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR@/maintainer/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	sed -i "s/@AUTHOR_EMAIL@/maintainer@exec-helper.xyz/g" $(PREPARE_DIR)/$(CHANGELOG_TEMP)
	mv $(PREPARE_DIR)/$(CHANGELOG_TEMP) $(PREPARE_DIR)/$(CHANGELOG_FILE)

$(PREPARE_DIR)/$(CONTROL_FILE): $(CONTROL_IN) $(PREPARE_DIR)/$(COMPAT_FILE)
	@mkdir -p $(@D)
	cp $(CONTROL_IN) $(PREPARE_DIR)/$(CONTROL_FILE)

$(PREPARE_DIR)/$(RULES_FILE): $(RULES_IN) $(PREPARE_DIR)/$(COMPAT_FILE)
	@mkdir -p $(@D)
	cp $(RULES_IN) $(PREPARE_DIR)/$(RULES_TEMP)
	mv $(PREPARE_DIR)/$(RULES_TEMP) $(PREPARE_DIR)/$(RULES_FILE)

$(DEBIAN_ARCHIVE): $(PREPARE_DIR)/$(CONTROL_FILE) $(PREPARE_DIR)/$(CHANGELOG_FILE) $(PREPARE_DIR)/$(RULES_FILE) $(PREPARE_DIR)/$(COMPAT_FILE)
	tar -c --directory $(PREPARE_DIR) --exclude=$(CONTROL_FILE)_*.in --exclude=$(CHANGELOG_IN) -af $(DEBIAN_ARCHIVE) debian

# Unfortunately, this had to become a PHONY target in order to be able to read the version at runtime
archive_source: $(DEBIAN_ARCHIVE) $(SOURCES)
	$(eval VERSION := $(patsubst %-1,%,$(shell dpkg-parsechangelog --file=$(PREPARE_DIR)/$(CHANGELOG_FILE) -S version | sed 's@\(.*\)-[0-9a-z]*$$@\1@g')))
	$(eval SOURCE_ARCHIVE := $(PROJECT_NAME)_$(VERSION).orig.tar.xz)
	tar --directory=$(SOURCE_DIR) -c --exclude-vcs --exclude-vcs-ignores --exclude=.gitlab-ci.yml -af $(SOURCE_ARCHIVE) .

clean:
	rm -rf $(PREPARE_DIR)
	rm -f $(DEBIAN_ARCHIVE)
	rm -f *.orig.tar.xz

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: $(DEBIAN_ARCHIVE) archive_source
.PHONY: all clean list
