#!/bin/bash

# Short URL for this script: https://is.gd/simplyarch
# See SimplyArch usage stats at: https://is.gd/stats.php?url=simplyarch

clear
echo "SimplyArch Installer will start in a few seconds..."
echo
pacman -Sy glibc --noconfirm
pacman -S git --noconfirm
git clone https://github.com/geminis3/simplyarch
cd simplyarch || exit
chmod +x installer.sh
./installer.sh
