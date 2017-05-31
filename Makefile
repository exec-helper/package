pkgbuild:
	cd pkgbuild && makepkg -fs

dpkg:
	dpkg-buildpackage -jauto

arch-linux: pkgbuild

debian: dpkg

ubuntu: dpkg

all: pkgbuild dpkg

.PHONY: pkgbuild dpkg arch-linux debian ubuntu
