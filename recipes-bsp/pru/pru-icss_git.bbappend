do_install_append_ti33x() {
    install -d ${D}/${includedir}
    install -m 644 ${S}/include/*.h ${D}/${includedir}
    install -m 644 ${S}/include/am335x/*.h ${D}/${includedir}
}

FILES_${PN}-dev = "${includedir}"
