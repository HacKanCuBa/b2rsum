PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

all:
	@echo "b2rsum is a shell script, so there is nothing to do. Try \"make install\" instead."

install:
	@install -v -d "$(DESTDIR)$(MANDIR)/man1" && install -m 0644 -v man/b2rsum.1 "$(DESTDIR)$(MANDIR)/man1/b2rsum.1"
	@install -v -d "$(DESTDIR)$(BINDIR)/"
	install -v -d "$(DESTDIR)$(BINDIR)/" && install -m 0755 -v src/b2rsum.bash "$(DESTDIR)$(BINDIR)/b2rsum"

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(BINDIR)/b2rsum" \
		"$(DESTDIR)$(MANDIR)/man1/b2rsum.1"

TESTS = $(sort $(wildcard tests/t[0-9][0-9][0-9][0-9]-*.sh))

test: $(TESTS)

$(TESTS):
	@$@ $(B2RSUM_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/

lint:
	shellcheck -s bash src/b2rsum.bash

.PHONY: install uninstall test clean lint $(TESTS)
