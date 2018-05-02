SUMMARY = "Connman config to setup wired interface on qemu machines"
DESCRIPTION = "This is the ConnMan configuration to set up a Wired \
network interface for a qemu machine."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://settings \
           file://main.conf \
                         "
PR = "r2"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN} = "${localstatedir}/* ${sysconfdir}/*"

do_install() {
    #Configure Wired network interface in case of qemu* machines
    install -d ${D}${localstatedir}/lib/connman
    install -m 0644 ${WORKDIR}/settings ${D}${localstatedir}/lib/connman
    #install -m 0644 ${WORKDIR}/*.config ${D}${localstatedir}/lib/connman

    install -d ${D}${sysconfdir}/connman
    install -m 0644 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman
}
