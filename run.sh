#!/bin/bash
clear
echo "SimplyArch bootstrapper..."
echo
pacman -Sy git
git clone https://github.com/geminis3/simplyarch
cd simplyarch || return 1
chmod +x simplyarch.sh
./simplyarch.sh