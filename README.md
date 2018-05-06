# meta-blackbone
Recipes for the Beaglebone Black supporting PRU (RPMsg)

# Prepare build machine
```shell
sudo apt install build-essential chrpath diffstat gawk libncurses5-dev texinfo git
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
MACHINE = "blackbone-board"
DISTRO  = "blackbone-distro"
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

# Create an SD-Card for BeagleBone Black
Please use script "blackbone-tools.sh" in scripts directory.
Or prepare your SD-Card by yourself according [this tutorial.](https://github.com/linneman/planck/wiki/How-to-create-a-Boot-SD-Card-for-the-BeagleBone-black)
And then copy "MLO and u-boot" files to boot partition:
```
sudo cp MLO u-boot.img /media/<username>/boot/
```
and write root file system to SD-Card:
```
sudo dd if=<image name>.ext3 of=/dev/<root fs>
```

meta-blackbone layer maintainer: Adrian Peniak -> adrian(at)peniak(dot)com
