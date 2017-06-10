all: find-distribution

find-distribution:
	make $(shell lsb_release --id --short | tr A-Z a-z)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

pkgbuild:
	cd pkgbuild && makepkg -fs --noconfirm --needed

dpkg:
	# Install the build deps
	yes | sudo mk-build-deps -i
	rm exec-helper-build-deps_*_all.deb

	# Generate the changelog
	dpkg/write_changelog.sh

	dpkg-buildpackage -jauto -us -uc

arch: pkgbuild

debian: dpkg

ubuntu: dpkg

.PHONY: list all pkgbuild dpkg arch debian ubuntu
