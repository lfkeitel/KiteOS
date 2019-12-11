#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

infobox() {
    dialog --infobox "$1" 4 50
}

infobox "Downloading dotfiles repo..."
if [ ! -d "$HOME/code/000-dotfiles" ]; then
    mkdir -p "$HOME/code"
    git clone "https://github.com/lfkeitel/dotfiles" "$HOME/code/000-dotfiles"
    cd "$HOME/code/000-dotfiles"
else
    cd "$HOME/code/000-dotfiles"
    git pull
fi

infobox "Setting up Pacman..."
./install.py pacman

# TODO: Prompt if user wants packages from my repo
echo "In the following shell, please trust my key ultimately (press Enter)"
read -k 1
sudo /bin/bash -c "pacman-key --recv-keys E638625F && pacman-key --edit lee@keitel.xyz"

sudo pacman -Sy # Download repo databases
sudo pacman -S --noconfirm --needed - < "$DIR/pkglist.txt"

install_common_configs() {
    ./install.py zsh
    ./install.py fish
    ./install.py configs
    ./install.py fonts
    ./install.py vscode
    ./install.py vim

    dialog --title "Install GPG Agent" \
        --backtitle "Install GPG Agent" \
        --defaultno \
        --yesno "Would you like to install the GPG Agent?" 7 60

    response=$?
    case $response in
        0) ./install.py gpg -NoKey;;
    esac
}

dialog --title "Are you Lee?" \
    --backtitle "Are you Lee?" \
    --defaultno \
    --yesno "Are you Lee and want to install more customized configs?" 7 60

response=$?

infobox "Installing configs..."
case $response in
    0) ./install.py;;
    1) install_common_configs;;
esac

infobox "Enabling system services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable lightdm.service
sudo systemctl enable haveged.service
sudo systemctl enable org.cups.cupsd.service

dialog --title "Restart PC" \
    --backtitle "Restart PC" \
    --defaultno \
    --yesno "To ensure everything is setup and running, it's recommended to reboot your machine.\n\nWould you like to reboot now?" 10 60

response=$?
case $response in
    0) sudo systemctl reboot;;
esac
