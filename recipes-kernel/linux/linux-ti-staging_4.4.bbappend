FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-bbb-pru0.patch"

do_install_append() {
   cd ${D}/boot
   ln -sf ./devicetree-zImage-am335x-bone.dtb  ./devicetree.dtb
}

KERNEL_MODULE_AUTOLOAD += "g_serial"
