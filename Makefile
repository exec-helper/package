all: find-distribution

pkgbuild:
	cd pkgbuild && makepkg -fs

arch: pkgbuild

find-distribution:
	make $(shell lsb_release --id --short | tr A-Z a-z)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: pkgbuild arch list all
