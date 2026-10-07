# Battery Charge Limit

[Battery Charge Limit](https://github.com/sriharshaarangi/BatteryChargeLimit) can hold this phone at a charge percentage. It needs Magisk, because it writes a sysfs switch as root. The latest release is 1.1.1, from 2018, and these steps match that build. A newer build would use the same switch.

The switch that works is:

```text
/sys/class/power_supply/battery/charging_enabled
```

Write `0` to stop charging and `1` to allow it. The app already knows that pair. Leave **Configurable CTRL File Data** off so it uses those values.

The phone also has `/sys/class/power_supply/battery/battery_charging_enabled`, and the app lists a third file under **Xiaomi Mi A1** (`qpnp-smbcharger-18/.../battery_charging_enabled`). That third entry is marked experimental. Use `charging_enabled` instead.

## Set it up

1. Install Battery Charge Limit and open it. Magisk will ask for root when the service starts. Grant it.

   If Magisk says the device needs additional setup, dismiss that prompt. Accepting it writes Magisk into the boot image again.

2. Open **Settings**, then **Set Control File**, and choose `charging_enabled` (`/sys/class/power_supply/battery/charging_enabled`). Leave **Configurable CTRL File Data** off.

3. On the main screen, set the two pickers. The left one is the level where charging stops. The right one is the level where it starts again, and it has to be lower. 80% and 40% is a reasonable pair.

4. Turn on **Enable Battery Charge Limit**. The status line should say whether the battery is charging, and **Control file data** should show:

   ```text
   /sys/class/power_supply/battery/charging_enabled, 1, 0
   ```

The limit switch stays on across a reboot. The app starts its service from `BOOT_COMPLETED`.

## Check the switch

Plug the phone in, then run `scripts/charge-test.sh` on the device as root. It writes `0` to `charging_enabled`, waits, turns charging back on, and tries the other file the same way. Charging is restored when the script exits.

```sh
adb push scripts/charge-test.sh /data/local/tmp/charge-test.sh
adb shell su -c 'sh /data/local/tmp/charge-test.sh'
```

On the `charging_enabled=0` line, charging should stop: status leaves `Charging`, or `current_now` drops off. The matching line for `battery_charging_enabled` is there so you can see that file do nothing useful. After `FINAL`, `charging_enabled` should be `1` again.

With the app enabled and the phone plugged in, the same thing happens at the limit. **Control file data** stays on `charging_enabled`, the value goes to `0`, and the status line shows the battery discharging until it falls to the recharge level.
