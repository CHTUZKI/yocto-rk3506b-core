# make install leaves a 0-byte ssh-keygen in ${D}; reinstall from ${B}
do_install:append() {
	install -m 0755 ${B}/ssh-keygen ${D}${bindir}/ssh-keygen
}
