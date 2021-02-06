<p align="center">
  <a href="https://github.com/victor-bayas/simplyarch">
    <img src="img/laptop.png" alt="laptop-mockup" height="200">
  </a>
  <h1 align="center">SimplyArch Installer</h1>
  <p align="center">
    The simplest way to install a base Arch Linux system without the bloat
  </p>
</p>

## Disclaimer
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED
# Pre-requisites 🔎
- A working internet connection
- **Being a somewhat advanced user**
- A previously partitioned disk
- **UEFI only** (BIOS version soon™)
# What this script will do ✅
- Install a functional base system
- Setup your keyboard, locales, timezone and hostname
- Create a standard user with sudo permissions
- Install popular utilities such as `vim` `nano` `htop` `neofetch` and our `simple_reflector.sh` tool
- **(NEW)** Installs `paru` as the AUR helper instead of `yay`
# What this script won't do 🚫
- Install any driver not included within the kernel
- Install a DE/WM or any GUI application
- Make questionable choices for you
# How to use it 📖
- Boot latest Arch Linux ISO
- Load your keyboard e.g `loadkeys us-acentos`
- Connect to the internet
- Partition the disk with the tool of your choice
- Install git `pacman -Sy git`
- Clone this repo `git clone https://github.com/victor-bayas/simplyarch`
- Run the `simplyarch-uefi.sh` file and follow on-screen instructions
# And now what? ❓
- Install drivers not included with the kernel if your hardware needs it (e.g. Nvidia, Broadcom, VAAPI, etc)
- Install `xorg-core`, a DM and the DE/WM of your choice
- Install any other application you need
- Profit 
