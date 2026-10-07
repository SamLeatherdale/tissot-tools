# tissot-tools

Tools for the Xiaomi Mi A1 (tissot) on stock Android 9.

- [Dark system theme](docs/theme.md). A Magisk module that replaces the stock light system palette. It does not use Substratum, and it does not theme apps that draw their own light screens.
- [Battery Charge Limit](docs/battery-charge-limit.md). How to stop charging at a set percentage. On this phone the working switch is `/sys/class/power_supply/battery/charging_enabled`.

`scripts/flash-stock.sh` flashes official V10.0.24.0.PDHMIXM from `firmware/` without locking the bootloader. It formats userdata for a 64 GB Mi A1 instead of writing the 32 GB userdata image in Xiaomi's package.
