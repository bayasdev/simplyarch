#!/bin/bash

# This is an optional post-installation script designed for SimplyArch Installer users
# Copyright (C) The SimplyArch Authors

# Released under the MIT license

# Function declaration begins

# Message displayed to user at start
greeting(){
    echo
    echo "Welcome to the SimplyArch Post-Installation Wizard"
    echo "Copyright (C) The SimplyArch Authors"
    echo
    echo "DISCLAIMER: THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED"
    echo
    echo "WARNING: MAKE SURE TO TYPE CORRECTLY BECAUSE THE SCRIPT WON'T PERFORM INPUT VALIDATIONS"
    echo
    echo "We'll help you get your Arch Linux installation ready to rock!"
    echo
}

# Gather data about the user's hardware and current OS environment
analyze_system(){
    echo
    echo "System Analysis:"
    echo
    # Check Nvidia
    if [ -n "$(lspci | grep -i nvidia)" ]
    then
    nvidia_gpu="true"
    echo "Detected Nvidia GPU"
    fi
    # Check Broadcom
    if [ -n "$(lspci | grep -i broadcom)" ]
    then
    broadcom_wifi="true"
    echo "Detected Broadcom WiFi card"
    fi
}

# Function declaration ends

# Execution order

clear
greeting
read -p "> Do you want to continue? (Y/N): " prompt
if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
then
    clear
    analyze_system
else
    echo
    echo "Installer aborted..."
    exit
fi
