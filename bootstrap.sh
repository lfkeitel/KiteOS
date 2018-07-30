#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Install dialog
pacman -S --noconfirm --needed dialog || {
    echo "Error at script start: Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection?"
    exit
}

dialog \
    --title "Welcome!" \
    --msgbox "Welcome to the KiteOS Bootstrapping Script!\n\nThis script will automatically many preliminary or tedious items for your new Arch system." \
    10 60

get_input() {
    dialog --no-cancel --inputbox "$1" 10 60 3>&1 1>&2 2>&3 3>&1
}

get_secret() {
    dialog --no-cancel --insecure --passwordbox "$1" 10 60 3>&1 1>&2 2>&3 3>&1
}

infobox() {
    dialog --infobox "$1" 4 50
}

[ ! -d /mnt/bin ] && pacstrap /mnt base base-devel networkmanager vim git
genfstab -U /mnt >> /mnt/etc/fstab

cp -R "$DIR" /mnt/KiteOS
arch-chroot /mnt /KiteOS/bootstrap2.sh

dialog \
    --title "All done!" \
    --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be in place.\n\nPlease check your install and restart.\n\nMake sure to run 'arch-chroot /mnt' first." \
    12 80

dialog \
    --title "Additional Configuration" \
    --msgbox "If you would like a fully furnished install, please checkout my dotfiles repo." \
    12 80
clear
