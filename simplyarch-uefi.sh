#!/bin/bash
clear
echo
echo "Welcome to SimplyArch Installer (UEFI)"
echo "Copyleft 2021 Victor Bayas"
echo
echo "DISCLAIMER: THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED"
echo "NOTE: Make sure to TYPE CORRECTLY because this script won't perform any user input validation"
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
	echo "Region & Language"
	echo
	echo "EXAMPLES:"
	echo "us United States | us-acentos US Intl | latam Latin American Spanish | es Spanish"
	read -p "Keyboard layout: " keyboard 
	#echo
	#echo "EXAMPLES: America/New_York | Europe/Berlin"
	#read -p "Timezone: " timezone
	echo
	echo "EXAMPLES: en_US.UTF-8 | es_EC.UTF-8"
	read -p "Locale: " locale
	clear
	# Ask account
	echo "Account Setup"
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
	echo "Partition Table"
	echo
	lsblk
	echo
	echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
	read -p "Root partition: " rootPart
	mkfs.ext4 $rootPart
	mount $rootPart /mnt
	mkdir -p /mnt/boot/efi
	clear
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
	mount $efiPart /mnt/boot/efi
	echo
	read -p "Where do you want to install GRUB (e.g. /dev/sda): " grub
	clear
	echo "Partition Table"
	echo
	lsblk
	echo
	echo "NOTE: If you don't want to use a Swap partition type N above"
	echo
	echo "Write the name of the partition e.g: /dev/sdaX /dev/nvme0n1pX"
	read -p "Swap partition: " swap
	if [[ $swap == "n" || $swap == "N" || $swap == "no" || $swap == "No" ]]
	then
		echo
		echo "Swap partition not selected"
		pause 1
	else
		mkswap $swap
		swapon $swap
	fi
	clear
	# update mirrors
	chmod +x simple_reflector.sh
	./simple_reflector.sh
	clear
	# Install base system
	pacstrap /mnt base base-devel linux linux-firmware linux-headers grub efibootmgr os-prober bash-completion sudo nano vim networkmanager ntfs-3g neofetch htop git reflector xdg-user-dirs e2fsprogs man-db
	# Fstab
	genfstab -U /mnt >> /mnt/etc/fstab
	# configure base system
	# locales
	echo "$locale UTF-8" > /mnt/etc/locale.gen
	arch-chroot /mnt /bin/bash -c "locale-gen" 
	echo "LANG=$locale" > /mnt/etc/locale.conf
	# timezone
	arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
	arch-chroot /mnt /bin/bash -c "hwclock --systohc"
	# keyboard
	echo "KEYMAP="$keyboard"" > /mnt/etc/vconsole.conf
	# enable multilib
	sed -i '93d' /mnt/etc/pacman.conf
	sed -i '94d' /mnt/etc/pacman.conf
	sed -i "93i [multilib]" /mnt/etc/pacman.conf
	sed -i "94i Include = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.co
	# hostname
	echo "$hostname" > /mnt/etc/hostname
	echo "127.0.0.1	localhost" > /mnt/etc/hosts
	echo "::1		localhost" >> /mnt/etc/hosts
	echo "127.0.1.1	$hostname.localdomain	$hostname" >> /mnt/etc/hosts
	# grub
	arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --recheck"
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
	# yay
	echo "Installing Yay..."
	echo "cd && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd && rm -rf yay-bin" | arch-chroot /mnt /bin/bash -c "su $user"
	clear
	echo "SimplyArch Installer (UEFI)"
	echo
	echo ">>> Installation finished sucessfully <<<"
	echo
	echo "System will reboot in a moment..."
	sleep 3
	clear
	umount -a
	reboot
fi
