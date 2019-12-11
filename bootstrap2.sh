#!/bin/bash
get_input() {
    dialog --no-cancel --inputbox "$1" 10 60 3>&1 1>&2 2>&3 3>&1
}

get_secret() {
    dialog --no-cancel --insecure --passwordbox "$1" 10 60 3>&1 1>&2 2>&3 3>&1
}

infobox() {
    dialog --infobox "$1" 4 50
}

# Setup main user
name=$(get_input "Username:")

re="^[a-z_][a-z0-9_-]*$"
while ! [[ "${name}" =~ ${re} ]]; do
    name=$(get_input "Username not valid. Give a username beginning with a letter, with only lowercase letters, - and _:")
done

pass1="$(get_secret "Password:")"
pass2="$(get_secret "Repeat password:")"

while [[ $pass1 != $pass2 ]]; do
    pass1="$(get_secret "Passwords do not match.\n\nPassword:")"
    pass2="$(get_secret "Repeat password:")"
    unset pass2
done

infobox "Adding user \"$name\"..."
useradd -m -g wheel -s /bin/bash $name >/dev/tty6
echo "$name:$pass1" | chpasswd >/dev/tty6

infobox "Setting up time..."
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

infobox "Setting up locale..."
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

hostname=$(get_input "Hostname:")

re="^[a-z_][a-z0-9_-]*$"
while ! [[ "${hostname}" =~ ${re} ]]; do
    hostname=$(get_input "Hostname not valid. Give a hostname beginning with a letter, with only lowercase letters, - and _:")
done

infobox "Setting up hostname..."
echo "$hostname" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1	localhost
::1	localhost
127.0.0.1	$hostname
EOF

# Get PARTUUID for root partition
cmd=(dialog --nocancel --backtitle "Root Partition" --radiolist "Select Root Partition:" 22 80 16)

available_disks=()
while IFS= read -r line; do
    available_disks+=("$line")
done < <(blkid)

options=()
index=0

for i in "${available_disks[@]}"; do
    options+=($index)
    options+=("$i")
    options+=(off)
    index=$(expr $index + 1)
done
unset index

choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

partuuid="$(echo "${available_disks[$choice]}" | sed -n 's/.*PARTUUID=\"\([^\"]*\)\".*/\1/p')"

infobox "Setting up UEFI boot entry..."
bootctl install

dialog --title "Are you using Intel?" \
    --backtitle "Are you using Intel?" \
    --yesno "Are you using an Intel CPU and not using a VM?" 7 60

response=$?
ucode_line=''
case $response in
    0) ucode_line=$'initrd /intel-ucode.img\n' && pacman -S --noconfirm --needed intel-ucode;;
esac

cat >/boot/loader/entries/arch.conf <<EOF
title KiteOS
linux /vmlinuz-linux
${ucode_line}initrd /initramfs-linux.img
options root=PARTUUID=$partuuid rw
EOF

cat >/boot/loader/entries/arch-zen.conf <<EOF
title KiteOS Zen
linux /vmlinuz-linux-zen
${ucode_line}initrd /initramfs-linux-zen.img
options root=PARTUUID=$partuuid rw
EOF


echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

infobox "Enabling Network Manager..."
systemctl enable NetworkManager

infobox "Disabling PC speaker..."
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

infobox "Setting up Pacman hooks..."
mkdir -p /etc/pacman.d/hooks

cat >/etc/pacman.d/hooks/package-list.hook <<EOF
[Trigger]
Type = Package
Operation = Install
Operation = Remove
Target = *

[Action]
Description = Generating package list...
When = PostTransaction
Exec = /bin/sh -c '/usr/bin/pacman -Qqe > /etc/packages.txt'
EOF

cat >/etc/pacman.d/hooks/systemd-boot.hook <<EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF
