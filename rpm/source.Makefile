PROJECT_NAME?=exec-helper
SOURCE_ARCHIVE?=$(PROJECT_NAME)*.tar.gz
SRPM_PACKAGE:=$(PROJECT_NAME).src.rpm

RPM_DIR:=$(HOME)/rpmbuild
RPM_SOURCES:=$(RPM_DIR)/SOURCES
RPM_SPECS:=$(RPM_DIR)/SPECS

SPEC_FILE:=$(RPM_SPECS)/$(PROJECT_NAME).spec

default: source

$(SRPM_PACKAGE):: $(SOURCE_ARCHIVE) $(SPEC_FILE)
	rpmbuild -bs $(SPEC_FILE)

source: $(SRPM_PACKAGE)

clean:
	rm -rf $(SRPM_PACKAGE)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: source
.PHONY: all clean list
