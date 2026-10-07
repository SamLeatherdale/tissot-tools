#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SDK=${ANDROID_SDK_ROOT:-/home/linuxbrew/.linuxbrew/share/android-commandlinetools}
AAPT=$SDK/build-tools/${BUILD_TOOLS:-36.0.0}/aapt
APKSIGNER=$SDK/build-tools/${BUILD_TOOLS:-36.0.0}/apksigner
ANDROID_JAR=$SDK/platforms/${PLATFORM:-android-36}/android.jar
KS=$ROOT/debug.keystore
OUT=$ROOT/module/system/vendor/overlay

if [ ! -f "$KS" ]; then
  keytool -genkeypair -keystore "$KS" -storepass android -keypass android \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

build() {
  name=$1
  src=$2
  dest=$3
  rm -rf "$ROOT/build/$name"
  mkdir -p "$ROOT/build/$name" "$dest"
  "$AAPT" package -f -M "$src/AndroidManifest.xml" -S "$src/res" \
    -I "$ANDROID_JAR" -F "$ROOT/build/$name/unsigned.apk"
  "$APKSIGNER" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
    --out "$dest/$(basename "$dest").apk" "$ROOT/build/$name/unsigned.apk"
}

rm -rf "$OUT"
mkdir -p "$OUT"
build framework "$ROOT/framework" "$OUT/FrameworkDark"
build systemui "$ROOT/systemui" "$OUT/SystemUIDark"
find "$OUT" -type f -print
