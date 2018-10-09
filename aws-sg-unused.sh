#!/bin/bash

MYSELF="${0##*/}"
MYSELF="${MYSELF%.*}"

 [[ -n $1 ]] && PROFILE="--profile ${1}"

#all SGs
SG_ALL=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
aws ${PROFILE} ec2 describe-security-groups --query 'SecurityGroups[*].GroupId'  --output text | tr '\t' '\n'> $SG_ALL
# used SGs
SG_USED_ORIG=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
aws ${PROFILE} ec2 describe-instances --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text | tr '\t' '\n' > $SG_USED_ORIG
aws ${PROFILE} rds describe-db-instances --query 'DBInstances[].VpcSecurityGroups[].VpcSecurityGroupId[]' --output text | tr '\t' '\n' >> $SG_USED_ORIG
aws ${PROFILE} elasticache describe-cache-clusters --query 'CacheClusters[].SecurityGroups[].SecurityGroupId' --output text | tr '\t' '\n' >> $SG_USED_ORIG
SG_USED=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
sort $SG_USED_ORIG | uniq > $SG_USED
#unused SGs
SG_UNUSED=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
comm -23 $SG_ALL $SG_USED | tr '\n' ' ' > $SG_UNUSED

for ThisSG in $(<$SG_UNUSED); do
## load aws json to bash array
  SGDATA="$(aws ${PROFILE} ec2 describe-security-groups --group-ids $ThisSG --output json )"

#  SG_GroupId=$(echo "$SGDATA" | jq .SecurityGroups[0].GroupId)
#  SG_GroupName=$(echo "$SGDATA" | jq .SecurityGroups[0].GroupName)
#  SG_Description=$(echo "$SGDATA" | jq .SecurityGroups[0].Description)
#  SG_RuleBlock=$(echo "$SGDATA" | jq .SecurityGroups[0].IpPermissions[])

#  echo SG_RuleBlock
#echo "SGDATA:
#- - - - - - - - - -
#$SGDATA
#- - - - - - - - - -"

  echo $SGDATA | jq -r '.SecurityGroups[0].GroupId + " | " + .SecurityGroups[0].GroupName + " | " + .SecurityGroups[0].Description'
  for i in $(seq 0 $(($(echo $SGDATA | jq '.SecurityGroups[0].IpPermissions | length')-1))); do
    for CIDR in $(echo $SGDATA | jq -r ".SecurityGroups[0].IpPermissions[${i}].IpRanges[].CidrIp"); do
      PROT=$(echo $SGDATA | jq -r ".SecurityGroups[0].IpPermissions[${i}].IpProtocol")
      PORT=$(echo $SGDATA | jq -r ".SecurityGroups[0].IpPermissions[${i}].FromPort")
      [[ $PROT == "-1" ]] && PROT="all"
      [[ $PORT == "null" ]] && PORT="all"
      printf "    %-5s  %-5s  %-s\n" $PROT $PORT $CIDR
    done
  done
  echo "- - - - - - - - - - - - - - - - - - - -"
done

rm $SG_ALL $SG_USED_ORIG $SG_USED

