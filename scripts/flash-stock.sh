#!/bin/bash
# Flash official tissot V10.0.24.0.PDHMIXM without locking the bootloader.
# userdata.img in the package is an 18.6 GiB filesystem (32 GB SKU). This
# phone's userdata partition is ~50 GiB, so format that instead.
set -u
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMG=$ROOT/firmware/tissot_images_V10.0.24.0.PDHMIXM_9.0/images
LOG=$ROOT/firmware/flash-stock.log
exec > >(tee -a "$LOG") 2>&1

echo "=== $(date -Is) flash stock V10.0.24.0.PDHMIXM ==="
command -v fastboot
command -v mke2fs

echo "=== reboot bootloader ==="
adb reboot bootloader
ok=0
for _ in $(seq 1 40); do
  if fastboot devices 2>/dev/null | grep -q 'fastboot\|[0-9a-f]'; then
    ok=1
    break
  fi
  sleep 1
done
fastboot devices
if [ "$ok" -ne 1 ]; then
  echo "device did not enter fastboot"
  exit 1
fi

echo "=== preflight ==="
prod=$(fastboot getvar product 2>&1 || true)
info=$(fastboot oem device-info 2>&1 || true)
unlocked=$(fastboot getvar unlocked 2>&1 || true)
echo "$prod"
echo "$unlocked"
fastboot getvar anti 2>&1 || true
fastboot getvar current-slot 2>&1 || true
fastboot getvar version-bootloader 2>&1 || true
echo "$info"

echo "$prod" | grep -E "product: *tissot" >/dev/null || {
  echo "refusing to flash: product is not tissot"
  fastboot reboot || true
  exit 1
}
if ! printf '%s\n%s\n' "$info" "$unlocked" | grep -Ei "unlocked: *(true|yes)" >/dev/null; then
  echo "refusing to flash: bootloader is locked"
  fastboot reboot || true
  exit 1
fi

flash() {
  echo "=== $(date -Is) fastboot $* ==="
  if ! fastboot "$@"; then
    echo "FAILED: fastboot $*"
    exit 1
  fi
}

flash erase boot_a
flash flash modem_a "$IMG/modem.img"
flash flash modem_b "$IMG/modem.img"
flash flash sbl1 "$IMG/sbl1.img"
flash flash sbl1bak "$IMG/sbl1.img"
flash flash rpm "$IMG/rpm.img"
flash flash rpmbak "$IMG/rpm.img"
flash flash tz "$IMG/tz.img"
flash flash tzbak "$IMG/tz.img"
flash flash devcfg "$IMG/devcfg.img"
flash flash devcfgbak "$IMG/devcfg.img"
flash flash dsp "$IMG/dsp.img"
flash flash sec "$IMG/sec.dat"
flash flash splash "$IMG/splash.img"
flash flash misc "$IMG/misc.img"
flash flash aboot "$IMG/emmc_appsboot.mbn"
flash flash abootbak "$IMG/emmc_appsboot.mbn"
flash flash boot_a "$IMG/boot.img"
flash flash boot_b "$IMG/boot.img"
flash flash system_a "$IMG/system.img"
flash flash system_b "$IMG/system_other.img"
flash flash lksecapp "$IMG/lksecapp.img"
flash flash lksecappbak "$IMG/lksecapp.img"
flash flash cmnlib "$IMG/cmnlib.img"
flash flash cmnlibbak "$IMG/cmnlib.img"
flash flash cmnlib64 "$IMG/cmnlib64.img"
flash flash cmnlib64bak "$IMG/cmnlib64.img"
flash flash keymaster "$IMG/keymaster.img"
flash flash keymasterbak "$IMG/keymaster.img"

# Partition is 53829147136 bytes. Stock fstab reserves 16 KiB for the FDE footer.
echo "=== format userdata to 53829130752 bytes ==="
if ! fastboot format:ext4:53829130752 userdata; then
  echo "format failed; erasing userdata instead"
  flash erase userdata
fi

flash set_active a
echo "=== reboot $(date -Is) ==="
fastboot reboot
echo "=== flash commands finished $(date -Is) ==="
