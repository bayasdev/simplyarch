#!/bin/bash

# This script is used to bootstrap SimplyArch Installer
# Copyright (C) The SimplyArch Authors

# Released under the MIT license

# Usage:
# curl -L is.gd/simplyarch > run ; sh run

# See our stats at: https://is.gd/stats.php?url=simplyarch

clear
echo "SimplyArch Installer will start in a few seconds..."
echo
pacman -Sy glibc --noconfirm
pacman -S git --noconfirm
git clone https://github.com/geminis3/simplyarch
cd simplyarch || exit
chmod +x installer.sh
./installer.sh
