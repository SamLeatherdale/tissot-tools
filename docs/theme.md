# Dark system theme

A dark system UI for stock Android 9. It replaces the stock light palette with dark surfaces and light text in Settings, the notification shade, dialogs, and toasts.

It does not use Substratum. The theme is two static resource overlays shipped as a Magisk module. Android 9 enables static overlays on its own. Apps that draw their own light screens stay light. [Battery Charge Limit](battery-charge-limit.md) is one of those.

## Build

You need `aapt`, `apksigner`, and `android.jar` from the Android SDK command-line tools, plus `keytool`.

```sh
export ANDROID_SDK_ROOT=/path/to/android-commandlinetools
export BUILD_TOOLS=36.0.0
export PLATFORM=android-36
theme/dark/build.sh
```

`build.sh` writes a local debug keystore if you do not already have one. That keystore stays on your machine. The signed overlays land in `theme/dark/module/system/vendor/overlay/`. The `.idsig` files next to them are not part of the module.

## Install

The phone needs Magisk and root over adb. From the repo root, with the phone connected:

```sh
adb shell rm -rf /data/local/tmp/tissot-dark
adb push theme/dark/module /data/local/tmp/tissot-dark
adb push theme/dark/install-on-device.sh /data/local/tmp/install-tissot-dark.sh
adb shell su -c 'sh /data/local/tmp/install-tissot-dark.sh'
adb reboot
```

Pushing into an existing `/data/local/tmp/tissot-dark` nests a second copy, which the installer will not see. Remove that directory first, as above.

After the first boot, turn night mode on as root. The overlay allows it, but the stock build keeps day/night locked against the normal shell command, so the setting would otherwise stay off and notification buttons and icons stay dark on the dark shade:

```sh
adb shell su -c 'cmd uimode night yes'
```

That setting persists. Also disable the stock System UI overlay. It only replaces one color and comes back enabled often enough to fight this theme:

```sh
adb shell su -c 'cmd overlay disable --user 0 com.android.systemui.theme.dark'
```

If a bad overlay prevents boot, Magisk safe mode (hold volume down) disables modules.
