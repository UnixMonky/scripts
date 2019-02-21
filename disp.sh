#!/bin/bash


if [[ -z $1 ]]; then
    echo "No argument supplied. exiting..."
    exit
fi
CMD=$1

case $CMD in
    "all")
        xrandr --output eDP-1 --auto --output DP-2-2 --auto --right-of eDP-1 --output DP-3-1 --auto --right-of DP-2-2
        ;;
    "laptop")
        xrandr --output eDP-1 --auto --output DP-2-2 --off --output DP-3-1 --off
        ;;
    "external")
        xrandr --output eDP-1 --off
        ;;
esac
