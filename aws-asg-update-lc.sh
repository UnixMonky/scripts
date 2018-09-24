#!/bin/bash

# This script will update matching autoscaling groups with a new launch config.

Usage () {
  cat << EOF
Usage: $(basename ${0}) [-p profile] -a AutoScalingFilter -l LaunchConfigName
where:
    -p profile               : aws profile
    -a AutoScalingFilter     : search string to match autoscaling groups
    -l LaunchConfigName      : name of the new Launch Config
EOF
exit
}

while getopts ":a:l:p:" opt; do
  case $opt in
    l) LCNAME="${OPTARG}" ;;
    a) ASGFILTER="${OPTARG}" ;;
    p) PROFILE="--profile ${OPTARG}";;
    *) Usage ;;
  esac
done

[[ -z ${LCNAME} ]] && Usage

[[ -z ${ASGFILTER} ]] && Usage


# get list of matching autoscale groups
ASGLIST=$(aws ${PROFILE} autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].[AutoScalingGroupName]' --output text | grep -i "$ASGFILTER")

echo "Found matching autoscalegroups:"
echo "$ASGLIST"
echo "\-------------------------------"
read -n 1 -p "Update Launch config to: ${LCNAME} (y/n)" answer
case ${answer:0:1} in
    y|Y )  echo "Starting..." ;;
    * )    echo "Aborting..."; exit ;;
esac

for ASG in ${ASGLIST}; do
  echo "$ASG..."
  aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG --launch-configuration-name "${LCNAME}"
done