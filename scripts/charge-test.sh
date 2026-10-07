#!/system/bin/sh
BAT=/sys/class/power_supply/battery
restore() {
  echo 1 > "$BAT/charging_enabled" 2>/dev/null || true
  echo 1 > "$BAT/battery_charging_enabled" 2>/dev/null || true
}
trap restore EXIT
snap() {
  printf "status=%s capacity=%s current=%s charging_enabled=%s battery_charging_enabled=%s\n" \
    "$(cat $BAT/status)" "$(cat $BAT/capacity)" "$(cat $BAT/current_now)" \
    "$(cat $BAT/charging_enabled)" "$(cat $BAT/battery_charging_enabled)"
}
echo "BASE $(snap)"
echo 0 > "$BAT/charging_enabled"
sleep 3
echo "AFTER charging_enabled=0 $(snap)"
echo 1 > "$BAT/charging_enabled"
sleep 3
echo "RESTORED charging_enabled $(snap)"
echo 0 > "$BAT/battery_charging_enabled"
sleep 3
echo "AFTER battery_charging_enabled=0 $(snap)"
restore
sleep 3
echo "FINAL $(snap)"
