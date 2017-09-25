all: build

clean:
	$(MAKE) -C pkgbuild clean
	$(MAKE) -C dpkg clean

# Package manager formats
pkgbuild:
	$(MAKE) -C pkgbuild $(TARGET) 

dpkg:
	$(MAKE) -C dpkg $(TARGET)

# Distribution to package manager mapping
arch: pkgbuild

debian: dpkg
ubuntu: dpkg

find-distribution:
	$(MAKE) $(shell lsb_release --id --short | tr A-Z a-z) TARGET=$(TARGET)

prepare:
	$(MAKE) find-distribution TARGET=prepare

build:
	$(MAKE) find-distribution TARGET=build

build-test:
	$(MAKE) find-distribution TARGET=build-test

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: pkgbuild dpkg pkgbuild-git arch arch-git debian ubuntu find-distribution list all
