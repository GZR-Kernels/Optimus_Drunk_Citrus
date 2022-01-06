#!/bin/bash

#set -e

## Copy this script inside the kernel directory
KERNEL_DEFCONFIG=vendor/citrus_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=Optimus_Drunk_Citrus_v11.2.zip
export ARCH=arm64

# Speed up build process
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[1;34m'
yellow='\033[1;33m'
nocol='\033[0m'

# Always do clean build lol
echo -e "$yellow**** Cleaning ****$nocol"
mkdir -p out
make O=out clean

echo -e "$yellow**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****$nocol"
echo -e "$blue***********************************************"
echo "          BUILDING KERNEL          "
echo -e "***********************************************$nocol"
make $KERNEL_DEFCONFIG O=out
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=$KERNELDIR/prebuilts/clang-r437112b/bin/clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=$KERNELDIR/prebuilts/aarch64-linux-android-4.9/bin/aarch64-linux-android- \
                      CROSS_COMPILE_ARM32=$KERNELDIR/prebuilts/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-

echo "$yellow**** Verify Image.gz-dtb ****"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb

# Anykernel 3 time!!
echo "$yellow**** Verifying AnyKernel3 Directory ****"
ls $ANYKERNEL3_DIR
echo "$yellow**** Removing leftovers ****"
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo "$yellow**** Copying Image.gz-dtb****"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/

echo "$yellow**** Time to zip up! ****"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP $KERNELDIR/$FINAL_KERNEL_ZIP

echo "$yellow**** Done, here is your sha1 ****"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf out/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
