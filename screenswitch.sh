#!/bin/bash
# set -x

readarray -t displayList < <( autorandr | grep -v "^$" | awk '{print $1}' | sort)
displayList+=( "${displayList[@]}" )
currentName=$(autorandr --current)
[[ -z ${currentName} ]] && currentName="lid"
for i in "${!displayList[@]}"; do
    [[ "${displayList[$i]}" == "${currentName}" ]] && currentIndex=${i} && break
done

res=999
j=$((currentIndex+1))
while [[ ${res} != 0 && ${j} < ${#displayList[@]} ]]; do
    case ${displayList[ji]} in
        ext|docked ) output="0x11";;
        *)           output="0x0F";;
    esac
    autorandr -l ${displayList[$j]}
    res=$?
    [[ -z $res ]] && ddcutil --model=XZ322QU setvcp 60 ${output}
    j=$((j+1))
done
