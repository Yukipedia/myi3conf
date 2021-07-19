#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

monitors=($(polybar --list-monitors | cut -d":" -f1))

for m in "${monitors[@]}"; do
	echo "$m"
	export MONITOR=$m
	export TRAY_POSITION=none
	if [[ "$m" == "HDMI-1" ]] && [[ "${#monitors[@]}" != "1" ]]; then
		TRAY_POSITION=right
	fi
	# If only one monitor
	# system tray will always shown
	if [[ "${#monitors[@]}" == "1" ]]; then
		TRAY_POSITION=right
	fi
    polybar -q --reload main -c ~/.config/polybar/config.ini &
done

# Launch bar1 and bar2
#polybar main -c ~/.config/polybar/config.ini &
