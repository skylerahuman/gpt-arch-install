#!/bin/bash

# Partition the NVME drive
sgdisk -Z /dev/nvme0n1
sgdisk -n 1::+512M -t 1:ef00 -c 1:"EFI System Partition" /dev/nvme0n1
sgdisk -n 2:: -t 2:8300 -c 2:"Arch Linux" /dev/nvme0n1

# Format the partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2

# Mount the partitions
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install the Arch Linux base packages
pacstrap /mnt base linux-firmware base-devel

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt

# Install the bootloader
bootctl install

# Install Paru AUR helper
pacman -S --noconfirm base-devel git
cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm

# Install the Linux-Liquorix kernel and AMD microcode
paru -S --noconfirm linux-liquorix amd-ucode

# Generate initramfs for the new kernel
mkinitcpio -p linux-liquorix

# Configure the bootloader
echo "default arch" > /boot/loader/loader.conf
echo "timeout 5" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf

echo "title   Arch Linux" > /boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux-liquorix" >> /boot/loader/entries/arch.conf
echo "initrd  /amd-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux-liquorix.img" >> /boot/loader/entries/arch.conf
echo "options root=/dev/nvme0n1p2 rw zswap.enabled=1" >> /boot/loader/entries/arch.conf

# Install Wayland compositor and tooling
pacman -S --noconfirm sway wlroots wayland-protocols

# Install VFIO for GPU passthrough
pacman -S --noconfirm qemu libvirt virt-manager

# Install audio and video codecs
pacman -S --noconfirm ffmpeg gstreamer

# Install Brave browser
paru -S --noconfirm brave-bin

# Install Discord
paru -S --noconfirm discord

# Install Steam
paru -S --noconfirm steam

# Install OBS
paru -S --noconfirm obs-studio

# Install Davinci Resolve
paru -S --noconfirm davinci-resolve

# Install Proton for gaming in Linux
pacman -S --noconfirm proton

# Install file manager
pacman -S --noconfirm thunar

# Install zswap for improved memory performance
echo "zswap.enabled=1" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install Btrfs filesystem utilities
pacman -S --noconfirm btrfs-progs

# Set up dotfiles
