#/bin/bash
# 为了编译iphone 和 支持videotoolbox 视频
#最终生成的头文件和库在$PWD/universal文件下
set -e
ROOT=$PWD
#echo $ROOT
#生成配置文件
echo "#define PJ_CONFIG_IPHONE 1\n#define PJMEDIA_HAS_VIDEO 1\n#include <pj/config_site_sample.h>\n" > "$PWD/pjlib/include/pj/config_site.h"
ARCHS="armv7 arm64 x86_64"
CFLAGS=""
LDFLAGS=""
MIN_IOS=""
echo "" > a.sh
rm -rf $PWD/output
for ARCH in $ARCHS
do
if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
then
    PLATFORM="iPhoneSimulator"
    MIN_IOS=""
    if [ "$ARCH" = "i386" ];then
        CFLAGS="-O2 -m32 -mios-simulator-version-min=8.0"
        LDFLAGS="-O2 -m32 -mios-simulator-version-min=8.0"
    else
        CFLAGS="-O2 -m64 -mios-simulator-version-min=8.0"
        LDFLAGS="-O2 -m64 -mios-simulator-version-min=8.0"
    fi
 else
    PLATFORM="iPhoneOS"
    MIN_IOS="-miphoneos-version-min=8.0"
    CFLAGS=""
    LDFLAGS=""
 fi
 XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
 CC=`xcrun --sdk ${XCRUN_SDK} --show-sdk-path`
 CC=${CC%/*}
 CC=${CC%/*}
 if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
then
    CMD="DEVPATH=\"${CC}\" ARCH=\"-arch ${ARCH}\" CFLAGS=\"${CFLAGS}\" LDFLAGS=\"${LDFLAGS}\" ./configure-iphone --with-ssl=${ROOT%/*}/openssl-1.1.1/output/${ARCH} --prefix=${ROOT}/output/${ARCH}"
else
    CMD="DEVPATH=\"${CC}\" ARCH=\"-arch ${ARCH}\" MIN_IOS=\"${MIN_IOS}\" ./configure-iphone --with-ssl=${ROOT%/*}/openssl-1.1.1/output/${ARCH} --prefix=${ROOT}/output/${ARCH}"
fi
echo $CMD >> a.sh
echo "make clean && make dep && make -j8 && make install" >> a.sh
#make dep && make -j8 && make install
done
source ./a.sh
LIBS="libg7221codec libgsmcodec libilbccodec libpj libpjlib-util libpjmedia-audiodev libpjmedia-codec libpjmedia-videodev libpjmedia libpjnath libpjsip-simple libpjsip-ua libpjsip libpjsua libpjsua2 libresample libspeex libsrtp libwebrtc libyuv"
for LIB in $LIBS
do
mkdir -p $PWD/output/universal/lib
SOURCE="lipo "
for ARCH in $ARCHS
do
SOURCE=${SOURCE}"-arch "${ARCH}" $PWD/output/${ARCH}/lib/"${LIB}"-"${ARCH}"-apple-darwin_ios.a "
done
CMD=$SOURCE" -create -output $PWD/output/universal/lib/"${LIB}".a"
$CMD
done
cp -rf $PWD/output/arm64/include $PWD/output/universal