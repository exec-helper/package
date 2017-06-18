all: build

pkgbuild:
	$(MAKE) -C pkgbuild $(TARGET) 

pkgbuild-git:
	$(MAKE) -C pkgbuild $(TARGET)

arch: pkgbuild
arch-git: pkgbuild-git

find-distribution:
	$(MAKE) $(shell lsb_release --id --short | tr A-Z a-z) TARGET=$(TARGET)

prepare:
	$(MAKE) find-distribution TARGET=prepare

build:
	$(MAKE) find-distribution TARGET=build

clean:
	$(MAKE) -C pkgbuild clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: pkgbuild pkgbuild-git arch arch-git find-distribution list all
