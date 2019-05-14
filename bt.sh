#!/bin/bash

if [[ -z $1 ]]; then
    echo "No argument supplied. exiting..."
    exit
fi

## get array of all known monitors
# mapfile -t DISP < <( xrandr --listmonitors | grep -v "^Monitors" | awk '{print $4}' )
# mapfile -t DISP < <( xrandr --current | grep " conn" | grep -v "^eDP" | awk '{print $1}' )

usage() { echo "Usage: $0 [a|a2dp|h|headset|r|reset]"; exit 1; }

num=0
while [[ -n $1 ]]; do
  opt="$1"
  case $opt in
    a|a2dp )     SINK="a2dp_sink";;
    h|headset )  SINK="headset_head_unit";;
    r|reset )    RESET=1; FLIP=1 SINK=$(pactl info | grep "Default Sink" | awk -F. '{print $NF}');;
    f|flip )     FLIP=1; SINK=$(pactl info | grep "Default Sink" | awk -F. '{print $NF}');;
    *)           usage;;
  esac
  shift
done

BLUEZCARD=$(pactl list cards short | egrep -o bluez.*[[:space:]])
[[ ${SINK} == "a2dp_sink" ]] && ALTSINK="headset_head_unit" || ALTSINK="a2dp_sink"
[[ ${FLIP} ]] && pactl set-card-profile $BLUEZCARD ${ALTSINK}
[[ ${RESET} ]] && pactl set-card-profile $BLUEZCARD ${SINK}
