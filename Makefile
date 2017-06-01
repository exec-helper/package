pkgbuild:
	cd pkgbuild && makepkg -fs --noconfirm --needed

dpkg:
	# Install the build deps
	yes | sudo mk-build-deps -i
	dpkg-buildpackage -jauto -us -uc

arch-linux: pkgbuild

debian: dpkg

ubuntu: dpkg

all: pkgbuild dpkg

.PHONY: pkgbuild dpkg arch-linux debian ubuntu
