#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="${SCRIPTDIR%/*/*}"
IMGDIR="$BASEDIR/build/tmp/deploy/images/blackbone-board"
TMPDIR="$SCRIPTDIR/.tmp"
BOOTDIR="$TMPDIR/boot"
ROOTFSDIR="$TMPDIR/rootFs"

SDCARD=""
IMAGE=""
UBOOT=""
MLO=""
BOOTPART=""
ROOTPART=""


function fFatal () {
   # $1 -> msg
   echo -e "${RED}[fatal]...$1${NC}"
   exit 1
}

function fInfo() {
   # $1 -> msg
   echo -e "${GREEN}[info]...$1${NC}"
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
    # $1 -> partition
    fInfo "Prepare partitions for $1"
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
    ) | sudo fdisk $1
    
    [[ -e $1"p1" ]] && BOOTPART=$1"p1" || BOOTPART=$1"1"
    [[ -e $1"p2" ]] && ROOTPART=$1"p2" || ROOTPART=$1"2"
    
    [[ -e $BOOTPART ]] && sudo mkfs.vfat  -F 16 -n "boot" $BOOTPART || fFatal "Partition not found $BOOTPART"
    fInfo "Boot partition created"
    [[ -e $ROOTPART ]] && sudo mke2fs -j -L "root" $ROOTPART || fFatal "Partition not found $ROOTPART"
    fInfo "Root partition created"
    
}

# Check deploy-image dir
[ -d $IMGDIR ] || fFatal "Not found $IMGDIR"

# Init script env
fInit
fInfo "Welcome in BlackBone tools (note: auto-completion works)"

# Select vars
cd /dev/
read -e -p "Select SD-Card for example /dev/mmcblk0(sdX): " SDCARD
cd $IMGDIR
read -e -p "Select image archive for example blackbone-image-minimal.tar.xz: " IMAGE
read -e -p "Select u-boot image  for example u-boot.img: " UBOOT
read -e -p "Select Memory LOader for example MLO: " MLO

# Prepare SD-Card partitions
fMakeSD $SDCARD

fInfo "Mount partitions"
sudo mount $BOOTPART $BOOTDIR
sudo mount $ROOTPART $ROOTFSDIR

cd $IMGDIR
fInfo "Copy $UBOOT"
sudo cp $UBOOT $BOOTDIR/MLO
fInfo "Copy $MLO"
sudo cp $MLO $BOOTDIR/u-boot.img
fInfo "Copy $IMAGE"
sudo tar xpf $IMAGE -C $ROOTFSDIR
sync

fInfo "Umount partitions"
sudo umount $BOOTDIR
sudo umount $ROOTFSDIR

exit 0
