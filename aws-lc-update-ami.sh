#!/bin/bash

# Updates launch configs with latest amazon AMI

Usage () {
  cat << EOF
Usage: $(basename ${0}) -v VERSION -f FILENAME
where:
    VERSION  : version number (i.e. 18.01b)
      YY.MMr where r is alphabetic revision
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

[[ -z ${VER} ]] && Usage

[[ ! -f ${SGFILE} ]] && { echo "File ${SGFILE} not found"; exit 1 ;}

declare -A AMI

while read -r REGION ACCT ENV FUNC SIZE SGLIST IAM KEY; do
  # skip comments in file
  [[ ${REGION/"#"} != ${REGION} ]] && continue
  # echo "[DBG] REGION|ENV|FUNC|SIZE|SGLIST=${REGION}|${ENV}|${FUNC}|${SIZE}|${SGLIST}"

  # echo "[DBG] Region: ${REGION}"
  # eval "AMI[${REGION}]=AMI-12345678"
  #   echo "[DBG] AMI[\${REGION}]: $AMI[${REGION}]"

  #Set the region-based AMI if we haven't alrady done so
  if [[ -z ${AMI[${REGION}]} ]]; then
    echo "[INF] Getting AMI for ${REGION}"
    AMI[${REGION}]=$(aws ${PROFILE} --region ${REGION} ec2 describe-images --owners amazon --filters "Name=name,Values=amzn-ami-hvm-*-gp2" --query 'Images[].[CreationDate,ImageId]' --output text | sort -rn | head -1 | cut -f2)
  fi
  # echo "[DBG] AMI[${REGION}]: ${AMI[${REGION}]}"

  # format Security Groups
  SG="\"$(echo ${SGLIST}|sed 's/,/\",\n      \"/g')\""
  # echo "[DBG] SG:"
  # echo ${SG}

  # write the file
  echo "[INF] Creating ${REGION}_${ENV}-${FUNC}-${VER}.txt"
  cat << EOF > ${REGION}_${ENV}-${FUNC}-${VER}.txt
{
    "LaunchConfigurationName": "${ENV}-${FUNC}-${VER}",
    "ImageId": "${AMI[${REGION}]}",
    "KeyName": "${KEY}",
    "SecurityGroups": [
      ${SG}
    ],
    "UserData": "$(base64 -w0 ~/${ACCT}/git/bootstrap/user-data.sh)",
    "InstanceType": "${SIZE}",
    "BlockDeviceMappings": [
        {
            "DeviceName": "/dev/xvda",
            "Ebs": {
                "VolumeSize": 30,
                "VolumeType": "gp2",
                "DeleteOnTermination": true
            }
        }
    ],
    "InstanceMonitoring": {
        "Enabled": false
    },
    "IamInstanceProfile": "${IAM}",
    "EbsOptimized": false
}
EOF
    echo "[INF] uploading ${ENV}-${FUNC}-${VER}.txt to ${REGION} AWS"
    aws ${PROFILE} --region ${REGION} autoscaling create-launch-configuration --launch-configuration-name ${ENV}-${FUNC}-${VER} --cli-input-json file://${REGION}_${ENV}-${FUNC}-${VER}.txt
done < ${SGFILE}
