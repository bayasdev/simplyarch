#!/bin/bash

# short URL: https://is.gd/simplyarch
# see stats at: https://is.gd/stats.php?url=simplyarch

clear
echo "SimplyArch bootstrapper..."
echo
pacman -Sy git --noconfirm --needed
git clone https://github.com/geminis3/simplyarch
cd simplyarch
chmod +x simplyarch.sh
./simplyarch.sh