#!/bin/bash

myBranch=$(git rev-parse --abbrev-ref HEAD)
branchList="$(git branch --merged | egrep -v "master|${myBranch}|production")"

echo "List of branches merged into ${myBranch}"
echo "----------------------------------------"
echo "${branchList}"
echo "----------------------------------------"
read -p "Delete these branches (local and origin)? " answer

if [[ ${answer} == "y" || ${answer} == "Y" || ${answer} == "yes" || ${answer} == "Yes" || ${answer} == "YES" ]]; then
  for branch in ${branchList}; do
    echo "Deleting branch: ${branch}..."
    git branch -d ${branch}
    git push --delete origin ${branch}
  done
else
  echo "exiting without deletion"
fi
