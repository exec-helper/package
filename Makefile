all: find-distribution

find-distribution:
	$(MAKE) $(shell lsb_release --id --short | tr A-Z a-z)

clean:
	$(MAKE) -C pkgbuild clean

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Package manager formats
pkgbuild:
	$(MAKE) -C pkgbuild pkgbuild

pkgbuild-git:
	$(MAKE) -C pkgbuild pkgbuild-git

dpkg:
	# Install the build deps
	yes | sudo mk-build-deps -i

	# Generate the changelog
	dpkg/write_changelog.sh

	dpkg-buildpackage -jauto -us -uc

# Distributions
arch: pkgbuild
arch-git: pkgbuild-git

debian: dpkg
ubuntu: dpkg

.PHONY: list all pkgbuild dpkg arch debian ubuntu
