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
    r|reset )    RESET=1; SINK=$(pactl info | grep "Default Sink" | awk -F. '{print $NF}');;
  esac
  shift
done

BLUEZCARD=$(pactl list cards short | egrep -o bluez.*[[:space:]])
if [[ ${RESET} ]]; then
  [[ ${SINk} == "a2dp_sink" ]] && ALTSINK="headset_head_unit" || ALTSUNK="a2dp_sink"
  pactl set-card-profile $BLUEZCARD ${SINK}
  sleep 1
  pactl set-card-profile $BLUEZCARD ${ALTSINK}
  sleep 1
fi
pactl set-card-profile $BLUEZCARD ${SINK}
