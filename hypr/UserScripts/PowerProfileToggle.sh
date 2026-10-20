#!/usr/bin/env bash
# ==================================================
#  Hyprland Power Profile Switcher
#  - Performance: 144Hz, smooth animations, blur & shadow ON
#  - Battery Saver: 60Hz, animations & blur & shadow OFF
# ==================================================

set -euo pipefail

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hypr_power_profile"

get_primary_monitor() {
    local mon
    mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name // empty')
    if [ -n "$mon" ] && [ "$mon" != "null" ]; then
        echo "$mon"
    else
        echo "eDP-1"
    fi
}

get_current_profile() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "performance"
    fi
}

set_performance() {
    local monitor
    monitor=$(get_primary_monitor)
    hyprctl eval 'hl.config({ ["animations.enabled"] = true, ["decoration.blur.enabled"] = true, ["decoration.shadow.enabled"] = true }); hl.monitor({ output = "'"$monitor"'", mode = "1920x1080@144", position = "auto", scale = "1" })' >/dev/null 2>&1
    echo "performance" > "$STATE_FILE"
    notify-send -u low -a "Power Profile" -i "video-display" \
        "🚀 Turbo Performance Active" \
        "144Hz Refresh Rate | Fluid Animations | Blur & Shadows ON"
}

set_battery() {
    local monitor
    monitor=$(get_primary_monitor)
    hyprctl eval 'hl.config({ ["animations.enabled"] = false, ["decoration.blur.enabled"] = false, ["decoration.shadow.enabled"] = false }); hl.monitor({ output = "'"$monitor"'", mode = "1920x1080@60", position = "auto", scale = "1" })' >/dev/null 2>&1
    echo "battery" > "$STATE_FILE"
    notify-send -u low -a "Power Profile" -i "battery-good-charging" \
        "🔋 Battery Saver Active" \
        "60Hz Refresh Rate | Animations & Blur OFF | Maximum Efficiency"
}

toggle_profile() {
    local current
    current=$(get_current_profile)
    if [ "$current" = "battery" ]; then
        set_performance
    else
        set_battery
    fi
}

show_menu() {
    local current
    current=$(get_current_profile)
    
    local perf_marker=""
    local batt_marker=""
    if [ "$current" = "performance" ]; then
        perf_marker="  [Active]"
    else
        batt_marker="  [Active]"
    fi
    
    local options="🚀 Turbo Performance (144Hz, Full Visuals)${perf_marker}\n🔋 Battery Saver (60Hz, Minimal Power, Visuals OFF)${batt_marker}"
    
    local rofi_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-menu.rasi"
    if [ ! -f "$rofi_config" ]; then
        rofi_config="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config-menu.rasi"
    fi

    local choice
    choice=$(echo -e "$options" | rofi -dmenu -i -p "Power Profile" \
        -config "$rofi_config" \
        -theme-str 'window { width: 680px; } listview { columns: 1; lines: 2; }' 2>/dev/null || true)
    
    case "$choice" in
        *"Turbo Performance"*)
            set_performance
            ;;
        *"Battery Saver"*)
            set_battery
            ;;
    esac
}

case "${1:-toggle}" in
    --performance|performance|-p)
        set_performance
        ;;
    --battery|battery|-b)
        set_battery
        ;;
    --toggle|toggle|-t)
        toggle_profile
        ;;
    --menu|menu|-m)
        show_menu
        ;;
    --status|status|-s)
        get_current_profile
        ;;
    *)
        toggle_profile
        ;;
esac
