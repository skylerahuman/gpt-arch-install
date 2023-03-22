#!/bin/bash

# Install required packages
pacman -S --noconfirm qemu libvirt virt-manager

# Set up VFIO modules
echo "options vfio-pci ids=1002:73bf,1002:ab28" > /etc/modprobe.d/vfio.conf
echo "options vfio-pci disable_vga=1" >> /etc/modprobe.d/vfio.conf
echo "vfio-pci" >> /etc/modules-load.d/vfio.conf

# Reload the modules
modprobe -r vfio_pci vfio_iommu_type1 vfio
modprobe vfio

# Add kernel parameters for VFIO
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on /' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="video=efifb:off"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Configure evdev passthrough for keyboard and mouse
echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="event[0-9]*", SUBSYSTEM=="input", GROUP="input", MODE="0660"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="mouse[0-9]*", SUBSYSTEM=="input", GROUP="input", MODE="0660"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="ts[0-9]*", SUBSYSTEM=="input", GROUP="input", MODE="0660"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="mice",      MODE="0660", GROUP="input"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="mouse*",    MODE="0660", GROUP="input"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="evdev",     MODE="0660", GROUP="input"' >> /etc/udev/rules.d/50-evdev.rules
echo 'KERNEL=="input*",    MODE="0660", GROUP="input"' >> /etc/udev/rules.d/50-evdev.rules

# Configure USB passthrough for audio controller
echo 'options usbcore autosuspend=-1' > /etc/modprobe.d/usbcore.conf
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0d8c", ATTR{idProduct}=="0008", MODE="0666", GROUP="input"' > /etc/udev/rules.d/50-audio.rules

# Install and configure virtio-gpu
pacman -S --noconfirm xf86-video-qxl
echo 'options qxl' > /etc/modprobe.d/qxl.conf
echo 'qxl' > /etc/modules-load.d/qxl.conf
