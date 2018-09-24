#!/bin/bash

BLUEZCARD=$(pactl list cards short | egrep -o bluez.*[[:space:]])
pactl set-card-profile $BLUEZCARD a2dp_sink
sleep 1
pactl set-card-profile $BLUEZCARD headset_head_unit
sleep 1
pactl set-card-profile $BLUEZCARD a2dp_sink
