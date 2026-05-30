CC     ?= cc

PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

TARGET  := windows
MANPAGE := windows.1

WAYLAND_SCANNER   := $(shell pkg-config --variable=wayland_scanner wayland-scanner)
WAYLAND_PROTOCOLS := $(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_HEADER    := \
	fractional-scale-v1-protocol.h  \
	viewporter-protocol.h \
	xdg-shell-protocol.h \
	ext-foreign-toplevel-list-v1-protocol.h \
	ext-image-capture-source-v1-protocol.h \
	ext-image-copy-capture-v1-protocol.h
WAYLAND_INTERFACE := \
	fractional-scale-v1-protocol.c \
	viewporter-protocol.c \
	xdg-shell-protocol.c \
	ext-foreign-toplevel-list-v1-protocol.c \
	ext-image-capture-source-v1-protocol.c \
	ext-image-copy-capture-v1-protocol.c

SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)
DEPS := $(SRCS:.c=.d)

CFLAGS += \
	$(shell pkg-config --cflags wayland-client) \
	$(shell pkg-config --cflags xkbcommon) \
	$(shell pkg-config --cflags cairo)
LDLIBS += \
	$(shell pkg-config --libs wayland-client) \
	$(shell pkg-config --libs xkbcommon) \
	$(shell pkg-config --libs cairo)

fractional-scale-v1-protocol.h: \
	$(WAYLAND_PROTOCOLS)/staging/fractional-scale/fractional-scale-v1.xml
	$(WAYLAND_SCANNER) client-header $< $@

fractional-scale-v1-protocol.c: \
	$(WAYLAND_PROTOCOLS)/staging/fractional-scale/fractional-scale-v1.xml
	$(WAYLAND_SCANNER) private-code $< $@

viewporter-protocol.h: \
	$(WAYLAND_PROTOCOLS)/stable/viewporter/viewporter.xml
	$(WAYLAND_SCANNER) client-header $< $@

viewporter-protocol.c: \
	$(WAYLAND_PROTOCOLS)/stable/viewporter/viewporter.xml
	$(WAYLAND_SCANNER) private-code $< $@

xdg-shell-protocol.h: \
	$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml
	$(WAYLAND_SCANNER) client-header $< $@

xdg-shell-protocol.c: \
	$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml
	$(WAYLAND_SCANNER) private-code $< $@

ext-foreign-toplevel-list-v1-protocol.h: \
	$(WAYLAND_PROTOCOLS)/staging/ext-foreign-toplevel-list/ext-foreign-toplevel-list-v1.xml
	$(WAYLAND_SCANNER) client-header $< $@

ext-foreign-toplevel-list-v1-protocol.c: \
	$(WAYLAND_PROTOCOLS)/staging/ext-foreign-toplevel-list/ext-foreign-toplevel-list-v1.xml
	$(WAYLAND_SCANNER) private-code $< $@

ext-image-capture-source-v1-protocol.h: \
	$(WAYLAND_PROTOCOLS)/staging/ext-image-capture-source/ext-image-capture-source-v1.xml
	$(WAYLAND_SCANNER) client-header $< $@

ext-image-capture-source-v1-protocol.c: \
	$(WAYLAND_PROTOCOLS)/staging/ext-image-capture-source/ext-image-capture-source-v1.xml
	$(WAYLAND_SCANNER) private-code $< $@

ext-image-copy-capture-v1-protocol.h: \
	$(WAYLAND_PROTOCOLS)/staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml
	$(WAYLAND_SCANNER) client-header $< $@

ext-image-copy-capture-v1-protocol.c: \
	$(WAYLAND_PROTOCOLS)/staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml
	$(WAYLAND_SCANNER) private-code $< $@

$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDLIBS) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.d: %.c $(WAYLAND_HEADER) $(WAYLAND_INTERFACE)
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

install: $(TARGET)
	@echo "Installing executable to $(DESTDIR)$(PREFIX)/bin"
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/$(TARGET)
#
	@echo "Installing manual page to $(DESTDIR)$(MANPREFIX)/man1"
	@mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	@install -m 644 $(MANPAGE) $(DESTDIR)$(MANPREFIX)/man1/$(MANPAGE)

uninstall:
	@echo "Removing executable from $(DESTDIR)$(PREFIX)/bin"
	@rm -f $(DESTDIR)$(PREFIX)/bin/$(TARGET)
#
	@echo "Removing manual page from $(DESTDIR)$(MANPREFIX)/man1"
	@rm -f $(DESTDIR)$(MANPREFIX)/man1/$(MANPAGE)

-include $(DEPS)

.PHONY: clean install uninstall
clean:
	rm -f $(OBJS) $(DEPS) $(TARGET) $(WAYLAND_HEADER) $(WAYLAND_INTERFACE)

.DEFAULT_GOAL := $(TARGET)
