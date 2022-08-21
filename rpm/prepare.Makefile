PROJECT_NAME?=exec-helper
BUILD_DIR?=prepare
SOURCE_DIR?=PROJECT_DIR
SOURCE_FILES?=SOURCE_FILES
VERSION?=VERSION
SYSTEM_DESCRIPTION?=SYSTEM_DESCRIPTION
SOURCE_ARCHIVE?=SOURCE_ARCHIVE
YEAR?=2018

SOURCES:=$(SOURCE_DIR)/$(SOURCE_FILES)

# Determine the target architecture
ARCHITECTURE:=$(shell $(CC) -dumpmachine | cut -d'-' -f1)
ifeq ($(ARCHITECTURE),x86_64)
ARCHITECTURE:=amd64
endif

default: prepare

$(SOURCE_ARCHIVE): $(SOURCES)
	cp -r $(SOURCE_DIR) /tmp/$(PROJECT_NAME)-$(VERSION)
	tar --directory=/tmp -c --exclude-vcs --exclude-vcs-ignores --exclude=.gitlab-ci.yml -af $(SOURCE_ARCHIVE) $(PROJECT_NAME)-$(VERSION)

prepare:: $(SOURCE_ARCHIVE)

clean:
	rm -rf /tmp/$(PROJECT_NAME)-$(VERSION)
	rm -f $(SOURCE_ARCHIVE)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: prepare
.PHONY: all clean list
