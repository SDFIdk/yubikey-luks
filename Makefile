info:
	@echo "builddeb [NO_SIGN=1]  - build deb package for Ubuntu LTS [NO_SIGN disables signing]"
	@echo "clean                 - clean build directory DEBUILD"
	@echo "ppa-dev               - upload to ppa launchpad. Development"
	@echo "ppa                   - upload to ppa launchpad. Stable"

VERSION=0.5.1
SRC_DIR = yubikey-luks-${VERSION}

debianize:
	rm -fr DEBUILD
	mkdir -p DEBUILD/${SRC_DIR}
	cp -r * DEBUILD/${SRC_DIR} || true
	(cd DEBUILD; tar -zcf yubikey-luks_${VERSION}.orig.tar.gz --exclude=${SRC_DIR}/debian  ${SRC_DIR})

builddeb:
	make debianize
ifndef NO_SIGN
	(cd DEBUILD/${SRC_DIR}; debuild)
else
	(cd DEBUILD/${SRC_DIR}; debuild -uc -us)
endif

ppa-dev:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea-dev DEBUILD/yubikey-luks_${VERSION}-?_source.changes

ppa:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea DEBUILD/yubikey-luks_${VERSION}-?_source.changes

clean:
	rm -fr DEBUILD

install:
	install -D -o root -g root -m755 hook $(DESTDIR)$(PREFIX)/share/initramfs-tools/hooks/yubikey-luks
	install -D -o root -g root -m755 key-script $(DESTDIR)$(PREFIX)/share/yubikey-luks/ykluks-keyscript
	install -D -o root -g root -m755 yubikey-luks-open $(DESTDIR)$(PREFIX)/bin/yubikey-luks-open
	install -D -o root -g root -m755 yubikey-luks-enroll $(DESTDIR)$(PREFIX)/bin/yubikey-luks-enroll
	install -D -o root -g root -m644 yubikey-luks-enroll.1 $(DESTDIR)$(PREFIX)/man/man1/yubikey-luks-enroll.1
	install -D -o root -g root -m644 README.md $(DESTDIR)$(PREFIX)/share/doc/yubikey-luks/README.md
	install -D -o root -g root -m644 ykluks.cfg $(DESTDIR)/etc/ykluks.cfg
	install -D -o root -g root -m755 yubikey-luks-suspend $(DESTDIR)$(PREFIX)/lib/yubikey-luks/yubikey-luks-suspend
	install -D -o root -g root -m755 initramfs-suspend $(DESTDIR)$(PREFIX)/lib/yubikey-luks/initramfs-suspend
	install -D -o root -g root -m644 yubikey-luks-suspend.service $(DESTDIR)$(PREFIX)/lib/systemd/system/yubikey-luks-suspend.service

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/yubikey-luks-open \
		$(DESTDIR)$(PREFIX)/bin/yubikey-luks-enroll \
		$(DESTDIR)$(PREFIX)/share/yubikey-luks/ykluks-keyscript \
		$(DESTDIR)$(PREFIX)/share/initramfs-tools/hooks/yubikey-luks \
		$(DESTDIR)$(PREFIX)/man/man1/yubikey-luks-enroll.1 \
		$(DESTDIR)$(PREFIX)/share/doc/yubikey-luks/README.md \
		$(DESTDIR)/etc/ykluks.cfg \
		$(DESTDIR)$(PREFIX)/lib/yubikey-luks/yubikey-luks-suspend \
		$(DESTDIR)$(PREFIX)/lib/yubikey-luks/initramfs-suspend \
		$(DESTDIR)$(PREFIX)/lib/systemd/systme/yubikey-luks-suspend.service

