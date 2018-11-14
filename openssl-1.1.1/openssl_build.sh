#!/bin/bash
ARCHS="armv7 arm64 x86_64"
for ARCH in $ARCHS
do
    make clean
    rm -rf $PWD/output/$ARCH
    if [ $ARCH = "armv7" -o $ARCH = "arm64" ];then
        export CC=clang
        export CROSS_TOP=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
        export CROSS_SDK=iPhoneOS.sdk
        export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
        if [ $ARCH = "armv7" ];then
            ./Configure ios-cross no-shared no-dso no-hw no-engine --prefix=$PWD/output/$ARCH
        else
            ./Configure ios64-cross no-shared no-dso no-hw no-engine --prefix=$PWD/output/$ARCH
        fi
    else
        unset CC CROSS_TOP CROSS_SDK
        ./Configure iossimulator-xcrun no-shared no-dso no-hw no-engine --prefix=$PWD/output/$ARCH
    fi 
    make -j8 && make install_sw
done
mkdir -p $PWD/output/universal/lib/
CMD="lipo "
CMD1="lipo "
for ARCH in $ARCHS
do
    CMD="${CMD} -arch ${ARCH} ${PWD}/output/$ARCH/lib/libcrypto.a "
    CMD1="${CMD1} -arch ${ARCH} ${PWD}/output/$ARCH/lib/libssl.a "
done
CMD="${CMD} -create -output ${PWD}/output/universal/lib/libcrypto.a"
CMD1="${CMD1} -create -output ${PWD}/output/universal/lib/libssl.a"
$CMD
$CMD1
cp -rf ${PWD}/output/armv7/include $PWD/output/universal/