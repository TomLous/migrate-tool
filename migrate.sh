#!/usr/bin/env bash

#set -x

clientId=$1
secret=$2
projectKey=$3
accountName=$4
userName=$5
userEmail=$6
force=${7:-0}

ORIGIN=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $ORIGIN
cd $ORIGIN
rm -rf repos
mkdir -p repos
cd repos


while read gitrepo; do
  accessToken=$(curl -s -X POST -u "$clientId:$secret" https://bitbucket.org/site/oauth2/access_token -d grant_type=client_credentials | jq -r ".access_token")
  gitname=$(echo "$gitrepo" | sed  's/.*\/\(.*\)\.git/\1/g')
  cd $ORIGIN/repos || { echo 'Failed to change to repos dir' ; exit 1; }
  echo -n "Cloning $gitrepo to $gitname ... "
  git clone --depth 1 --quiet $gitrepo $gitname
  echo "OK"
#  echo -n "Deleting bitbucket repo  $gitname ... "
#  httpStatus=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE  -H "Authorization: Bearer $accessToken"  "https://api.bitbucket.org/2.0/repositories/$accountName/$gitname")
#  echo $httpStatus
  echo -n "Creating bitbucket repo $gitname ... "
  httpStatus=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json" "https://api.bitbucket.org/2.0/repositories/$accountName/$gitname" -d '{"scm":"git","project":{"key":"'$projectKey'"},"is_private":"true"}')
  if [[ $force -eq "1" || $httpStatus -eq "200" ]]; then
      echo "Ok"
      cd $ORIGIN/repos/$gitname || { echo 'Failed to change to repo' ; exit 1; }
      rm -rf .git
      git init
      git config user.name $userName
      git config user.email $userEmail
      git add . > /dev/null
      git commit -m "First from shallow clone" --quiet
    #  git filter-branch -- --all
      git remote add origin git@bitbucket.org:$accountName/$gitname.git || { echo 'Failed to change the origin' ; exit 1; }
    #  git remote set-url origin git@bitbucket.org:$accountName/test_$gitname.git || { echo 'Failed to change the origin' ; exit 1; }
      git push -u origin master --quiet
   else
     echo "Skip"
   fi




done < ../source-repos