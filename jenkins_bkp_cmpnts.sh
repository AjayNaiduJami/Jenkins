#!/bin/bash

#jenkins_home="/mnt/hgfs/jenkins/"
jenkins_home="/var/lib/jenkins/jenkins-complete-bk-07032016"
#backup="/app/jenkins_backup"
backup="/Backup/"
date="$(date '+%d-%b-%Y-%H-%M-%S')"

cd $backup

tar --exclude="$jenkins_home/jobs/*/builds/*/log" \
 --exclude="$jenkins_home/jobs/*/modules/*" \
 --exclude="$jenkins_home/jobs/*/jobs/*/modules/*" \
 --exclude="$jenkins_home/jobs/*/jobs/*/builds/*/log" \
 -cvzf jenkins_bkp_$date.tar.gz \
 $jenkins_home/*.xml \
 $jenkins_home/users \
 $jenkins_home/nodes \
 $jenkins_home/jobs/* \
 $jenkins_home/secrets \
 $jenkins_home/userContent \
 $jenkins_home/fingerprints \
 $jenkins_home/plugins/*.jpi


# tar -cvzf jenkins_bkp_$date.tar.gz \
#  $jenkins_home/*.xml \
#  $jenkins_home/users \
#  $jenkins_home/nodes \
#  $jenkins_home/secrets \
#  $jenkins_home/userContent \
#  $jenkins_home/fingerprints \
#  $jenkins_home/plugins/*.jpi \
#  $jenkins_home/jobs/*/config.xml \
#  $jenkins_home/jobs/*/jobs/*/config.xml