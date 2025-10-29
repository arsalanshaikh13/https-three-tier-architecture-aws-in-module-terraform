#!/bin/bash
set -euo pipefail
pwd
cd ../packer/backend

# sudo chmod +x build_ami.sh
chmod +x build_ami.sh
./build_ami.sh

cd ../frontend
# sudo chmod +x build_ami.sh
chmod +x build_ami.sh
./build_ami.sh

cd ../../root