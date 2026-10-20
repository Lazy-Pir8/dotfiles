#!/usr/bin/env bash
# ==================================================
#  Hyprland Screen Shader Switcher
#  Applies GPU shaders (vibrance, blue light, grayscale, invert)
# ==================================================

set -euo pipefail

SHADER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/shaders"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hypr_current_shader"

get_current() {
    if [ -f "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    else
        echo "off"
    fi
}

apply_shader() {
    local name="$1"
    local file=""
    local desc=""
    local icon=""

    case "$name" in
        vibrance)
            file="$SHADER_DIR/vibrance.frag"
            desc="🎨 Digital Vibrance Boost (+35% Saturation)"
            icon="preferences-desktop-display"
            ;;
        night|blue-light-filter)
            file="$SHADER_DIR/blue-light-filter.frag"
            desc="🌙 Night Light (Warm Amber Eye Saver)"
            icon="weather-clear-night"
            name="night"
            ;;
        grayscale|mono)
            file="$SHADER_DIR/grayscale.frag"
            desc="☕ Grayscale Focus Mode (Monochrome)"
            icon="view-paged"
            name="grayscale"
            ;;
        invert)
            file="$SHADER_DIR/invert.frag"
            desc="🌓 Inverted Colors (High Contrast)"
            icon="format-stroke-color"
            name="invert"
            ;;
        off|none|"")
            hyprctl eval 'hl.config({ ["decoration.screen_shader"] = "" })' >/dev/null 2>&1
            echo "off" > "$CACHE_FILE"
            notify-send -u low -a "Screen Shader" -i "display" "Screen Shaders Disabled" "Display returned to default colors."
            return 0
            ;;
        *)
            notify-send -u normal -a "Screen Shader" "Unknown Shader" "$name"
            return 1
            ;;
    esac

    if [ -f "$file" ]; then
        hyprctl eval 'hl.config({ ["decoration.screen_shader"] = "'"$file"'" })' >/dev/null 2>&1
        echo "$name" > "$CACHE_FILE"
        notify-send -u low -a "Screen Shader" -i "$icon" "$desc" "Shader loaded successfully."
    else
        notify-send -u critical -a "Screen Shader" "Shader file missing" "$file"
    fi
}

toggle_shader() {
    local cur
    cur=$(get_current)
    if [ "$cur" = "off" ]; then
        apply_shader "vibrance"
    else
        apply_shader "off"
    fi
}

show_menu() {
    local cur
    cur=$(get_current)

    local mark_off=""
    local mark_vib=""
    local mark_night=""
    local mark_gray=""
    local mark_inv=""

    case "$cur" in
        vibrance) mark_vib="  [Active]" ;;
        night) mark_night="  [Active]" ;;
        grayscale) mark_gray="  [Active]" ;;
        invert) mark_inv="  [Active]" ;;
        *) mark_off="  [Active]" ;;
    esac

    local options="❌ Normal Colors (Disable Shaders)${mark_off}\n🎨 Digital Vibrance (+35% Color Boost)${mark_vib}\n🌙 Night Light (Warm Amber Eye Saver)${mark_night}\n☕ Grayscale Focus Mode (Monochrome)${mark_gray}\n🌓 Invert Colors (High Contrast)${mark_inv}"

    local rofi_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-menu.rasi"
    if [ ! -f "$rofi_config" ]; then
        rofi_config="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config-menu.rasi"
    fi

    local choice
    choice=$(echo -e "$options" | rofi -dmenu -i -p "Screen Shader" \
        -config "$rofi_config" \
        -theme-str 'window { width: 680px; } listview { columns: 1; lines: 5; }' 2>/dev/null || true)

    case "$choice" in
        *"Normal Colors"*)
            apply_shader "off"
            ;;
        *"Digital Vibrance"*)
            apply_shader "vibrance"
            ;;
        *"Night Light"*)
            apply_shader "night"
            ;;
        *"Grayscale Focus"*)
            apply_shader "grayscale"
            ;;
        *"Invert Colors"*)
            apply_shader "invert"
            ;;
    esac
}

case "${1:-toggle}" in
    --vibrance|vibrance)
        apply_shader "vibrance"
        ;;
    --night|night)
        apply_shader "night"
        ;;
    --grayscale|grayscale|--mono)
        apply_shader "grayscale"
        ;;
    --invert|invert)
        apply_shader "invert"
        ;;
    --off|off)
        apply_shader "off"
        ;;
    --toggle|toggle)
        toggle_shader
        ;;
    --menu|menu|-m)
        show_menu
        ;;
    --status|status)
        get_current
        ;;
    *)
        toggle_shader
        ;;
esac
