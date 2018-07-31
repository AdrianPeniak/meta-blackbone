SUMMARY = "BeagleBone Black image"
LICENSE = "CLOSED"

require images/blackbone-image-minimal.bb

IMAGE_FEATURES += "package-management debug-tweaks"

IMAGE_INSTALL += "mc"
    
export IMAGE_BASENAME = "blackbone-image"
