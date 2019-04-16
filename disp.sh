#!/bin/bash

#xrandr --output eDP-1 --auto --output DP-2-2 --auto --right-of eDP-1 --output DP-3-1 --auto --right-of DP-2-2

if [[ -z $1 ]]; then
    echo "No argument supplied. exiting..."
    exit
fi

## get array of all known monitors
# mapfile -t DISP < <( xrandr --listmonitors | grep -v "^Monitors" | awk '{print $4}' )
# mapfile -t DISP < <( xrandr --current | grep " conn" | grep -v "^eDP" | awk '{print $1}' )

usage() { echo "Usage: $0 [#,#,#|all|h|help]"; exit 1; }

ORDER=()
mapfile -t DISP < <( xrandr --current | grep " conn" | awk '{print $1}' )

num=0
while [[ -n $1 ]]; do
    opt="$1"
    case $opt in
        all)    mapfile -t ORDER < <( seq 0 $((${#DISP[*]}-1)) ); break;;
        ext)    j=0; for i in "${!DISP[@]}"; do
                    if [[ ! ${DISP[$i]} =~ eDP* ]]; then ORDER[$i]=$j; ((j++)); else ORDER[$i]="x"; fi
                done; break;;
        int)    j=0; for i in "${!DISP[@]}"; do
                    if [[ ${DISP[$i]} =~ eDP* ]]; then ORDER[$i]=$j; ((j++)); else ORDER[$i]="x"; fi
                done; break;;
        list)   for i in "${!DISP[@]}"; do echo "$i: ${DISP[$i]}"; done; exit; break;;
        h|help) usage;;
        [0-9]*) if (( $opt >= ${#DISP[@]} )); then
                    echo "[ERR] Invalid display number. Exiting..."
                    exit
                else
                    echo "adding $opt to array"
                    ORDER[$opt]=$num; ((num++))
                fi;;
    esac
    shift
done

for i in "${!DISP[@]}"; do
    [[ -z ${ORDER[i]} ]] && ORDER[$i]="x"
done

# echo $(IFS=',';echo "[DBG] \$DISP=[${DISP[*]// /|}]";IFS=$'')
# echo $(IFS=',';echo "[DBG] \$ORDER=[${ORDER[*]// /|}]";IFS=$'')

for i in "${!ORDER[@]}"; do
    echo "[DBG] i=$i"
    CMD[$i]="--output ${DISP[$i]}"
    if [[ ${ORDER[$i]} == "x" ]]; then
        CMD[$i]+=" --off"
    else
        CMD[$i]+=" --auto"
        if [[ ${ORDER[$i]} > 0 ]]; then
            for v in "${!ORDER[@]}"; do
                if [[ ${ORDER[$v]} == $((i-1)) ]]; then
                    CMD[$i]+=" --right-of ${DISP[${ORDER[$v]}]}"
                fi
            # echo "[DBG] i=$i, ORDER[$((i-1))]=${ORDER[$((i-1))]}, DISP[ORDER[$((i-1))]]=${DISP[${ORDER[$((i-1))]}]}"
            done
        fi
    fi
done

# echo "[DBG] Turn off unnneded DISPs"
# D=0
# while [[ $D -lt ${#DISP[@]} ]]; do
#     [[ -z ${CMD[$D]} ]] && CMD[$D]="--output ${DISP[$D]} --off"
#     ((D++))
# done

CMD="xrandr ${CMD[@]}"
echo "$CMD"
exec $CMD

