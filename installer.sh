#!/bin/bash

# This is the core script used by SimplyArch Installer
# Copyright (C) The SimplyArch Authors

# Released under the MIT license

# Function declaration begins

# Message displayed to user at start
greeting(){
    echo
    echo "Welcome to SimplyArch Installer v2"
    echo "Copyright (C) The SimplyArch Authors"
    echo
    echo "DISCLAIMER: THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED"
    echo
    echo "WARNING: MAKE SURE TO TYPE CORRECTLY BECAUSE THE SCRIPT WON'T PERFORM INPUT VALIDATIONS"
    echo
    echo "We'll guide you through the Arch Linux installation process"
    echo
}

# Gather data about the user's computer
analyze_host(){
    echo
    echo "System Analysis:"
    echo
    # Check BIOS type
    if [[ -d /sys/firmware/efi ]]
    then
        bios_type="uefi"
        echo "Detected UEFI"
    else
        bios_type="bios"
        echo "Detected BIOS"
    fi
    # Check CPU vendor
    if [ -n "$(lscpu | grep GenuineIntel)" ]
    then
        cpu_vendor="intel"
        echo "Detected Intel CPU"
    elif [ -n "$(lscpu | grep AuthenticAMD)" ]
    then
        cpu_vendor="amd"
        echo "Detected AMD CPU"
    fi
    sleep 3
}

# Language & Keyboard setup
locales(){
    echo
    echo "1. Language & Keyboard Setup"
    echo
    echo "HINT: write en_US for English US (don't add .UTF-8)"
    echo
    read -p "> System Language: " language
    # If no input from user then default to en_US
    if [[ -z "$language" ]]
	then
		language="en_US"
	fi
    echo
    echo "EXAMPLES: us United States | us-acentos US Intl | latam Latin American Spanish | es Spanish"
    echo
    read -p "> Keyboard Distribution: " keyboard
    # If no input from user then default to us keyboard
    if [[ -z "$keyboard" ]]
	then
		keyboard="us"
	fi
    # Load selected keyboard distribution
    loadkeys "$keyboard"
}

# Account setup
user_accounts(){
    echo
    echo "2. User Accounts"
    echo
    read -p "> Choose a hostname for this computer: " hostname
    # If no input from user then default to archlinux
    if [[ -z "$hostname" ]]
	then
		hostname="archlinux"
	fi
	echo
	echo "Administrator User"
	echo "User: root"
	read -sp "> Password: " root_password
	echo
	read -sp "> Re-type password: " root_password2
	echo
	while [[ "$root_password" != "$root_password2" ]]
	do
		echo
		echo "Passwords don't match. Try again"
		echo
		read -sp "> Password: " root_password
		echo
		read -sp "> Re-type password: " root_password2
		echo
	done
	echo
	echo "Standard User"
	read -p "> User: " user
	export user
	read -sp "> Password: " user_password
	echo
	read -sp "> Re-type password: " user_password2
	echo
	while [[ "$user_password" != "$user_password2" ]]
	do
		echo
		echo "Passwords don't match. Try again"
		echo
		read -sp "> Password: " user_password
		echo
		read -sp "> Re-type password: " user_password2
		echo
	done
}

# Disk setup
disks(){
    echo
    echo "3. Disks Setup"
	echo
	echo "Make sure to have your disk previously partitioned, if you are unsure re-run this script when done"
    echo
    echo "HINT: you can use cfdisk, fdisk, parted or the tool of your preference"
    echo "For reference partition layouts check out the Arch Wiki entry at https://bit.ly/3m4I33p"
	echo
    echo "Your current partition table:"
    echo
    lsblk
    echo
    read -p "> Do you want to continue? (Y/N): " prompt
    if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
    then
        # Filesystem
        clear
        echo
        echo "3. Disks Setup"
        while ! [[ "$filesystem" =~ ^(1|2|3)$ ]]
        do
            echo
            echo "Choose a filesystem for your root partition:"
            echo
            echo "1. EXT4 (the standard choice for most users)"
            echo "2. BTRFS (a modern copy on write (CoW) filesystem)"
            echo "3. XFS (a high-performance journaling file system)"
            echo
            read -p "> Filesystem (1-3): " filesystem
        done
        # Root partition
        clear
        echo
        echo "3. Disks Setup"
        echo
        echo "Your current partition table:"
        echo
        lsblk
        echo
        echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
        read -p "> Root partition: " root_partition
        case "$filesystem" in
            1)
                mkfs.ext4 -f "$root_partition"
                mount "$root_partition" /mnt
                ;;
            2)
                mkfs.btrfs -f -L "Arch Linux" "$root_partition"
                mount "$root_partition" /mnt
                btrfs su cr /mnt/@
                btrfs su cr /mnt/@home
                btrfs su cr /mnt/@var
                btrfs su cr /mnt/@opt
                btrfs su cr /mnt/@tmp
                btrfs su cr /mnt/@.snapshots
                umount "$root_partition"
                mount -o relatime,space_cache=v2,compress=lzo,subvol=@ "$root_partition" /mnt
                ;;
            3)
                mkfs.xfs -f -m bigtime=1 -L "Arch Linux" "$root_partition"
                mount "$root_partition" /mnt
                ;;
        esac
        # EFI only needed for UEFI
        if [[ "$bios_type" == "uefi" ]]
            then
            clear
            echo
            echo "3. Disks Setup"
            echo
            echo "Your current partition table:"
            echo
            lsblk
            echo
            echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
            read -p "> EFI partition: " efi_partition
            echo
            echo "HINT: If you're dualbooting another OS type N otherwise Y"
            read -p "> Do you want to format this EFI partition as FAT32? (Y/N): " format_efi
            if [[ "$format_efi" == "y" || "$format_efi" == "Y" || "$format_efi" == "yes" || "$format_efi" == "Yes" ]]
            then
                mkfs.fat -F32 "$efi_partition"
            fi
            mkdir -p /mnt/boot/efi
            mount "$efi_partition" /mnt/boot/efi
        fi
        # Swap
        clear
        echo "3. Disks Setup"
        echo
        echo "Your current partition table:"
        echo
        lsblk
        echo
        echo "HINT: If you don't want to use a Swap partition type N below"
        echo
        echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
        read -p "> Swap partition: " swap
        if [[ "$swap" == "n" || "$swap" == "N" || "$swap" == "no" || "$swap" == "No" ]]
        then
            echo
            echo "Swap partition not selected"
            sleep 1
        else
            mkswap "$swap"
            swapon "$swap"
        fi
    else
        echo
        echo "Installer aborted..."
        exit
    fi
}

# Allow user to select the kernel of their choice
kernel_selector(){
    while ! [[ "$kernel_flavor" =~ ^(1|2|3|4)$ ]]
    do
    echo
    echo "4. Kernel Selector"
    echo
    echo "Choose a kernel for your system:"
    echo
    echo "1. linux (the preferred choice for most users)"
    echo "2. linux-lts (a long-term supported kernel)"
    echo "3. linux-zen (a performance focused kernel)"
    echo "4. linux-hardened (a security focused kernel)"
    echo
    read -p "> Kernel flavor (1-4): " kernel_flavor
    done
    case "$kernel_flavor" in
        1)
            kernel_flavor="linux"
            ;;
        2)
            kernel_flavor="linux-lts"
            ;;
        3)
            kernel_flavor="linux-zen"
            ;;
        4)
            kernel_flavor="linux-hardened"
            ;;
    esac
}

# Update mirrors, accepted values: before, after
mirror_updater(){
    case $1 in
        "before" )
            echo
            echo "Updating mirrors for faster install, please wait..."
            echo
            sudo -u nobody ./bin/rate_mirrors arch | tee /etc/pacman.d/mirrorlist
            ;;
        "after" )
            echo
            echo "Updating mirrors for installed system, please wait..."
            echo
            sudo -u nobody ./bin/rate_mirrors arch | tee /mnt/etc/pacman.d/mirrorlist
            ;;
    esac
}

# Performs the actual system install
arch_installer(){
    # Install the base packages
    case "$bios_type" in
        "bios" )
            pacstrap /mnt base base-devel "$kernel_flavor" "$kernel_flavor"-headers linux-firmware grub os-prober sudo bash-completion networkmanager nano xdg-user-dirs ntfs-3g
            ;;
        "uefi" )
            pacstrap /mnt base base-devel "$kernel_flavor" "$kernel_flavor"-headers linux-firmware grub efibootmgr os-prober sudo bash-completion networkmanager nano xdg-user-dirs ntfs-3g
            ;;
    esac
    # Generate fstab with UUID
    genfstab -U /mnt >> /mnt/etc/fstab
    # Set language
    echo "$language.UTF-8 UTF-8" > /mnt/etc/locale.gen
	arch-chroot /mnt /bin/bash -c "locale-gen"
	echo "LANG=$language.UTF-8" > /mnt/etc/locale.conf
    # Set keyboard
    echo "KEYMAP=$keyboard" > /mnt/etc/vconsole.conf
    # Auto-detect timezone
    arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
	arch-chroot /mnt /bin/bash -c "hwclock --systohc"
    # Copy tweaked Pacman config
    cp ./config/pacman.conf /mnt/etc/pacman.conf
    # Set hostname
    echo "$hostname" > /mnt/etc/hostname
	echo "127.0.0.1	localhost" > /mnt/etc/hosts
	echo "::1		localhost" >> /mnt/etc/hosts
	echo "127.0.1.1	$hostname.localdomain	$hostname" >> /mnt/etc/hosts
    # Update mirrors for installed system
    clear
    mirror_updater "after"
    # Install FS tools
    case "$filesystem" in
        2)
            arch-chroot /mnt /bin/bash -c "pacman -Sy btrfs-progs --noconfirm --needed"
            ;;
        3)
            arch-chroot /mnt /bin/bash -c "pacman -Sy xfsprogs xfsdump --noconfirm --needed"
            ;;
    esac
    # Install appropiate CPU microcode
    case "$cpu_vendor" in
        "intel" )
            arch-chroot /mnt /bin/bash -c "pacman -Sy intel-ucode --noconfirm --needed"
            ;;
        "amd" )
            arch-chroot /mnt /bin/bash -c "pacman -Sy amd-ucode --noconfirm --needed"
            ;;
    esac
    # Install bootloader
    case "$bios_type" in
    "bios" )
        arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc ${root_partition::-1}"
        ;;
    "uefi" )
        arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch"
        ;;
    esac
    arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
    # Enable Network Manager
	arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager.service"
	# Set root user password
	arch-chroot /mnt /bin/bash -c "(echo $root_password ; echo $root_password) | passwd root"
	# Setup user
	arch-chroot /mnt /bin/bash -c "useradd -m -G wheel $user"
	arch-chroot /mnt /bin/bash -c "(echo $user_password ; echo $user_password) | passwd $user"
	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
    # AUR installer
    clear
    aur_installer
}

# Install an AUR helper
aur_installer(){
    while ! [[ "$aur_helper" =~ ^(1|2|3)$ ]]
    do
    echo
    echo "5. AUR Installer"
    echo
    echo "Choose an AUR helper for your system:"
    echo
    echo "1. Yay"
    echo "2. Paru"
    echo "3. No AUR helper"
    echo
    read -p "> AUR helper (1-3): " aur_helper
    done
    case "$aur_helper" in
        1)
            clear
            echo
            echo "5. AUR Installer"
            echo
            echo "Installing Yay..."
            echo
            arch-chroot /mnt /bin/bash -c "pacman -Sy git --noconfirm --needed"
            echo "cd && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd && rm -rf yay-bin" | arch-chroot /mnt /bin/bash -c "su $user"
            ;;
        2)
            clear
            echo
            echo "5. AUR Installer"
            echo
            echo "Installing Paru..."
            echo
            arch-chroot /mnt /bin/bash -c "pacman -Sy git --noconfirm --needed"
            echo "cd && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd && rm -rf paru-bin" | arch-chroot /mnt /bin/bash -c "su $user"
            ;;
    esac
}

# Byeeeeee
goodbye(){
    echo
    echo "Thank you for using SimplyArch Installer!"
    echo
    echo "Installation finished successfully"
    echo
    read -p "> Would you like to reboot your computer? (Y/N): " prompt
    if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
    then
        echo
        echo "System will reboot in a moment..."
		sleep 3
		clear
		umount -a
		reboot
    else
        exit
    fi
}

# Function declaration ends

# Main execution

clear
# Welcome
greeting
read -p "> Do you want to continue? (Y/N): " prompt
if [[ "$prompt" == "y" || "$prompt" == "Y" || "$prompt" == "yes" || "$prompt" == "Yes" ]]
then
    # Preparation
    clear
    analyze_host
    # Locale setup
    clear
    locales
    # User setup
    clear
    user_accounts
    # Disk setup
    clear
    disks
    # Kernel selector
    clear
    kernel_selector
    # Update mirrors before install
    clear
    mirror_updater "before"
    # Perform install
    clear
    arch_installer
    # Call postinstall
    clear
    chmod +x ./postinstall.sh
    ./postinstall.sh
    clear
    # End
    goodbye
else
    echo
    echo "Installer aborted..."
    exit
fi
