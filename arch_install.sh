#!/bin/bash
timedatectl set-ntp true
cfdisk
printf "\n"

read -p "Enter EFI partition name (e.g. sda1): " efidrive
read -p "Enter Root partition name (e.g. sda2): " rootdrive
read -p "Did you already have an existing EFI partition? (y/n)" doesefiexist
printf "\n"

if [[ "$doesefiexist" == "n" ]]
then
    mkfs.fat -F32 /dev/$efidrive
    printf "\n"
fi

mkfs.ext4 /dev/$rootdrive
printf "\n"

mount /dev/$rootdrive /mnt
mkdir /mnt/boot
mount /dev/$efidrive /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware net-tools dhcpcd netctl ifplugd neofetch openssh nano wget git sudo

#Extras:
# pacstrap /mnt linux-headers intel-ucode nvidia-dkms nvidia-utils bluez bluez-utils

genfstab -U /mnt >> /mnt/etc/fstab
printf "\nBase install done!\n"
printf "Enter command: [arch-chroot /mnt] and use [wget] to download the post_install.sh script from the same github repo you got this script from (make sure you wget the raw file)!\n"
