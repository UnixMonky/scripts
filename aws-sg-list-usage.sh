#!/bin/bash
set -x
MYSELF="${0##*/}"
MYSELF="${MYSELF%.*}"

 [[ -n $1 ]] && PROFILE="--profile ${1}"

#all SGs
TMPFILE=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
AllSGs=$(aws ${PROFILE} ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId]'  --output text | sort -u)
# # used SGs
# SG_USED_ORIG=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
# aws ${PROFILE} ec2 describe-instances --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text | tr '\t' '\n' > $SG_USED_ORIG
# aws ${PROFILE} rds describe-db-instances --query 'DBInstances[].VpcSecurityGroups[].VpcSecurityGroupId[]' --output text | tr '\t' '\n' >> $SG_USED_ORIG
# aws ${PROFILE} elasticache describe-cache-clusters --query 'CacheClusters[].SecurityGroups[].SecurityGroupId' --output text | tr '\t' '\n' >> $SG_USED_ORIG
# SG_USED=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
# sort $SG_USED_ORIG | uniq > $SG_USED
# #unused SGs
# SG_UNUSED=$(mktemp /tmp/tmp_${MYSELF}.XXXXX)
# comm -23 $SG_ALL $SG_USED | tr '\n' ' ' > $SG_UNUSED

for ThisSG in ${AllSGs}; do
  aws ${PROFILE} ec2 describe-security-groups --group-id ${ThisSG} --query 'SecurityGroups[].[GroupId,GroupName,Description]' --output text | sed 's/	/ | /g'
  aws ${PROFILE} ec2 describe-network-interfaces --filters Name=group-id,Values=${ThisSG} --query 'NetworkInterfaces[].[Description]' --output text
  echo "- - - - - - - - - - - - - - - - - - - -"
exit
done
