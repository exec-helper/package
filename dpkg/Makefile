SOURCE_DIR=../exec-helper
EXEC_HELPER_DEPS=exec-helper/CMakeLists.txt
CHANGELOG_FILE=debian/changelog

GIT_DESCRIBE=$(shell git -C $(SOURCE_DIR) describe --long 2>/dev/null || echo "UNKNOWN")
MAJOR_VERSION=$(shell echo $(GIT_DESCRIBE) | sed "s/\(.*\)-.*-.*$$/\1/g" -)
COMMIT=$(shell git -C $(SOURCE_DIR) log -n1 --format=%h)
COMMIT_COUNT=$(shell git -C $(SOURCE_DIR) rev-list --count HEAD)
DISTRIBUTION=$(shell lsb_release --codename --short)

VERSION=$(MAJOR_VERSION)-$(COMMIT_COUNT)-git$(COMMIT)

all: dpkg

$(EXEC_HELPER_DEPS):
	cp -r ../exec-helper .

$(CHANGELOG_FILE):
	cp debian/changelog.in $(CHANGELOG_FILE)

write-changelog: $(CHANGELOG_FILE)
	sed -i "s/@VERSION@/$(VERSION)/g" $(CHANGELOG_FILE)
	sed -i "s/@PACKAGE@/exec-helper/g" $(CHANGELOG_FILE)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(CHANGELOG_FILE)

check-build-deps:
	yes | sudo mk-build-deps -i

prepare: write-changelog

build:: $(EXEC_HELPER_DEPS) prepare check-build-deps
	dpkg-buildpackage -jauto -us -uc

clean:
	$(MAKE) -f debian/rules clean || true
	rm -f $(EXEC_HELPER_DEPS)
	rm -f $(CHANGELOG_FILE)
	rm -f ../exec-helper*.dsc
	rm -f ../exec-helper*.tar.gz
	rm -f ../exec-helper*.changes
	rm -f ../exec-helper*.deb

.PHONY: write-changelog check-build-deps dpkg clean all
