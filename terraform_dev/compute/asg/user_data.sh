#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1
set -euxo pipefail
whoami

echo " name of the bucket"
# COPY APP CODE
cd /home/ec2-user
pwd
whoami
echo "hello" > /home/ec2-user/log.txt
cat log.txt
ls -lra log.txt
realpath log.txt
cat /home/ec2-user/log.txt
mkdir somethin
echo "something echo" > /home/ec2-user/somethin/som.txt
cd somethin
pwd
sudo -u ec2-user cat /home/ec2-user/somethin/som.txt
realpath som.txt