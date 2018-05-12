#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="${SCRIPTDIR%/*/*}"
IMGDIR="$BASEDIR/build/tmp/deploy/images/blackbone-board"
TMPDIR="$SCRIPTDIR/.tmp"
BOOTDIR="$TMPDIR/boot"
ROOTFSDIR="$TMPDIR/rootFs"

MMCPATH="/dev/mmcblk1"

SYSTEMPARTITION=""
IMAGE=""
UBOOT=""
MLO=""
BOOTPART=""
ROOTPART=""
VAR=0

[ "$1" == "debug" ] && set -x

function fFatal () {
   # $1 -> msg
   echo -e "${RED}[fatal]...$1${NC}"
   exit 1
}

function fInfo() {
   # $1 -> msg
   echo -e "${GREEN}[info]...$1${NC}"
}

function fWarn() {
   # $1 -> msg
   echo -e "${YELLOW}[warn]...$1${NC}"
}

function fInit() {
    if [ -d $TMPDIR ] ; then 
        fInfo "Cleaning TMP dir $TMPDIR"
        rm -rf $TMPDIR/*
    else
        fInfo "Creating TMP dir $TMPDIR"
        mkdir $TMPDIR
    fi
    
    cd $TMPDIR
    mkdir $BOOTDIR
    mkdir $ROOTFSDIR
    
    [ -f /etc/bash_completion ] && . /etc/bash_completion    
}

function fMakeSD() {
    # $1 -> SYSTEMPARTITION
    fInfo "Prepare SD-Card partitions for $1"
    (
    # Boot
    echo o       # Create a new empty DOS partition table
    echo p       #verify the partition table
    echo n       # Add a new partition
    echo p       # Primary partition
    echo 1       # Partition number
    echo         # First sector (Accept default)
    echo +72261K # Last sector
    echo t       # Change the partition type
    echo c       # Partition type W95 FAT32 (LBA)
    echo a       # Set the partition bootable
    #echo 1       # Number of bootable partition
    # RootFS
    echo n       # Add a new partition
    echo p       # Primary partition
    echo 2       # Partition number
    echo         # First sector (Accept default)
    echo         # Last sector (Accept default)
    echo p       # Print the partition table
    echo w       # Write changes
    ) | fdisk $1
    sleep 1
}

function fMakeMMC() {
    # $1 -> SYSTEMPARTITION
    fInfo "Prepare eMMC partitions for $1"
    (
    # Boot
    echo o       # Create a new empty DOS partition table
    echo p       #verify the partition table
    echo n       # Add a new partition
    echo p       # Primary partition
    echo 1       # Partition number
    echo         # First sector (Accept default)
    echo +72261K # Last sector
    echo t       # Change the partition type
    echo c       # Partition type W95 FAT32 (LBA)
    echo a       # Set the partition bootable
    echo 1       # Number of bootable partition
    # RootFS
    echo n       # Add a new partition
    echo p       # Primary partition
    echo 2       # Partition number
    echo         # First sector (Accept default)
    echo         # Last sector (Accept default)
    echo p       # Print the partition table
    echo w       # Write changes
    ) | fdisk $1
    sleep 2
}

function fMakeFS() {
    # $1 -> SYSTEMPARTITION
    if [ "$VAR" -ne "0" ] ; then
        fMakeSD $1
    else
        fMakeMMC $1
    fi
    
    [[ -e $1"p1" ]] && BOOTPART=$1"p1" || BOOTPART=$1"1"
    [[ -e $1"p2" ]] && ROOTPART=$1"p2" || ROOTPART=$1"2"
    
    [[ -e $BOOTPART ]] && mkfs.vfat  -F 16 -n "boot" $BOOTPART || fFatal "Partition not found $BOOTPART"
    fInfo "Boot partition created"
    [[ -e $ROOTPART ]] && mke2fs -F -j -L "root" $ROOTPART || fFatal "Partition not found $ROOTPART"
    fInfo "Root partition created"
}

# TODO
function checkIntegritySDCard() {
    # $1 -> ROOTFSDIR
    cd $1
    touch $TMPDIR/md5$(date +%s).txt
    for var in $( ls ) ; do
        md5=$(find $var -type f -exec md5sum {} \; | sort -k 2 | md5sum)
        fInfo "write MD5 for $var [$md5]"
        echo "$var'=\"'$md5'\"'" >> $TMPDIR/md5$(date +%s).txt
    done
}

function fPrepareMMCinstall() {
    cd $ROOTFSDIR
    fInfo "Prepare MMC installation"
    [ -d $ROOTFSDIR/var/bonablackTools ] || mkdir $ROOTFSDIR/var/bonablackTools
    cp $SCRIPTDIR/blackbone-tools.sh $ROOTFSDIR/etc/init.d/blackbone-tools
    chmod +x $ROOTFSDIR/etc/init.d/blackbone-tools
    
    cd $ROOTFSDIR/etc/rc1.d/ 
    ln -sf ../init.d/blackbone-tools K02blackbone-tools
    cd $ROOTFSDIR/etc/rc2.d/
    ln -sf ../init.d/blackbone-tools S02blackbone-tools
    cd $ROOTFSDIR/etc/rc3.d/
    ln -sf ../init.d/blackbone-tools S02blackbone-tools
    cd $ROOTFSDIR/etc/rc4.d/
    ln -sf ../init.d/blackbone-tools S02blackbone-tools
    cd $ROOTFSDIR/etc/rc5.d/
    ln -sf ../init.d/blackbone-tools S02blackbone-tools
    
    cd $ROOTFSDIR/var/bonablackTools
    cp $UBOOT .
    cp $MLO .
    cp $IMAGE .
    
    echo "IMAGE=\"$IMAGE\"" > env.txt
    echo "UBOOT=\"$UBOOT\"" >> env.txt
    echo "MLO=\"$MLO\"" >> env.txt
    
    sync
}

function fWriteImage() {
    # $1 -> SYSTEMPARTITION
    # Prepare SD-Card partitions
    fMakeFS $1

    fInfo "Mount partitions"
    mount $BOOTPART $BOOTDIR
    mount $ROOTPART $ROOTFSDIR

    [ -d $IMGDIR ] && cd $IMGDIR
    fInfo "Copy $UBOOT"
    cp $UBOOT $BOOTDIR/u-boot.img
    fInfo "Copy $MLO"
    cp $MLO $BOOTDIR/MLO
    fInfo "Copy $IMAGE"
    tar xpf $IMAGE -C $ROOTFSDIR
    sync

    [ $VAR -eq 2 ] && fPrepareMMCinstall
    
    fInfo "Umount partitions"
    umount -l $BOOTDIR
    umount -l $ROOTFSDIR
}

function fInstallOption() {
    if [ -e "/etc/init.d/blackbone-tools" ] && [ -e  $MMCPATH ] ; then
        echo "Do you want write image to MMC, if not press key (in 3 sec)"
        read -n 1 -t 3 tmp
        [ $? -eq 0 ] || return
    fi
    while [ true ] ; do
        echo "Do you want write image for: "
        echo "1: SD-Card" 
        echo "2: MMC"
        read -n 1 VAR
        [ "$VAR" == "1" ] || [ "$VAR" == "2" ] && break
    done
    echo
}

function fGetAndCheckFullPath() {
    # $1 -> file
    [ -e "${!1}" ] || fFatal "Not found ${!1} !"
    eval ${1}="$(realpath ${!1})"
    [ -e "${!1}" ] || fFatal "Not found ${!1} !!!"
    echo ${!1}
}

###
# main
###
[ -d $IMGDIR ] || fWarn "Not found $IMGDIR, you have to use full path for files!"

fInit
fInfo "Welcome in BlackBone tools (note: auto-completion works)"

fInstallOption
if [ $VAR -ne 0 ] ; then
    cd /dev/
    read -e -p "Select SD-Card for example /dev/mmcblk0(sdX): " SYSTEMPARTITION
    if [ -d $IMGDIR ] ; then 
        cd $IMGDIR
    else
        cd $SCRIPTDIR
    fi
    read -e -p "Select image archive for example blackbone-image-minimal.tar.xz: " IMAGE
    read -e -p "Select u-boot image  for example u-boot.img: " UBOOT
    read -e -p "Select Memory LOader for example MLO: " MLO
else
    [ -e "/var/bonablackTools/env.txt" ] || fFatal "Not found /var/bonablackTools/env.txt"
    source /var/bonablackTools/env.txt
    SYSTEMPARTITION="$MMCPATH"
    IMAGE="/var/bonablackTools/${IMAGE##*/}"
    UBOOT="/var/bonablackTools/${UBOOT##*/}"
    MLO="/var/bonablackTools/${MLO##*/}"
fi

fInfo "Check files:"
fGetAndCheckFullPath SYSTEMPARTITION
fGetAndCheckFullPath IMAGE
fGetAndCheckFullPath UBOOT
fGetAndCheckFullPath MLO
fWriteImage $SYSTEMPARTITION


if [ "$VAR" == "1" ] || [ "$VAR" == "2" ] ; then
    fInfo "SD-Card finished"
else
    fInfo "MMC finished"
    halt
fi

exit 0
