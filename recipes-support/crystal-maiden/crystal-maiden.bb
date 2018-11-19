SUMMARY = "crystal maiden script"
DESCRIPTION = "crystal maiden provide several system commands during boot process"
HOMEPAGE = ""
SECTION = "console/utils"
LICENSE = "CLOSED"


DEPENDS = ""

SRC_URI = "file://crystal-maiden.sh"
S = "${WORKDIR}"

INITSCRIPT_NAME = "crystal-maiden"
INITSCRIPT_PARAMS = "start 10 5 . stop 50 0 1 6 ."

do_install_append() {
    install -d ${D}/${sysconfdir}/init.d/
    install -m 755 ${S}/crystal-maiden.sh ${D}/${sysconfdir}/init.d/crystal-maiden
}

inherit update-rc.d
