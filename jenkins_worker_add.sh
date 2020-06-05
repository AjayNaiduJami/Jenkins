#!/bin/bash

set -xe

MASTER_URL=$1 #must include protocol http:// or https://
MASTER_USERNAME=$2
MASTER_PASSWORD=$3
NODE_NAME=$4
NUM_EXECUTORS=$5


echo "Installing java8 on slave"
apt install -y openjdk-8-jdk

echo "creating jenkins working dir in agent"
mkdir /jenkins/

echo "Downloading Jenkins CLI jar from the master"
curl ${MASTER_URL}/jnlpJars/jenkins-cli.jar -o /jenkins/jenkins-cli.jar
echo "Downloading Jenkins agent jar from the master"
curl ${MASTER_URL}/jnlpJars/agent.jar -o /jenkins/agent.jar

echo "Creating node according to parameters passed in"
cat <<EOF | java -jar /jenkins/jenkins-cli.jar -auth "${MASTER_USERNAME}:${MASTER_PASSWORD}" -s "${MASTER_URL}" create-node "${NODE_NAME}" |true
<slave>
  <name>${NODE_NAME}</name>
  <description></description>
  <remoteFS>/home/jenkins/agent</remoteFS>
  <numExecutors>${NUM_EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label></label>
  <nodeProperties/>
  <userId>${USER}</userId>
</slave>
EOF
# Creating the node will fail if it already exists, so |true to suppress the
# error. This probably should check if the node exists first but it should be
# possible to see any startup errors if the node doesn't attach as expected.


echo "Running jnlp launcher"
echo "java -jar /jenkins/agent.jar -jnlpUrl ${MASTER_URL}/computer/${NODE_NAME}/slave-agent.jnlp -jnlpCredentials "${MASTER_USERNAME}:${MASTER_PASSWORD}" -workDir /jenkins/" > /jenkins/agent_run.sh
chmod +x /jenkins/agent_run.sh

cat > /etc/systemd/system/jenkins_slave.service<<EOF
[Unit]
Description=jenkins_slave
After=network.target

[Service]
User=root
WorkingDirectory=/jenkins/
ExecStart=/jenkins/agent_run.sh

[Install]
WantedBy=multi-user.target
EOF

echo "Starting Jenkins agent service"
systemctl daemon-reload
systemctl start jenkins_slave.service