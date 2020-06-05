#!/bin/bash

#jenkins_home="/mnt/hgfs/jenkins/"
jenkins_home="/var/lib/jenkins/jenkins-complete-bk-07032016"
#backup="/app/jenkins_backup"
backup="/Backup"
type="full" # use "full" to backup jobs with history build data or use "config" to backup job configurations


date="$(date '+%d-%b-%Y-%H-%M-%S')"

if [[ $type == "full" ]]
then
  echo "Backup of jenkins with jobs build history data started"
  cd $backup
  tar --exclude="$jenkins_home/jobs/*/builds/*/log" \
    --exclude="$jenkins_home/jobs/*/modules/*" \
    --exclude="$jenkins_home/jobs/*/jobs/*/modules/*" \
    --exclude="$jenkins_home/jobs/*/jobs/*/builds/*/log" \
    -cvzf jenkins_bkp_-$type-$date.tar.gz \
    $jenkins_home/*.xml \
    $jenkins_home/users \
    $jenkins_home/nodes \
    $jenkins_home/jobs/* \
    $jenkins_home/secrets \
    $jenkins_home/userContent \
    $jenkins_home/fingerprints \
    $jenkins_home/plugins/*.jpi
  echo "Backup completed and stored at ${backup}/jenkins_bkp_-$type-$date.tar.gz"
elif [[ $type == "config" ]]
then
  echo "Backup of jenkins with jobs configurations excluding build history data started"
  cd $backup
  tar -cvzf jenkins_bkp_-$type-$date.tar.gz \
    $jenkins_home/*.xml \
    $jenkins_home/users \
    $jenkins_home/nodes \
    $jenkins_home/secrets \
    $jenkins_home/userContent \
    $jenkins_home/fingerprints \
    $jenkins_home/plugins/*.jpi \
    $jenkins_home/jobs/*/config.xml \
    $jenkins_home/jobs/*/jobs/*/config.xml
  echo "Backup completed and stored at ${backup}/jenkins_bkp_-$type-$date.tar.gz"
else
  echo "Type havent defined in script"
fi
