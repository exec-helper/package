CURDIR:=$(shell pwd)

PREFIX?="$(CURDIR)/package"

all: prepare

clean:
	$(MAKE) --directory pkgbuild clean
	$(MAKE) --directory dpkg clean

# Package manager formats
pkgbuild:
	$(MAKE) --directory pkgbuild PREFIX=$(PREFIX) $(TARGET) 

dpkg:
	$(MAKE) --directory dpkg PREFIX=$(PREFIX) $(TARGET)

# Distribution to package manager mapping
arch: pkgbuild

debian: dpkg
ubuntu: dpkg

find-distribution:
	$(MAKE) $(shell lsb_release --id --short | tr A-Z a-z) TARGET=$(TARGET) PREFIX=$(PREFIX)

prepare:
	$(MAKE) find-distribution TARGET=prepare

source:
	$(MAKE) find-distribution TARGET=source

binary:
	$(MAKE) find-distribution TARGET=binary

install:
	$(MAKE) find-distribution TARGET=install

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: pkgbuild dpkg arch debian ubuntu find-distribution list all prepare source binary clean%
