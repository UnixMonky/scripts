#!/bin/bash

#xrandr --output eDP-1 --auto --output DP-2-2 --auto --right-of eDP-1 --output DP-3-1 --auto --right-of DP-2-2

if [[ -z $1 ]]; then
    echo "No argument supplied. exiting..."
    exit
fi

## get array of all known monitors
mapfile -t DISPLAY < <( xrandr --listmonitors | grep -v "^Monitors" | awk '{print $4}' )

usage() { echo "Usage: $0 [-a] [-o #,#,#]" 1>&2; exit 1; }

while getopts ":ao:" o; do
    case "${o}" in
        a)  mapfile -t ORDER < <( seq 0 $((${#DISPLAY[*]}-1)) );;
        o)  mapfile -t ORDER < <( echo ${OPTARG} | sed 's/,/\n/g' );;
        *)  usage;;
    esac
done
shift $((OPTIND-1))

echo $(IFS=',';echo "[DBG] \$ORDER=${ORDER[*]// /|}";IFS=$'')
CMD="xrandr "
NOTFIRST=true
for O in ${ORDER[@]}; do
    echo "[DBG] \$O=$O"
    CMD+=" --output ${DISPLAY[$O]} --auto"
    ${NOTFIRST} && CMD+=" --right-of ${DISPLAY[${ORDER[$((O-1))]}]}"
    NOTFIRST=false
done
echo "$CMD"
#$CMD