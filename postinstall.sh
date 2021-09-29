#!/bin/bash

# This is an optional post-installation script for SimplyArch Installer
# Copyright (C) The SimplyArch Authors

# Released under the MIT license

# WARNING:
# Designed to work inside archiso environment
# The user variable is inherited from the parent script, however feel free to modify if run independently
#user="your_username"

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
    # Detect Intel GPU
    if (lspci | grep VGA | grep "Intel" &>/dev/null)
    then
        intel_gpu="true"
        echo "Detected Intel GPU"
    fi
    # Detect AMD GPU
    if (lspci | grep VGA | grep "ATI\|AMD/ATI" &> /dev/null)
    then
        amd_gpu="true"
        echo "Detected AMD GPU"
    fi
    # Detect Nvidia
    if [ -n "$(lspci | grep -i nvidia)" ]
    then
        nvidia_gpu="true"
        echo "Detected Nvidia GPU"
    fi
    # Detect Broadcom
    if [ -n "$(lspci | grep -i broadcom)" ]
    then
        broadcom_wifi="true"
        echo "Detected Broadcom WiFi card"
    fi
    # Detect VM
    vm=$(systemd-detect-virt)
    if [ "$vm" != "none" ]
    then
        echo "Running inside $vm"
    else
        echo "Running on a real machine"
    fi
    # Detect AUR helper
    if [ -n "$(arch-chroot /mnt /bin/bash -c "pacman -Qq | grep -i yay")" ]
    then
        aur_helper="yay"
    elif [ -n "$(arch-chroot /mnt /bin/bash -c "pacman -Qq | grep -i paru")" ]
    then
        aur_helper="paru"
    else
        echo
        echo "ERROR: This script cannot run without an AUR helper installed"
        goodbye
    fi
    sleep 3
}

# DE installer
de_installer(){
    while ! [[ "$desktop" =~ ^(1|2|3|4|5|6|7|8|9)$ ]]
    do
        echo
        echo "Desktop Environment Installer"
        echo
        echo "Please select one option:"
        echo
        echo "1. GNOME"
        echo "2. KDE Plasma"
        echo "3. Xfce"
        echo "4. MATE"
        echo "5. LXQt"	
        echo "6. LXDE"
        echo "7. Cinnamon"
        echo "8. Cutefish"
        echo "9. Return to main menu"
        echo
        read -p "Desktop environment (1-9): " desktop
    done
    # Packages for each DE
    case $desktop in
        1)
            de_pkgs="gnome-shell gdm gedit gnome-terminal gnome-control-center gnome-tweaks gnome-screenshot gnome-keyring file-roller nautilus nautilus-sendto sushi evince eog gnome-usage gnome-disk-utility adwaita-icon-theme xdg-user-dirs-gtk gvfs gvfs-mtp gvfs-afc gvfs-gphoto2 gvfs-nfs"
            ;;
        2)
            de_pkgs="plasma-desktop sddm kinfocenter konsole dolphin kinit plasma-nm plasma-pa kscreen powerdevil sddm-kcm kdeconnect dbus-python kio-fuse audiocd-kio gwenview ark okular spectacle print-manager kate plasma-disks"
            ;;
        3)
            de_pkgs="xfce4 parole ristretto thunar-archive-plugin thunar-media-tags-plugin xfce4-battery-plugin xfce4-datetime-plugin xfce4-mount-plugin xfce4-netload-plugin xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screensaver xfce4-screenshooter xfce4-taskmanager xfce4-wavelan-plugin xfce4-weather-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin file-roller gvfs gvfs-mtp gvfs-afc gvfs-gphoto2 gvfs-nfs gvfs-smb network-manager-applet xed galculator lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings xdg-user-dirs-gtk"
            ;;
        4)
            de_pkgs="mate mate-extra network-manager-applet xdg-user-dirs-gtk lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings gvfs gvfs-mtp gvfs-afc gvfs-gphoto2 gvfs-nfs gvfs-smb"
            ;;
        5)
            de_pkgs="lxqt xdg-utils sddm libpulse libstatgrab libsysstat lm_sensors network-manager-applet breeze breeze-gtk featherpad pavucontrol-qt xscreensaver print-manager gvfs gvfs-mtp lxqt-archiver qt5-translations kio-fuse"
            ;;
        6)
            de_pkgs="lxdm lxde leafpad galculator"
            ;;
        7)
            de_pkgs="cinnamon cinnamon-translations gnome-terminal gnome-system-monitor gthumb x-apps file-roller lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings nemo-fileroller nemo-image-converter nemo-preview nemo-share gvfs gvfs-mtp gvfs-afc gvfs-gphoto2 gvfs-nfs gvfs-smb gnome-screenshot gnome-calculator xdg-user-dirs-gtk"
            ;;
        8)
            de_pkgs="sddm cutefish"
            ;;
        9)
            main_menu
            ;;
    esac
    # Install pkgs + xorg + pulseaudio
    arch-chroot /mnt /bin/bash -c "pacman -Sy xorg-server $de_pkgs pulseaudio pavucontrol --noconfirm --needed"
    # Enable display manager accordingly
    case $desktop in
    1)
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    2)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    3)
        arch-chroot /mnt /bin/bash -c "systemctl enable lightdm.service"
        ;;
    4)
        arch-chroot /mnt /bin/bash -c "systemctl enable lightdm.service"
        ;;
    5)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    6)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    7)
        arch-chroot /mnt /bin/bash -c "systemctl enable lightdm.service"
        ;;
    8)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    esac
    # Install VM drivers
    case "$vm" in
        "kvm" )
            arch-chroot /mnt /bin/bash -c "pacman -Sy qemu-guest-agent --noconfirm --needed"
            ;;
        "oracle" )
            arch-chroot /mnt /bin/bash -c "pacman -Sy virtualbox-guest-utils --noconfirm --needed"
            arch-chroot /mnt /bin/bash -c "systemctl enable vboxservice.service"
            ;;
        "vmware" )
            arch-chroot /mnt /bin/bash -c "pacman -Sy open-vm-tools xf86-video-vmware xf86-input-vmmouse --noconfirm --needed"
            arch-chroot /mnt /bin/bash -c "systemctl enable vmtoolsd.service; systemctl enable vmware-vmblock-fuse.service"
            ;;
    esac
    driver_installer
}

# Install Software
app_installer(){
    while ! [[ "$app" =~ ^(25)$ ]] 
do
    clear
    echo
    echo "App Installer"
    echo
    echo "Available app categories:"
    echo
    echo ">>> Browsers"
    echo
    echo "1. Google Chrome"
    echo "2. Firefox"
    echo "3. Opera"
    echo "4. Brave"
    echo "5. Chromium"
    echo
    echo ">>> Work & Communication"
    echo
    echo "6. LibreOffice Fresh"
    echo "7. WPS Office"
    echo "8. OnlyOffice"
    echo "9. Zoom"
    echo "10. Microsoft Teams"
    echo "11. Slack"
    echo "12. Telegram Desktop"
    echo
    echo ">>> Multimedia"	
    echo
    echo "13. VLC"
    echo "14. MPV"
    echo
    echo ">>> System Utilities & Software Management"
    echo
    echo "15. GParted"
    echo "16. Timeshift Backup"
    echo "17. Flatpak"
    echo "18. Snap"
    echo "19. Pamac (Manjaro App Store includes Flatpak and Snap)"
    echo
    echo ">>> Text Editors"
    echo
    echo "20. Visual Studio Code"
    echo "21. Vim"
    echo "22. Neovim"
    echo "23. GNU Emacs"
    echo "24. Atom"
    echo
    echo "25. Return to main menu"
    read -p "App (1-25): " app
    case $app in
        1)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S google-chrome --noconfirm --needed"
            ;;
        2)
            arch-chroot /mnt /bin/bash -c "pacman -S firefox --noconfirm --needed"
            ;;
        3)
            arch-chroot /mnt /bin/bash -c "pacman -S opera opera-ffmpeg-codecs --noconfirm --needed"
            ;;
        4)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S brave-bin --noconfirm --needed"
            ;;
        5)
            arch-chroot /mnt /bin/bash -c "pacman -S chromium --noconfirm --needed"
            ;;
        6)
            arch-chroot /mnt /bin/bash -c "pacman -S libreoffice-fresh --noconfirm --needed"
            ;;
        7)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S wps-office --noconfirm --needed"
            ;;
        8)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S onlyoffice-bin --noconfirm --needed"
            ;;
        9)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S zoom --noconfirm --needed"
            ;;
        10)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S teams--noconfirm --needed"
            ;;
        11)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S slack-desktop --noconfirm --needed"
            ;;
        12)
            arch-chroot /mnt /bin/bash -c "pacman -S telegram-desktop --noconfirm --needed"
            ;;
        13)
            arch-chroot /mnt /bin/bash -c "pacman -S vlc --noconfirm --needed"
            ;;
        14)
            arch-chroot /mnt /bin/bash -c "pacman -S mpv --noconfirm --needed"
            ;;
        15)
            arch-chroot /mnt /bin/bash -c "pacman -S gparted --noconfirm --needed"
            ;;
        16)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S timeshift-bin --noconfirm --needed"
            ;;
        17)
            arch-chroot /mnt /bin/bash -c "pacman -S flatpak --noconfirm --needed"
            ;;
        18)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S snapd --noconfirm --needed"
            ;;
        19)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S pamac-all --noconfirm --needed"
            ;;
        20)
            arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S visual-studio-code-bin --noconfirm --needed"
            ;;
        21)
            arch-chroot /mnt /bin/bash -c "pacman -S vim --noconfirm --needed"
            ;;
        22)
            arch-chroot /mnt /bin/bash -c "pacman -S neovim --noconfirm --needed"
            ;;
        23)
            arch-chroot /mnt /bin/bash -c "pacman -S emacs --noconfirm --needed"
            ;;
        24)
            arch-chroot /mnt /bin/bash -c "pacman -S atom --noconfirm --needed"
            ;;
        25)
            main_menu
            ;;
    esac
done
}

# Smart driver installer
driver_installer(){
    # Nvidia
    if [ "$nvidia_gpu" == "true" ]
    then
        clear
        echo
        echo "Nvidia Driver Installer"
        echo
        echo "Detected Nvidia GPU"
        echo
        read -p "> Would you like to install the propietary Nvidia drivers? (Y/N): " prompt
        if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
        then
            arch-chroot /mnt /bin/bash -c "pacman -S nvidia-dkms nvidia-utils egl-wayland vdpauinfo --noconfirm --needed"
            # Optimus
            if [[ "$intel_gpu" == "true" || "$amd_gpu" == "true"  ]]
            then
                clear
                echo
                echo "Dual-GPU system detected (Optimus Hybrid Graphics support)"
                echo
                echo "Optimus Manager is NOT recommended on Turing (RTX) or newer cards that implement native power management"
                echo "See Nvidia documentation at https://bit.ly/3F59nr2"
                echo
                read -p "> Would you like to install Optimus Manager? (Y/N): " prompt
                if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
                then
                arch-chroot /mnt /bin/bash -c "sudo -u $user $aur_helper -S optimus-manager optimus-manager-qt --noconfirm --needed"
                fi
            fi
        fi
    fi
    # Broadcom
    if [ "$broadcom_wifi" == "true" ]
    then
        clear
        echo
        echo "Broadcom Driver Installer"
        echo
        echo "Detected Broadcom WiFi"
        echo
        read -p "> Would you like to install the propietary Broadcom drivers? (Y/N): " prompt
        if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
        then
            arch-chroot /mnt /bin/bash -c "pacman -S broadcom-wl-dkms --noconfirm --needed"
        fi
    fi
    # Intel
    if [ "$intel_gpu" == "true" ]
    then
        clear
        echo
        echo "Intel VAAPI Driver Installer"
        echo
        echo "Recommended for GPU accelerated video decode on supported applications"
        echo "For more information see the Arch Wiki entry at https://bit.ly/3zUBDsD"
        echo
        read -p "> Would you like to install Intel VAAPI drivers? (Y/N): " prompt
        if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
        then
            arch-chroot /mnt /bin/bash -c "pacman -S libva-intel-driver intel-media-driver vainfo --noconfirm --needed"
        fi
    fi
    # AMD
    if [ "$amd_gpu" == "true" ]
    then
        clear
        echo
        echo "AMD VAAPI/VDPAU Driver Installer"
        echo
        echo "Recommended for GPU accelerated video decode on supported applications"
        echo "For more information see the Arch Wiki entry at https://bit.ly/3zUBDsD"
        echo
        read -p "> Would you like to install AMD VAAPI/VDPAU drivers? (Y/N): " prompt
        if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
        then
            arch-chroot /mnt /bin/bash -c "pacman -S libva-mesa-driver vainfo mesa-vdpau vdpauinfo --noconfirm --needed"
        fi
    fi
    clear
    app_installer
}

# Byeeeeee
goodbye(){
    echo
    echo "Thank you for using SimplyArch Post-Installation Wizard!"
    sleep 3
    exit
}

# Main menu
main_menu(){
    clear
    while ! [[ "$option" =~ ^(1|2|3|4)$ ]]
    do
    echo
    echo "SimplyArch Post-Installation Wizard"
    echo
    echo "1. Install a Desktop Environment"
    echo "2. Smart Driver Installer"
    echo "3. Install additional software"
    echo "4. Exit"
    echo
    read -p "> Choose an option (1-4): " option
    case "$option" in
        1)
            clear
            de_installer
            ;;
        2)
            clear
            driver_installer
            ;;
        3)
            clear
            app_installer
            ;;
        4)
            clear
            goodbye
            ;;
    esac
    done
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
    clear
    main_menu
else
    echo
    echo "Installer aborted..."
    exit
fi
