pkgbuild:
	cd pkgbuild && makepkg -fs --noconfirm --needed

dpkg:
	# Install the build deps
	yes | sudo mk-build-deps -i
	rm exec-helper-build-deps_*_all.deb

	# Generate the changelog
	dpkg/write_changelog.sh

	dpkg-buildpackage -jauto -us -uc

arch-linux: pkgbuild

debian: dpkg

ubuntu: dpkg

all: pkgbuild dpkg

.PHONY: pkgbuild dpkg arch-linux debian ubuntu
