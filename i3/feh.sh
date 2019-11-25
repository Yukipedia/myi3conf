#! /bin/bash

# The wallpaper directory
wallpaperDir=$HOME/Pictures/wallhaven
delimiter="x"

xrandr_output=$(xrandr --listmonitors 2>&1)
monitors=$(echo $xrandr_output | awk '{split($0, s, " "); print s[2]}')
echo "$xrandr_output"
xrandr_output=$(echo "$xrandr_output" | tr '\n' ' ')

gcd()
{
    if [[ $2 == 0 ]]
	then
        echo $1
    else
        local result=$(gcd $2 $(($1 % $2)))
        echo "$result"
    fi
}

global_rematch() { 
    local s=$1 regex=$2 
    while [[ $s =~ $regex ]]; do 
        echo "${BASH_REMATCH[1]}"
        s=${s#*"${BASH_REMATCH[1]}"}
    done
}

changeAction()
{
    #r=$(echo $xrandr_output | awk '
    #    { match($0, /([0-9]{4}\/[0-9]+x[0-9]{3,4})+/, arr) }
    #    END {print arr[1], arr[2]}
    #')

    regex='([0-9]{4}\/[0-9]+x[0-9]{3,4})'
    r=$(global_rematch "$xrandr_output" "$regex")
    r=$(echo "$r" | tr '\n' ' ')

    IFS=' ' read -r -a rsarr <<< "$r"

    wallpapers=()
    for monitor in $( seq 0 $(($monitors - 1)))
    do
        x=$(echo "${rsarr[monitor]}" | awk '{split($0, s, "/"); print s[1]}')
        y=$(echo "${rsarr[monitor]}" | awk '{split($0, s, "x"); print s[2]}')
        common=$(gcd $x $y)
        ratioX=$((x/common))
        ratioY=$((y/common))

        echo "x = ${x}, y = ${y}, ratio = ${ratioX}:${ratioY}" > /dev/tty

        wallpath="${wallpaperDir}/${ratioX}${delimiter}${ratioY}"
        if [ -d $wallpath ]
        then
            wallpaper=$(find $wallpath -type f | shuf -n 1)
            wallpapers+=("$wallpaper")
        fi
    done

    printf '%s\n' "${wallpapers[@]}" >&2
    fehCMD="feh"
    for i in "${!wallpapers[@]}"
    do
        fehCMD+=" --bg-fill ${wallpapers[i]}"
    done

    eval $fehCMD
}


# kill script if exist.
fehpids=$(ps -A | grep feh.sh)
fehpidsarr=($(echo $fehpids | tr " " "\n"))

for spid in "${fehpidsarr[@]}"
do
    if [ "$spid" != "$$" ]
    then
        kill -9 "$spid" 2>/dev/null && echo "more then one feh.sh running kill pid: $spid."
    fi
done

while true
do
    changeAction
    sleep 900s
done
