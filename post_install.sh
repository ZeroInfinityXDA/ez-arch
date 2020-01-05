#!/bin/bash
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
locale-gen
printf "\n"

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
cat /etc/locale.conf
printf "\n"

echo "KEYMAP=uk" > /etc/vconsole.conf
cat /etc/vconsole.conf
printf "\n"

read -p "Enter a hostname: " hostname
echo "$hostname" > /etc/hostname
cat /etc/hostname
printf "\n"

printf "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 $hostname.localdomain $hostname" > /etc/hosts
cat /etc/hosts
printf "\n\n"

printf "Enter a root password\n"
passwd
printf "\n"

bootctl --path=/boot install
printf "\n"

printf "timeout 3\ndefault arch" > /boot/loader/loader.conf
cat /boot/loader/loader.conf
printf "\n\n"

fdisk -l
printf "\n"

read -p "Enter root partition id (e.g. sda2): " rootpart
read -p "Does your CPU require ucode? [n/intel/amd]: " ucode
printf "\n"

if [[ "$ucode" == "intel" ]]
then
    printf "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img\noptions root=/dev/$rootpart rw" > /boot/loader/entries/arch.conf
elif [[ "$ucode" == "amd" ]]
then
    printf "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /amd-ucode.img\ninitrd /initramfs-linux.img\noptions root=/dev/$rootpart rw" > /boot/loader/entries/arch.conf
else
    printf "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=/dev/$rootpart rw" > /boot/loader/entries/arch.conf
fi

cat /boot/loader/entries/arch.conf
printf "\n\n"

ifconfig
printf "\n"

read -p "Enter your network interface name (e.g. enp0s4): " nic
ip link set $nic up
dhcpcd
printf "\n"

cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/inet
sed -i "s/eth0/$nic/g" "/etc/netctl/inet"
cat /etc/netctl/inet
printf "\n"

systemctl enable netctl-ifplugd@$nic
systemctl enable sshd

read -p "\nEnter a username: " username
useradd -m $username
passwd $username
printf "\nAdd '$username ALL=(ALL) ALL' in sudoers file without quotes and save the file\n"
read -p "Press enter to continue..."
EDITOR=nano visudo

printf "\nInstall finished! You may now exit chroot and reboot!\n"
