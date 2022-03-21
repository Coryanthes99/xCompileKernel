#!/bin/bash
#
# Compile script for QuicksilveR kernel
# Copyright (C) 2020-2021 Adithya R.
SECONDS=0 # builtin bash timer
DATE="$(TZ=Asia/Jakarta date)"
ZIPNAME="Orchid-Q-Surya-$(TZ=Asia/Jakarta date '+%Y%m%d-%H%M').zip"
SDC_DIR="$HOME/tc/sdclang"
GCC_DIR="$HOME/tc/gcc"
GCC64_DIR="$HOME/tc/gcc64"
AK3_DIR="$HOME/android/AnyKernel3"
DEFCONFIG="surya-perf_defconfig"
CHATID="-1001719821334"
TOKEN="5136571256:AAEVb6wcnHbB358erxRQsP4crhW7zNh_7p8"
COMMIT_HEAD="$(git log --pretty=format:'"%h : %s"' -1)"
KERVER="$(make kernelversion)"

export PATH="${SDC_DIR}/compiler/bin:${GCC64_DIR}/bin:${GCC_DIR}/bin:/usr/bin:${PATH}"

if ! [ -d "$SDC_DIR" ]; then
echo "Proton clang not found! Cloning to $SDC_DIR..."
if ! git clone -b main --depth=1 https://gitlab.com/AnggaR96s/clang-gengkapak $SDC_DIR; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

<!--
if ! [ -d "$GCC64_DIR" ]; then
echo "GCC 64 not found! Cloning to $GCC64_DIR..."
if ! git clone https://github.com/mvaisakh/gcc-arm64 -b gcc-master --depth=1 $GCC64_DIR; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

if ! [ -d "$GCC_DIR" ]; then
echo "GCC not found! Cloning to $GCC_DIR..."
if ! git clone https://github.com/mvaisakh/gcc-arm -b gcc-master --depth=1 $GCC_DIR; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi-->

export KBUILD_BUILD_USER=FakeRiz
export KBUILD_BUILD_HOST=Umbrella-CI

if [[ $1 = "-r" || $1 = "--regen" ]]; then
make O=out ARCH=arm64 $DEFCONFIG savedefconfig
cp out/defconfig arch/arm64/configs/$DEFCONFIG
exit
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
rm -rf out
fi

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\nStarting compilation...\n"

# Your Telegram Group
   curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHATID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>🔨 Building Kernel Started</b>%0ADATE : <code>${DATE}</code>%0AKERNEL VERSION : <code>${KERVER}</code>%0ABUILDER NAME : <code>${KBUILD_BUILD_USER}</code>%0ABUILDER HOST : <code>${KBUILD_BUILD_HOST}</code>%0ACLANG VERSION : <code>$(${SDC_DIR}/compiler/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0ACOMMIT : <code>${COMMIT_HEAD}</code>"

make -j$(nproc --all) O=out ARCH=arm64 LD_LIBRARY_PATH="${SDC_DIR}/lib:${LD_LIBRARY_PATH}" CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-android- CROSS_COMPILE_ARM32=arm-linux-androideabi- CLANG_TRIPLE=aarch64-linux-gnu- Image.gz-dtb dtbo.img

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "out/arch/arm64/boot/dtbo.img" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"
if [ -d "$AK3_DIR" ]; then
cp -r $AK3_DIR AnyKernel3
elif ! git clone -q https://github.com/ghostrider-reborn/AnyKernel3; then
echo -e "\nAnyKernel3 repo not found locally and cloning failed! Aborting..."
exit 1
fi
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3
cp out/arch/arm64/boot/dtbo.img AnyKernel3
rm -f *zip
cd AnyKernel3
git checkout master &> /dev/null
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
cd ..
rm -rf AnyKernel3
rm -rf out/arch/arm64/boot
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"
if ! [[ $HOSTNAME = "Umbrella-CI" && $USER = "FakeRiz" ]]; then
curl -F document=@$ZIPNAME "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$CHATID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="✅ Build Completed : $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)!"
fi
else
echo -e "\nCompilation failed!"
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHATID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="❌ Build throw an error(s) : $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
exit 1
fi
\
