#!/bin/bash
##################################################################
#Set up linux kernel on MACCHIATObin for Edge Infrastructure     #
#This script not support cross-compilation                       #
##################################################################

# Hardcoded Paths
export ROOTDIR=${PWD}

# Hardcoded Build_param
export ARCH=arm64

# Parameter Overridable Paths
export KDIR=${ROOTDIR}/kernel/4.14.22
export MUSDK_PATH=${ROOTDIR}/musdk
export DEFCONFIG_MCBIN=${ROOTDIR}/defconfig-mcbin-edge

echo -e "Please run shell script as root!"

# Check file defconfig-mcbin-edge
if [ ! -f "$DEFCONFIG_MCBIN" ]; then
    echo -e "\tPlease copy defconfig-mcbin-edge to currently directory!"
    exit 1
fi


# Download Kernel Source
echo -e "Download marvell linux 18.09..."
mkdir -p $KDIR
cd $KDIR || exit
#touch kernel-test
git clone https://github.com/MarvellEmbeddedProcessors/linux-marvell .
git checkout linux-4.14.22-armada-18.09
cd $ROOTDIR || exit

# Download MUSDK Package
echo -e "Download MUSDK package 18.09..."
mkdir -p $MUSDK_PATH
cd $MUSDK_PATH || exit
#touch musdk-test
git clone https://github.com/MarvellEmbeddedProcessors/musdk-marvell .
git checkout musdk-armada-18.09

#Patch kernel
cd $KDIR || exit
echo -e "Patch kernel..."
#touch patch_kernel
git am $MUSDK_PATH/patches/linux-4.14/*.patch

# Check file defconfig-mcbin-edge
if [ ! -f "$DEFCONFIG_MCBIN" ]; then
    echo -e "\tPlease copy defconfig-mcbin-edge to $ROOTDIR!"
    exit 1
fi


# Build Kernel
echo -e "Backup mvebu_v8_lsp_defconfig"
mv $KDIR/arch/arm64/configs/mvebu_v8_lsp_defconfig $KDIR/arch/arm64/configs/mvebu_v8_lsp_defconfig.bac
echo -e "Replease kernel config by defconfig-mcbin-edge"
cp $DEFCONFIG_MCBIN $KDIR/arch/arm64/configs/mvebu_v8_lsp_defconfig
echo -e "Build Kernel..."
make mvebu_v8_lsp_defconfig
make -j$(($(nproc)+1))

#Install Kernel
echo -e "Install Kernel..."
make modules_install
cp ./arch/arm64/boot/Image /boot/
cp ./arch/arm64/boot/dts/marvell/armada-8040-mcbin.dtb  /boot/
sync

echo -e "Success! Please reboot!"
