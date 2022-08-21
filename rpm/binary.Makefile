PROJECT_NAME?=exec-helper
SRPM_PACKAGE?=$(PROJECT_NAME).src.rpm
ARCHITECTURE?=x86_64
RPM_PACKAGE?=$(PROJECT_NAME).$(ARCHITECTURE).rpm

RPM_DIR:=$(HOME)/rpmbuild
RPM_SOURCES:=$(RPM_DIR)/SOURCES
RPM_SPECS:=$(RPM_DIR)/SPECS

SOURCE_ARCHIVE?=$(PROJECT_NAME)*.tar.gz
SPEC_FILE:=$(RPM_SPECS)/$(PROJECT_NAME).spec

default: binary

$(RPM_PACKAGE):: $(SOURCE_ARCHIVE) $(SPEC_FILE)
	rpmbuild -bb $(SPEC_FILE)

binary: $(RPM_PACKAGE)

clean:
	rm -rf $(RPM_PACKAGE)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: build
.PHONY: build clean list all
