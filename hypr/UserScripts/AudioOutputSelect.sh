#!/usr/bin/env python3
# ==================================================
#  Hyprland Audio Output Switcher
#  Fast & clean sink switcher for PipeWire/WirePlumber
# ==================================================

import os
import re
import subprocess
import sys


def get_sinks():
  try:
    out = subprocess.check_output(['wpctl', 'status'], text=True)
  except Exception as e:
    subprocess.run(['notify-send', '-u', 'critical', 'Audio Error', str(e)])
    sys.exit(1)

  lines = out.splitlines()
  in_sinks = False
  sinks = []

  for line in lines:
    if 'Sinks:' in line:
      in_sinks = True
      continue
    if in_sinks:
      if any(k in line for k in ['Sources:', 'Filters:', 'Streams:']):
        break
      if not line.strip():
        continue
      m = re.search(r'([*]?)\s*(\d+)\.\s+([^\[]+)', line)
      if m:
        is_active = '*' in m.group(1)
        sink_id = m.group(2)
        raw_name = m.group(3).strip()
        sinks.append(
            {'id': sink_id, 'raw_name': raw_name, 'is_active': is_active}
        )

  return sinks


def format_sink(sink):
  raw = sink['raw_name']
  active_tag = '  [✓ Active]' if sink['is_active'] else ''

  # Categorize and generate clean, human-friendly titles
  if any(
      k in raw.lower()
      for k in [
          'wh-ch',
          'bluez',
          'bluetooth',
          'headphone',
          'buds',
          'airpods',
          'wireless',
      ]
  ):
    icon = '🎧'
    clean_name = raw.replace('bluez_output.', '').replace('_', ' ')
    display = f'Bluetooth: {clean_name}'
  elif 'speaker' in raw.lower():
    icon = '🔊'
    display = 'Built-in Laptop Speakers'
  elif 'hdmi' in raw.lower() or 'displayport' in raw.lower():
    icon = '📺'
    m = re.search(r'HDMI\s*/\s*DisplayPort\s*(\d+)', raw, re.IGNORECASE)
    if m:
      display = f'HDMI / DisplayPort {m.group(1)} Output'
    else:
      m2 = re.search(r'HDMI\s*(\d+)', raw, re.IGNORECASE)
      if m2:
        display = f'HDMI {m2.group(1)} Output'
      else:
        display = 'HDMI / External Display Audio'
  elif 'headphones' in raw.lower() or 'headset' in raw.lower():
    icon = '🎧'
    display = 'Wired Headphones (3.5mm)'
  else:
    icon = '🔈'
    display = raw

  menu_label = f'{icon}  {display}{active_tag}'
  return menu_label, sink['id'], display


def main():
  sinks = get_sinks()
  if not sinks:
    subprocess.run([
        'notify-send',
        '-u',
        'normal',
        'Audio Switcher',
        'No audio outputs found.',
    ])
    return

  # Sorting priority:
  # 1. Currently active sink
  # 2. Bluetooth headphones
  # 3. Built-in speakers
  # 4. HDMI / other
  def sort_key(s):
    name = s['raw_name'].lower()
    if s['is_active']:
      return 0
    if any(k in name for k in ['wh-ch', 'bluetooth', 'headphone', 'buds']):
      return 1
    if 'speaker' in name:
      return 2
    return 3

  sinks.sort(key=sort_key)

  menu_lines = []
  id_map = {}

  for s in sinks:
    label, s_id, short_name = format_sink(s)
    menu_lines.append(label)
    id_map[label] = (s_id, short_name)

  input_data = '\n'.join(menu_lines)

  home = os.environ.get('HOME', '')
  rofi_config = os.path.join(
      os.environ.get('XDG_CONFIG_HOME', f'{home}/.config'),
      'hypr/rofi/config-menu.rasi',
  )
  if not os.path.isfile(rofi_config):
    rofi_config = os.path.join(
        os.environ.get('XDG_CONFIG_HOME', f'{home}/.config'),
        'rofi/config-menu.rasi',
    )

  num_lines = min(len(menu_lines), 6)
  rofi_cmd = [
      'rofi',
      '-dmenu',
      '-i',
      '-p',
      'Audio Output',
      '-config',
      rofi_config,
      '-theme-str',
      f'window {{ width: 700px; }} listview {{ columns: 1; lines:'
      f' {num_lines}; }}',
  ]

  try:
    proc = subprocess.Popen(
        rofi_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    choice, _ = proc.communicate(input=input_data)
    choice = choice.strip()
  except Exception:
    return

  if not choice or choice not in id_map:
    return

  selected_id, short_name = id_map[choice]

  # Set default sink in PipeWire
  subprocess.run(['wpctl', 'set-default', selected_id])

  # Send desktop notification
  icon_name = 'audio-headphones' if '🎧' in choice else 'audio-speakers'
  subprocess.run([
      'notify-send',
      '-u',
      'low',
      '-a',
      'Audio Switcher',
      '-i',
      icon_name,
      'Audio Output Switched',
      f'Now playing through: {short_name}',
  ])


if __name__ == '__main__':
  main()
