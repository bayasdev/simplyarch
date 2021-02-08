#!/bin/bash
clear
echo
echo "Welcome to SimplyArch Installer"
echo "Copyright (C) 2021 Victor Bayas"
echo
echo "DISCLAIMER: THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED"
echo
echo "WARNING: Make sure to TYPE CORRECTLY because this script won't perform any user input validation"
echo
echo "We'll guide you through the installation process of a functional base Arch Linux system"
echo
echo "\"btw btw btw btw btw btw\""
echo "- a satisfied SimplyArch user"
echo
read -p "Do you want to continue? (Y/N): " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
	#timedatectl set-ntp true
	clear
	# Ask locales
	echo ">>> Region & Language <<<"
	echo
	echo "EXAMPLES:"
	echo "us United States | us-acentos US Intl | latam Latin American Spanish | es Spanish"
	read -p "Keyboard layout: " keyboard 
	if [ -z "$keyboard" ]
	then
		keyboard="us"
	fi
	#echo
	#echo "EXAMPLES: America/New_York | Europe/Berlin"
	#read -p "Timezone: " timezone
	echo
	echo "EXAMPLES: en_US | es_ES (don't add .UTF-8)"
	read -p "Locale: " locale
	if [ -z "$locale" ]
	then
		locale="en_US"
	fi
	clear
	# Ask account
	echo ">>> Account Setup <<<"
	echo
	read -p "Hostname: " hostname
	echo
	echo "Administrator User"
	echo "User: root"
	read -sp "Password: " rootpw
	echo
	read -sp "Re-type password: " rootpw2
	echo
	while [ $rootpw != $rootpw2 ]
	do
		echo
		echo "Passwords don't match. Try again"
		echo
		read -sp "Password: " rootpw
		echo
		read -sp "Re-type password: " rootpw2
		echo
	done
	echo
	echo "Standard User"
	read -p "User: " user
	read -sp "Password: " userpw
	echo
	read -sp "Re-type password: " userpw2
	echo
	while [ $userpw != $userpw2 ]
	do
		echo
		echo "Passwords don't match. Try again"
		echo
		read -sp "Password: " userpw
		echo
		read -sp "Re-type password: " userpw2
		echo
	done
	# Disk setup
	clear
	echo ">>> Disks Setup <<<"
	echo
	echo "Make sure to have your disk previously partitioned, if you are unsure press CTRL+C and run this script again"
	sleep 5
	clear
	echo "Partition Table"
	echo
	lsblk
	echo
	while ! [[ "$partType" =~ ^(1|2)$ ]] 
	do
		echo "Please select partition type (1/2):"
		echo "1. EXT4"
		echo "2. BTRFS"
		read -p "Partition Type: " partType
	done
	clear
	echo "Partition Table"
	echo
	lsblk
	echo
	echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
	read -p "Root partition: " rootPart
	case $partType in
		1)
			mkfs.ext4 $rootPart
			mount $rootPart /mnt
			;;
		2)
			mkfs.btrfs -f -L "Arch Linux" $rootPart
			mount $rootPart /mnt
			btrfs sub cr /mnt/@
			umount $rootPart
			mount -o relatime,space_cache=v2,compress=lzo,subvol=@ $rootPart /mnt
			mkdir /mnt/boot
			;;
	esac
	clear
	if [[ -d /sys/firmware/efi ]]
	then
		echo "Partition Table"
		echo
		lsblk
		echo
		echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
		read -p "EFI partition: " efiPart
		echo
		echo "DUALBOOT USERS: If you are sharing this EFI partition with another OS type N"
		read -p "Do you want to format this partition as FAT32? (Y/N): " formatEFI
		if [[ $formatEFI == "y" || $formatEFI == "Y" || $formatEFI == "yes" || $formatEFI == "Yes" ]]
		then
			mkfs.fat -F32 $efiPart
		fi
		mkdir -p /mnt/boot/efi
		mount $efiPart /mnt/boot/efi
		echo
		clear
	fi
	echo "Partition Table"
	echo
	lsblk
	echo
	echo "NOTE: If you don't want to use a Swap partition type N below"
	echo
	echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
	read -p "Swap partition: " swap
	if [[ $swap == "n" || $swap == "N" || $swap == "no" || $swap == "No" ]]
	then
		echo
		echo "Swap partition not selected"
		sleep 1
	else
		mkswap $swap
		swapon $swap
	fi
	clear
	# update mirrors
	chmod +x simple_reflector.sh
	./simple_reflector.sh
	clear
	echo ">>> Installing and configuring the base system <<<"
	echo
	echo "This process may take a while, please wait..."
	sleep 1
	# Install base system
	if [[ -d /sys/firmware/efi ]]
	then
		pacstrap /mnt base base-devel linux linux-firmware linux-headers grub efibootmgr os-prober bash-completion sudo nano vim networkmanager ntfs-3g neofetch htop git reflector xdg-user-dirs e2fsprogs man-db
	else
		pacstrap /mnt base base-devel linux linux-firmware linux-headers grub os-prober bash-completion sudo nano vim networkmanager ntfs-3g neofetch htop git reflector xdg-user-dirs e2fsprogs man-db
	fi
	# fstab
	genfstab -U /mnt >> /mnt/etc/fstab
	nano /mnt/etc/fstab
	# configure base system
	# locales
	echo "$locale.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	arch-chroot /mnt /bin/bash -c "locale-gen" 
	echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
	# timezone
	arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
	arch-chroot /mnt /bin/bash -c "hwclock --systohc"
	# keyboard
	echo "KEYMAP="$keyboard"" > /mnt/etc/vconsole.conf
	# enable multilib
	sed -i '93d' /mnt/etc/pacman.conf
	sed -i '94d' /mnt/etc/pacman.conf
	sed -i "93i [multilib]" /mnt/etc/pacman.conf
	sed -i "94i Include = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.conf
	# hostname
	echo "$hostname" > /mnt/etc/hostname
	echo "127.0.0.1	localhost" > /mnt/etc/hosts
	echo "::1		localhost" >> /mnt/etc/hosts
	echo "127.0.1.1	$hostname.localdomain	$hostname" >> /mnt/etc/hosts
	# grub
	if [[ -d /sys/firmware/efi ]]
	then
		arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch"
	else
		arch-chroot /mnt /bin/bash -c "grub-install ${rootPart::-1}"
	fi
	arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
	# networkmanager
	arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager.service"
	# root pw
	arch-chroot /mnt /bin/bash -c "(echo $rootpw ; echo $rootpw) | passwd root"
	# create user
	arch-chroot /mnt /bin/bash -c "useradd -m -G wheel $user"
	arch-chroot /mnt /bin/bash -c "(echo $userpw ; echo $userpw) | passwd $user"
	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
	# update mirrors
	cp ./simple_reflector.sh /mnt/home/$user/simple_reflector.sh
	arch-chroot /mnt /bin/bash -c "chmod +x /home/$user/simple_reflector.sh"
	arch-chroot /mnt /bin/bash -c "/home/$user/simple_reflector.sh"
	clear
	# paru
	echo ">>> Post-install routine <<<"
	echo
	echo "Installing the Paru AUR Helper..."
	echo "cd && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd && rm -rf paru-bin" | arch-chroot /mnt /bin/bash -c "su $user"
	clear
	echo "SimplyArch Installer"
	echo
	echo ">>> Installation finished sucessfully <<<"
	echo
	echo "System will reboot in a moment..."
	sleep 3
	clear
	umount -a
	reboot
fi
