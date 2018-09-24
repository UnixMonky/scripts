#!/bin/bash

Usage () {
  cat << EOF
Usage: $(basename ${0}) -f FILENAME
where:
    FILENAME : loacation of security group filename
EOF
exit
}

while getopts ":v:f:p:" opt; do
  case $opt in
    v) VER=${OPTARG} ;;
    f) SGFILE=${OPTARG} ;;
    p) PROFILE="--profile ${OPTARG}";;
    *) Usage ;;
  esac
done

[[ ! -f ${SGFILE} ]] && { echo "File ${SGFILE} not found"; exit 1 ;}

while read -r REGION ACCT ENV FUNC SIZE SGLIST IAM KEY; do
  # skip comments in file
  [[ ${REGION/"#"} != ${REGION} ]] && continue
  # echo "[DBG] REGION|ENV|FUNC|SIZE|SGLIST=${REGION}|${ENV}|${FUNC}|${SIZE}|${SGLIST}"

  # echo "[DBG] Region: ${REGION}"
  # eval "AMI[${REGION}]=AMI-12345678"
  #   echo "[DBG] AMI[\${REGION}]: $AMI[${REGION}]"

  # format Security Groups
  SG="$(echo ${SGLIST}|sed 's/,/ /g')"
  # echo "[DBG] SG:"
  # echo ${SG}

  # write the file
  echo "= = = = = = = = = = = = = = ="
  echo "[${REGION}] ${ENV}-${FUNC}"
  echo "- - - - - - - - - - - - - - -"

  aws ec2 --profile ${ACCT} --region ${REGION} describe-security-groups --group-ids ${SG} --query 'SecurityGroups[*].[GroupId,GroupName]' --output text
done < ${SGFILE}
