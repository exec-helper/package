SOURCE_DIR=../exec-helper
EXEC_HELPER_DEPS=exec-helper/CMakeLists.txt

CHANGELOG_FILE=debian/changelog
CHANGELOG_IN:=$(CHANGELOG_FILE).in
CHANGELOG_TEMP_TEMPLATE:=$(CHANGELOG_FILE).tmp
CHANGELOG_TEMP:=$(shell mktemp --dry-run $(CHANGELOG_TEMP_TEMPLATE).XXX)

VERSION:=$(shell git -C $(SOURCE_DIR) describe --long "--match=*.*.*" 2>/dev/null || git -C $(SOURCE_DIR) -n1 --pretty=format:%h)
DISTRIBUTION:=$(shell lsb_release --codename --short)

all: build

$(EXEC_HELPER_DEPS):
	cp -r ../exec-helper .

$(CHANGELOG_FILE): $(CHANGELOG_IN)
	cp $(CHANGELOG_IN) $(CHANGELOG_TEMP)
	sed -i "s/@VERSION@/$(VERSION)/g" $(CHANGELOG_TEMP)
	sed -i "s/@PACKAGE@/exec-helper/g" $(CHANGELOG_TEMP)
	sed -i "s/@DISTRIBUTION@/$(DISTRIBUTION)/g" $(CHANGELOG_TEMP)
	mv $(CHANGELOG_TEMP) $(CHANGELOG_FILE)

check-build-deps:
	yes | sudo mk-build-deps -i

prepare: $(CHANGELOG_FILE)

build:: $(EXEC_HELPER_DEPS) prepare check-build-deps
	dpkg-buildpackage -jauto -us -uc

clean:
	$(MAKE) -f debian/rules clean || true
	rm -f $(EXEC_HELPER_DEPS)
	rm -f $(CHANGELOG_FILE)
	rm -f $(CHANGELOG_TEMP_TEMPLATE)*
	rm -f ../exec-helper*.dsc
	rm -f ../exec-helper*.tar.gz
	rm -f ../exec-helper*.changes
	rm -f ../exec-helper*.deb

.PHONY: write-changelog check-build-deps dpkg clean all
