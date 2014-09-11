CC = gcc
DEFS = -D_GNU_SOURCE
CFLAGS = -Os
LDFLAGS =-s

PROGS = tr trinstall
SCRIPTS = selectgcc selectprog

%: %.c
	$(CC) $(DEFS) $(CFLAGS) $(LDFLAGS) -o $@ $<

all: $(PROGS)

trinstall: install.c
	$(CC) $(DEFS) $(CFLAGS) $(LDFLAGS) -o $@ $<

install: all
	install -d -m 755 "$(DESTDIR)/usr/bin"
	install -m 755 $(PROGS) $(SCRIPTS) "$(DESTDIR)/usr/bin"
	ln -sf trinstall "$(DESTDIR)/usr/bin/install"

clean:
	rm -f $(PROGS)
