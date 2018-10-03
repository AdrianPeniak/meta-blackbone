SUMMARY = "BeagleBone Black image"
LICENSE = "CLOSED"

IMAGE_FEATURES += "package-management"

inherit core-image


IMAGE_INSTALL += "dpkg"

export IMAGE_BASENAME = "blackbone-image"
