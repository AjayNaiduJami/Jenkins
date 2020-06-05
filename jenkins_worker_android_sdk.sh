#!/bin/bash

ANDROID_HOME="/usr/local/android_linux_sdk"

apt-get update -y
apt-get install -y openjdk-8-jdk wget unzip
mkdir -p ${ANDROID_HOME} /root/.android
cd ${ANDROID_HOME}
wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O android_tools.zip
unzip android_tools.zip
rm android_tools.zip

echo "export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/build-tools" >> ~/.profile
source ~/.profile

touch /root/.android/repositories.cfg
yes | sdkmanager --licenses
sdkmanager --update
echo "Android SDK installed at ${ANDROID_HOME}"
echo "Android SDK download and setup was completed"