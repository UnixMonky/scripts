#!/bin/bash

# List (and optionally delete) unused AWS launch configs

# Check if a value exists in an array
# @param $1 mixed  Needle
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
Usage () {
  cat << EOF
Usage: $(basename ${0}) [-p profile] [-a] [-d]
where:
    -a : show all LCs (default is only inactive)
    -p : AWS cli profile
    -d : delete unused launch configs
EOF
exit
}

while getopts ":adp:" opt; do
  case $opt in
    a) SHOWALL=true ;;
    d) DELETE=true;;
    p) PROFILE="--profile ${OPTARG}" ;;
    *) Usage ;;
  esac
done

in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

active_config() {
  INSTANCE=$1
  [[ $SHOWALL ]] && echo "[ACT] Active Launch Config: $INSTANCE"
}

inactive_config() {
  INSTANCE=$1
  if [[ $DELETE ]]; then
    echo "[DEL] Deleting inactive LC: $1"
    aws ${PROFILE} autoscaling delete-launch-configuration --launch-configuration-name ${1}
  else
    echo "[INA] Inactive Launch Config: $1"
  fi
}

# Get all launch configuration names that have been created for this AWS account
allconfigs=$(aws ${PROFILE} autoscaling describe-launch-configurations | jq '.LaunchConfigurations[].LaunchConfigurationName' | sed s/\"//g | grep -v null)
configs=($allconfigs)

# Get all active launch configurations names that are currently associated with running instances
allinstances=$(aws ${PROFILE} autoscaling describe-auto-scaling-instances | jq '.AutoScalingInstances[].LaunchConfigurationName' | sed s/\"//g | grep -v null)
instances=($allinstances)

# Get all active launch configuration names that are currently associated with launch configuration groups
allgroups=$(aws ${PROFILE} autoscaling describe-auto-scaling-groups | jq '.AutoScalingGroups[].LaunchConfigurationName' | sed s/\"//g | grep -v null)
groups=($allgroups)

# merge group configs and active instances configs into one array.  We need to keep them, and remove the rest
groupsandinstances=(`for R in "${instances[@]}" "${groups[@]}" ; do echo "$R" ; done | sort -du`)

for g in "${groupsandinstances[@]}"; do
  echo "-> [$g]"
done
echo

#Loop through all configs and check against active ones to determine whether they need to be deleted
for i in "${configs[@]}"
do
	echo "checking element [$i]"
#in_array $i "${groupsandinstances[@]}" && echo active ${i} || echo deleting ${i} #`aws autoscaling delete-launch-configuration --launch-configuration-name ${i}`
#  in_array $i "${groupsandinstances[@]}" && active_config ${i} || inactive_config ${i}
  #in_array $i "${groupsandinstances[@]}" && echo active ${i} || echo deleting ${i} 
  if [[ ${groupsandinstances["$i"]} ]]; then

      echo "found in array: $i"
  else
      echo "not in array: $i"
  fi
done
