PREFIX ?= /usr
DESTDIR ?=
THEME_NAME ?= custom-sddm
INSTALL_DIR ?= $(DESTDIR)$(PREFIX)/share/sddm/themes/$(THEME_NAME)

.PHONY: all install uninstall test

all:
	@echo "SDDM Sugar Candy Theme"
	@echo "Run 'make install' to install the theme to $(INSTALL_DIR)"
	@echo "Run 'make uninstall' to remove the theme from $(INSTALL_DIR)"
	@echo "Run 'make test' to preview the theme with sddm-greeter"

install:
	@if [ -d "$(INSTALL_DIR)" ] && [ "$(FORCE)" != "1" ]; then \
		echo "Error: Directory $(INSTALL_DIR) already exists!"; \
		echo "Use 'make uninstall' first, or run 'make install FORCE=1' to overwrite."; \
		exit 1; \
	fi
	install -d $(INSTALL_DIR)
	cp -r Assets Backgrounds Components Previews $(INSTALL_DIR)/
	install -m 644 Main.qml metadata.desktop theme.conf AUTHORS COPYING README.md CHANGELOG.md $(INSTALL_DIR)/

uninstall:
	rm -rf $(INSTALL_DIR)

test:
	sddm-greeter --test-mode --theme .
