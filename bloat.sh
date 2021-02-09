#!/bin/bash
clear
echo ">>> SimplyArch bloat installer <<<"
echo
echo "This step is COMPLETELY OPTIONAL, feel free to select None and finish the installation process"
echo
echo ">>> Desktop Environment <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4|5|6|7)$ ]] 
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
        DEpkg="gdm gnome-shell gnome-backgrounds gnome-control-center gnome-screenshot gnome-system-monitor gnome-terminal gnome-tweak-tool nautilus gedit gnome-calculator gnome-disks"
        ;;
    2)
    	DEpkg="gdm gnome gnome-tweak-tool"
    	;;
    3)
        DEpkg="sddm plasma plasma-wayland-session dolphin konsole kate kcalc ark gwenview spectacle okular packagekit-qt5"
        ;;
    4)
        DEpkg="lxdm xfce4 xfce4-goodies"
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
# install KVM drivers (xf86-video-qxl is disabled due to bugs on certain DEs)
vm=$(arch-chroot /mnt /bin/bash -c "systemd-detect-virt")
if [[ $vm = "kvm" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S spice-vdagent --noconfirm --needed"
fi
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
