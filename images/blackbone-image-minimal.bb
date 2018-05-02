SUMMARY = "BeagleBone Black image minimal"
LICENSE = "CLOSED"

IMAGE_FEATURES += "ssh-server-openssh package-management debug-tweaks"

inherit core-image


IMAGE_INSTALL += "\
    openssh openssh-keygen openssh-sftp-server \
    python3-modules python3-pip python3-flask python3-netifaces \
    ntp \
    mc nano iptables htop findutils \
    kernel-modules load-modules \
"
    
export IMAGE_BASENAME = "blackbone-image-minimal"
