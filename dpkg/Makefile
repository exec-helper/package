SOURCE_DIR=../exec-helper
EXEC_HELPER_DEPS=exec-helper/CMakeLists.txt
CHANGELOG_FILE=debian/changelog

VERSION=$(shell git -C $(SOURCE_DIR) describe 2>/dev/null || echo "UNKNOWN")
DISTRIBUTION=$(shell lsb_release --codename --short)
COMMIT=$(shell git submodule | sed "s/[- ]\([0-9a-f]*\) .*$$/\1/g")
COMMIT=134567

all: dpkg

$(EXEC_HELPER_DEPS):
	cp -r ../exec-helper .

$(CHANGELOG_FILE):
	cp debian/changelog.in $(CHANGELOG_FILE)

write-changelog: $(CHANGELOG_FILE)
	sed -i "s/@VERSION@/$(VERSION)-$(COMMIT)/g" $(CHANGELOG_FILE)
	sed -i "s/@PACKAGE@/exec-helper/g" $(CHANGELOG_FILE)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(CHANGELOG_FILE)

check-build-deps:
	yes | sudo mk-build-deps -i

dpkg:: $(EXEC_HELPER_DEPS) write-changelog check-build-deps
	dpkg-buildpackage -jauto -us -uc

clean:
	$(MAKE) -f debian/rules clean
	rm -f $(EXEC_HELPER_DEPS)
	rm -f $(CHANGELOG_FILE)

.PHONY: write-changelog check-build-deps dpkg clean all
