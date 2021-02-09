#!/bin/bash
clear
echo ">>> Bloat installer <<<"
echo
echo "This step is COMPLETELY OPTIONAL, feel free to select None and finish the installation process"
echo
echo ">>> Desktop Environment <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4|5|6|7)$ ]] 
do
    echo "Please select 1,2,3,4,5,6,7 for:"
    echo "1. GNOME Minimal"
    echo "2. GNOME with apps"
    echo "3. KDE Plasma"
    echo "4. Xfce"
    echo "5. LXQt"	
    echo "6. LXDE"
    echo "7. Cinnamon"
    echo "8. None - Quit"
    read -p "Desktop: " desktop
done
case $desktop in
    1)
        DEpkg = "gdm gnome-shell chrome-gnome-shell gnome-backgrounds gnome-control-center gnome-screenshot gnome-system-monitor gnome-terminal gnome-tweak-tool nautilus tracker"
        ;;
    2)
    	DEpkg = "gdm gnome"
    	;;
    3)
        DEpkg = "sddm plasma plasma-wayland-session dolphin konsole kate kcalc ark gwenview spectacle okular packagekit-qt5"
        ;;
    4)
        DEpkg = "lxdm xfce xfce4-goodies"
        ;;
    5)
    	DEpkg = "sddm lxqt breeze-icons featherpad"
    	;;
    6)
    	DEpkg = "lxdm lxde leafpad galculator"
    	;;
    7)
        DEpkg = "lxdm cinnamon cinnamon-translations"
    	;;
    8)
        echo "No desktop environment will be installed."
        exit 0
        ;;
esac
# install packages accordingly and Firefox
arch-chroot /mnt /bin/bash -c "pacman -Sy $DEpkg firefox --noconfirm --needed"
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
# install KVM video drivers
vm = $(arch-chroot /mnt /bin/bash -c "systemd-detect-virt")
if [[ $vm = "kvm" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S spice-vdagent xf86-video-qxl --noconfirm --needed"
fi
clear
echo ">>> NVIDIA Support <<<"
echo
echo "Do you want to add NVIDIA support? (Y/N)"
read -p "NVIDIA Support: " nvidia
if [[ $nvidia == "y" || $nvidia == "Y" || $nvidia == "yes" || $nvidia == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S nvidia nvidia-utils egl-wayland --noconfirm --needed"
fi
clear
echo ">>> Flatpak <<<"
echo
echo "Do you want to install flatpak? (Y/N)"
read -p "Flatpak: " flatpak
if [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S flatpak --noconfirm --needed"
fi
clear
echo ">>> Printer Support (CUPS) <<<"
echo
echo "Do you want to add printing support? (Y/N)"
read -p "Printing Support: " printerSupport
if [[ $printerSupport == "y" || $printerSupport == "Y" || $printerSupport == "yes" || $printerSupport == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S cups --noconfirm --needed"
fi
exit 0
