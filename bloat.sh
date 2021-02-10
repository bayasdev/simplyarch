#!/bin/bash

# WARNING: BLOAT SHALL BE RUN AS A CHILD OF THE BASE SCRIPT BECAUSE PARU CAN'T BE RUN AS ROOT
# However feel free to override the inherited user variable if you know what you're doing
#user="your_username"

clear
echo "Bloat by SimplyArch (BETA)"
echo "Copyright (C) 2021 Victor Bayas"
echo
echo "NOTE: THIS STEP IS COMPLETELY OPTIONAL, feel free to select None and finish the installation process"
echo
echo "We'll guide you through the process of installing a DE, additional software and drivers."
echo
echo ">>> Desktop Environment <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4|5|6|7|8)$ ]]
do
    echo "Please select one option:"
    echo "1. GNOME Minimal"
    echo "2. GNOME Full (beware of pkgs count)"
    echo "3. KDE Plasma"
    echo "4. Xfce"
    echo "5. LXQt"	
    echo "6. LXDE"
    echo "7. Cinnamon"
    echo "8. None - I don't want bloat"
    read -p "Desktop (1-8): " desktop
done
case $desktop in
    1)
        DEpkg="gdm gnome-shell gnome-backgrounds gnome-control-center gnome-screenshot gnome-system-monitor gnome-terminal gnome-tweak-tool nautilus gedit gnome-calculator gnome-disk-utility eog evince"
        ;;
    2)
        DEpkg="gdm gnome gnome-tweak-tool"
        ;;
    3)
        DEpkg="sddm plasma plasma-wayland-session dolphin konsole kate kcalc ark gwenview spectacle okular packagekit-qt5"
        ;;
    4)
        DEpkg="lxdm xfce4 xfce4-goodies network-manager-applet"
        ;;
    5)
        DEpkg="sddm lxqt breeze-icons featherpad"
        ;;
    6)
        DEpkg="lxdm lxde leafpad galculator"
        ;;
    7)
        DEpkg="lxdm cinnamon cinnamon-translations gnome-terminal"
        ;;
    8)
        echo "No desktop environment will be installed."
        exit 0
        ;;
esac
# install packages accordingly
arch-chroot /mnt /bin/bash -c "pacman -Sy $DEpkg firefox pulseaudio pavucontrol pulseaudio-alsa --noconfirm --needed"
# enable DM accordingly
case $desktop in
    1)
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    2)
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    3)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    4)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    5)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    6)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    7)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
esac
# auto-install VM drivers
case $(systemd-detect-virt) in
    kvm)
        # xf86-video-qxl is disabled due to bugs on certain DEs
        arch-chroot /mnt /bin/bash -c "pacman -S spice-vdagent --noconfirm --needed"
        ;;
    vmware)
        arch-chroot /mnt /bin/bash -c "pacman -S open-vm-tools --noconfirm --needed"
        arch-chroot /mnt /bin/bash -c "systemctl enable vmtoolsd.service ; systemctl enable vmware-vmblock-fuse.service"
        ;;
esac
# app installer
while ! [[ "$app" =~ ^(15)$ ]] 
do
    clear
    echo ">>> App Installer <<<"
    echo
    echo "NOTE: Firefox was already installed on the previous step"
    echo
    echo "Please select:"
    echo
    echo ">>> Browsers"
    echo
    echo "1. Google Chrome"
    echo "2. Chromium"
    echo
    echo ">>> Work & Productivity"
    echo
    echo "3. LibreOffice Fresh"
    echo "4. Zoom"
    echo "5. Microsoft Teams"
    echo "6. Telegram Desktop"
    echo
    echo ">>> Multimedia"	
    echo
    echo "7. VLC"
    echo "8. MPV"
    echo
    echo ">>> System Utilities"
    echo
    echo "9. GParted"
    echo "10. Timeshift Backup"
    echo
    echo ">>> Text Editors"
    echo
    echo "11. Visual Studio Code"
    echo "12. Neovim"
    echo "13. GNU Emacs"
    echo "14. Atom"
    echo
    echo "15. None / Continue to next step"
    read -p "App (1-15): " app
    case $app in
        1)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S google-chrome --noconfirm --needed"
            ;;
        2)
            arch-chroot /mnt /bin/bash -c "pacman -S chromium --noconfirm --needed"
            ;;
        3)
            arch-chroot /mnt /bin/bash -c "pacman -S libreoffice-fresh --noconfirm --needed"
            ;;
        4)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S zoom --noconfirm --needed"
            ;;
        5)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S teams --noconfirm --needed"
            ;;
        6)
            arch-chroot /mnt /bin/bash -c "pacman -S telegram-desktop --noconfirm --needed"
            ;;
        7)
            arch-chroot /mnt /bin/bash -c "pacman -S vlc --noconfirm --needed"
            ;;
        8)
            arch-chroot /mnt /bin/bash -c "pacman -S mpv --noconfirm --needed"
            ;;
        9)
            arch-chroot /mnt /bin/bash -c "pacman -S gparted --noconfirm --needed"
            ;;
        10)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S timeshift-bin --noconfirm --needed"
            ;;
        11)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S visual-studio-code-bin --noconfirm --needed"
            ;;
        12)
            arch-chroot /mnt /bin/bash -c "pacman -S neovim --noconfirm --needed"
            ;;
        13)
            arch-chroot /mnt /bin/bash -c "pacman -S emacs --noconfirm --needed"
            ;;
        14)
            arch-chroot /mnt /bin/bash -c "pacman -S atom --noconfirm --needed"
            ;;
    esac
done
clear
# nvidia
echo ">>> NVIDIA Support <<<"
echo
echo "Do you want to add propietary NVIDIA drivers? (Y/N)"
read -p "NVIDIA Support: " nvidia
if [[ $nvidia == "y" || $nvidia == "Y" || $nvidia == "yes" || $nvidia == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S nvidia-dkms nvidia-utils egl-wayland --noconfirm --needed"
fi
clear
# broadcom
echo ">>> Broadcom WiFi Support <<<"
echo
echo "Only do this if your Broadcom card doesn't works with built-in kernel drivers"
echo
echo "Do you want to add propietary Broadcom drivers? (Y/N)"
read -p "Broadcom Support: " broadcom
if [[ $broadcom == "y" || $broadcom == "Y" || $broadcom == "yes" || $broadcom == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S broadcom-wl-dkms --noconfirm --needed"
fi
clear
# intel vaapi
echo ">>> Intel VAAPI drivers (recommended) <<<"
echo
echo "Only do this if you have an Intel GPU"
echo
echo "Do you want to add Intel VAAPI? (Y/N)"
read -p "Intel VAAPI: " intelVaapi
if [[ $intelVaapi == "y" || $intelVaapi == "Y" || $intelVaapi == "yes" || $intelVaapi == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S libva-intel-driver intel-media-driver vainfo --noconfirm --needed"
fi
clear
# flatpak
echo ">>> Flatpak <<<"
echo
echo "Do you want to install Flatpak? (Y/N)"
read -p "Flatpak: " flatpak
if [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S flatpak --noconfirm --needed"
fi
clear
# cups
echo ">>> Printer Support (CUPS) <<<"
echo
echo "Do you want to add printing support? (Y/N)"
read -p "Printing Support: " printerSupport
if [[ $printerSupport == "y" || $printerSupport == "Y" || $printerSupport == "yes" || $printerSupport == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S cups --noconfirm --needed"
fi
exit 0
