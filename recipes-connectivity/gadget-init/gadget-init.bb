# This recipe is based on the recipe by Koen in meta-texasinstruments
DESCRIPTION = "Scripts to initialize usb gadgets"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

RDEPENDS_${PN}="devmem2 bash"

COMPATIBLE_MACHINE = "(ti33x)"
PACKAGE_ARCH = "${MACHINE_ARCH}"


PR = "r3"

SRC_URI = "file://gadget_init \
           file://gadget-init.sh"

inherit update-rc.d
INITSCRIPT_NAME = "gadget_init"
INITSCRIPT_PARAMS = "start 50 5 . stop 50 0 1 6 ."


do_install() {
    install -d ${D}${sysconfdir}/init.d/
    install -m 755 ${WORKDIR}/gadget_init ${D}${sysconfdir}/init.d/
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/*.sh ${D}${bindir}
}

FILES_${PN} = "${sysconfdir} ${bindir}"

RRECOMMENDS_${PN} = "kernel-module-g-ether"
