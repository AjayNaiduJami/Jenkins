#!/bin/bash

install_location="/usr/local"
apt-get update -y
apt-get install -y wget python
wget https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.gz
tar -xvf node-v12.16.1-linux-x64.tar.gz
rm node-v12.16.1-linux-x64.tar.gz
mv node-v12.16.1-linux-x64 ${install_location}/

echo "export PATH=${PATH}:${install_location}/node-v12.16.1-linux-x64/bin/node:${install_location}/node-v12.16.1-linux-x64/bin/npm" >> ~/.profile
source ~/.profile

echo "node installed at ${install_location}/node-v12.16.1-linux-x64/bin/node"
echo "npm installed at ${install_location}/node-v12.16.1-linux-x64/bin/npm"
echo "Node.js download and setup was completed"