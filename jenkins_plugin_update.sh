#!/bin/bash

JENKINS_URL="http://192.168.1.168" #must include protocol http:// or https://
USERNAME=""
PASSWORD=""

cli_location="/jenkins"


if [ ! -f "${cli_location}/jenkins-cli.jar" ]; then
    echo "Downloading Jenkins CLI jar from the master"
    curl ${JENKINS_URL}/jnlpJars/jenkins-cli.jar -o /tmp/jenkins-cli.jar
else
  echo "Jenkins CLI jar exists on local"
fi

UPDATE_LIST=$( java -jar ${cli_location}/jenkins-cli.jar -s ${JENKINS_URL} -auth ${USERNAME}:${PASSWORD} list-plugins | grep -e ')$' | awk '{ print $1 }' ); 
if [ ! -z "${UPDATE_LIST}" ]; then 
    echo Updating Jenkins Plugins: ${UPDATE_LIST}; 
   java -jar ${cli_location}/jenkins-cli.jar -s ${JENKINS_URL} -auth ${USERNAME}:${PASSWORD} install-plugin ${UPDATE_LIST};
   java -jar ${cli_location}/jenkins-cli.jar -s ${JENKINS_URL} -auth ${USERNAME}:${PASSWORD} safe-restart;
else
  echo "Jenkins Plugins are up to date"
fi