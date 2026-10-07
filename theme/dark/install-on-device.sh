#!/system/bin/sh
set -eu
SRC=/data/local/tmp/tissot-dark
DST=/data/adb/modules/tissot-dark
rm -rf "$DST"
mkdir -p "$DST"
cp -a "$SRC/module.prop" "$DST/module.prop"
mkdir -p "$DST/system/vendor/overlay"
cp -a "$SRC/system/vendor/overlay/FrameworkDark" "$DST/system/vendor/overlay/FrameworkDark"
cp -a "$SRC/system/vendor/overlay/SystemUIDark" "$DST/system/vendor/overlay/SystemUIDark"
rm -f "$DST/system/vendor/overlay/FrameworkDark/"*.idsig
rm -f "$DST/system/vendor/overlay/SystemUIDark/"*.idsig
chmod 755 "$DST" "$DST/system" "$DST/system/vendor" "$DST/system/vendor/overlay"
chmod 755 "$DST/system/vendor/overlay/FrameworkDark" "$DST/system/vendor/overlay/SystemUIDark"
chmod 644 "$DST/module.prop" "$DST/system/vendor/overlay/FrameworkDark/"*.apk "$DST/system/vendor/overlay/SystemUIDark/"*.apk
chown -R root:root "$DST"
# Drop a previous copy cleanly on the next boot.
rm -f "$DST/disable" "$DST/remove"
ls -laR "$DST"
