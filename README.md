# meta-blackbone
Recipes for the Beaglebone Black supporting PRU (RPMsg)

# Prepare build machine
```shell
sudo apt install build-essential chrpath diffstat gawk libncurses5-dev texinfo git libc6-i386
```

# Clone required repos
```shell
git clone -b morty git://git.yoctoproject.org/poky.git poky-morty
cd poky-morty
git clone -b morty git://git.openembedded.org/meta-openembedded
git clone -b morty git://git.yoctoproject.org/meta-ti
git clone -b morty https://github.com/AdrianPeniak/meta-blackbone.git
```

# Environment Setup
```shell
source oe-init-build-env
```
In to use this layer please comment-out default machine "MACHINE ??= "qemux86""
in generated file ./conf/local.conf and add following lines at the end of the file:
```
-  MACHINE ??= "qemux86"
+  #MACHINE ??= "qemux86"
+  MACHINE = "blackbone-board"
+  DISTRO  = "blackbone-distro"
```

Optionaly you can choose OPKG (instead of default RPM) packaging systems, 
for avoid python 2.7 runtime dependencies, by replacing "package_rpm" by "package_ipk":
```
-  PACKAGE_CLASSES ?= "package_rpm"
+  PACKAGE_CLASSES ?= "package_ipk"
```

Also plase remove "meta-yocto-bsp" layer from generated file ./conf/bblayers.conf
and add following meta layers to the list:
```
-  <some path>/poky-morty/meta-yocto-bsp \
+  <some path>/poky-morty/meta-ti \
+  <some path>/poky-morty/meta-blackbone \
+  <some path>/poky-morty/meta-openembedded/meta-oe \
+  <some path>/poky-morty/meta-openembedded/meta-python \
+  <some path>/poky-morty/meta-openembedded/meta-networking \
```

# Building Image
```
bitbake blackbone-image-minimal
```

# Flash an SD-Card/eMMC for BeagleBone Black
Please use script [blackbone-tools.sh](https://github.com/AdrianPeniak/meta-blackbone/blob/master/scripts/blackbone-tools.sh) in scripts directory and follow script instructions.
Run script as sudo:
```
sudo ./blackbone-tools.sh
```
For creation SD-Crard for flash eMMC, you have to chose option 2 in script wizard:
```
Do you want write image for: 
1: SD-Card
2: MMC
2
```
then put your SD-Card to the SD-Card slot on your BeagleBone and holding the S2 switch down for 5 sec, then the BeagleBone will to try booting from the SD-Card first. The S2 switch is above the SD-Card holder
The blackbone-tools script will be automatically launched for the eMMC flashing. When the BeagleBone LEDs stop flashing in cylon-mode, then the eMMC flashing is complete.

Or you can prepare your SD-Card by yourself according [this tutorial.](https://github.com/linneman/planck/wiki/How-to-create-a-Boot-SD-Card-for-the-BeagleBone-black)
And then copy "MLO and u-boot" files to boot partition:
```
sudo cp MLO u-boot.img /media/<username>/boot/
```
and write root file system to SD-Card:
```
sudo dd if=<image name>.ext3 of=/dev/<root fs>
```

meta-blackbone layer maintainer: Adrian Peniak -> adrian(at)peniak(dot)com
