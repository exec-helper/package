pkgbuild:
	cd pkgbuild && makepkg -fs

arch-linux: pkgbuild

all: pkgbuild

.PHONY: pkgbuild arch-linux
