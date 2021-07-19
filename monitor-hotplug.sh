#!/bin/sh

xrandr_listmonitors=$(xrandr --listmonitors 2>&1)
monitor_ports=$(echo "$xrandr_listmonitors" | grep -P '\w+-\d*\s' -o | xargs)

readarray -td '' monitor_ports_arr < <(awk '{ gsub(/ /, "\0"); print; }' <<<"$monitor_ports "); unset 'monitor_ports_arr[-1]';

# screen initialize order, 0 stand for primary screen.
#   ↓
# primary  xrandr-identity    sys-identity       mode     pos   rotate  
#   ↓            ↓                 ↓               ↓       ↓      ↓
#   0     :    HDMI-1    :   card0-HDMI-A-2   :1920x1080:0x1080:normal

layout="0:HDMI-1:card0-HDMI-A-2:1920x1080:0x1080:normal
1:HDMI-0:card0-HDMI-A-1:1920x1080:1920x1080:normal
2:DP-3:card0-DP-2:1920x1080:0x0:normal"

readarray -t layout_arr <<<"$layout" 

xrandrCMD="xrandr"

for layout_spec in "${layout_arr[@]}"
do
	readarray -td '' layout_spec_arr < <(awk '{ gsub(/:/, "\0"); print; }' <<<"$layout_spec:"); unset 'layout_spec_arr[-1]';

	layout_primary="${layout_spec_arr[0]}"
	layout_xrandr_identity="${layout_spec_arr[1]}"
	layout_sys_identity="${layout_spec_arr[2]}"
	layout_mode="${layout_spec_arr[3]}"
	layout_pos="${layout_spec_arr[4]}"
	layout_rotate="${layout_spec_arr[5]}"

	isConnect=$(cat "/sys/class/drm/$layout_sys_identity/status")

	if [ "$isConnect" != "connected" ]; then
		xrandrCMD+=" --output $layout_xrandr_identity --off"
		continue
	fi


	if [ "$layout_primary" = "0" ]; then
		xrandrCMD+=" --output $layout_xrandr_identity --primary --mode $layout_mode --pos $layout_pos --rotate $layout_rotate"
	else
		xrandrCMD+=" --output $layout_xrandr_identity --mode $layout_mode --pos $layout_pos --rotate $layout_rotate"
	fi
done

echo "$xrandrCMD"

eval "$xrandrCMD"

# auto restart i3 desktop env
i3-msg restart
