SUMMARY = "BeagleBone Black image ROFS"
LICENSE = "CLOSED"

require images/blackbone-image-minimal.bb

EXTRA_IMAGE_FEATURES += "read-only-rootfs"
IMAGE_INSTALL += "crystal-maiden"

export IMAGE_BASENAME = "blackbone-image-rofs"
