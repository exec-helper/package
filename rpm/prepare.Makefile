PROJECT_NAME?=exec-helper
BUILD_DIR?=prepare
SOURCE_DIR?=PROJECT_DIR
SOURCE_FILES?=SOURCE_FILES
SHORT_VERSION?=SHORT_VERSION
VERSION?=VERSION
SYSTEM_DESCRIPTION?=SYSTEM_DESCRIPTION
SOURCE_ARCHIVE?=SOURCE_ARCHIVE
YEAR?=2018
RELEASE?=0

SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

RPM_DIR:=$(HOME)/rpmbuild
RPM_SOURCES:=/usr/src/packages/SOURCES
RPM_SPECS:=$(RPM_DIR)/SPECS

SPEC_FILE:=$(RPM_SPECS)/$(PROJECT_NAME).spec
SPEC_TEMP_TEMPLATE:=$(CHANGELOG).tmp
SPEC_TEMP:=$(RPM_SPECS)/$(shell mktemp --dry-run $(SPEC_TEMP_TEMPLATE).XXX)

# Determine the target architecture
ARCHITECTURE:=$(shell $(CC) -dumpmachine | cut -d'-' -f1)
ifeq ($(ARCHITECTURE),x86_64)
ARCHITECTURE:=amd64
endif

default: prepare

$(RPM_SOURCES):
	mkdir --parents $(RPM_SOURCES)

$(RPM_SPECS):
	mkdir --parents $(RPM_SPECS)

$(SPEC_FILE): $(RPM_SPECS) SPECS/exec-helper.spec
	cp SPECS/exec-helper.spec $(SPEC_TEMP)
	sed -i "s/@SHORT_VERSION@/$(SHORT_VERSION)/g" $(SPEC_TEMP)
	sed -i "s/@VERSION@/$(VERSION)/g" $(SPEC_TEMP)
	sed -i "s/@RELEASE@/$(RELEASE)/g" $(SPEC_TEMP)
	mv $(SPEC_TEMP) $(SPEC_FILE)

$(SOURCE_ARCHIVE):: $(RPM_SOURCES) $(SOURCES) $(SPEC_FILE)
	cp -r $(SOURCE_DIR) /tmp/$(PROJECT_NAME)-$(SHORT_VERSION)
	tar --directory=/tmp -c --exclude-vcs --exclude-vcs-ignores --exclude=.gitlab-ci.yml -af $(SOURCE_ARCHIVE) $(PROJECT_NAME)-$(SHORT_VERSION)

prepare:: $(SOURCE_ARCHIVE)

clean:
	rm -rf /tmp/$(PROJECT_NAME)-$(VERSION)
	rm -f $(SOURCE_ARCHIVE)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: prepare
.PHONY: all clean list
