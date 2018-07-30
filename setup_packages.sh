#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

infobox() {
    dialog --infobox "$1" 4 50
}

infobox "Ensuring git is installed..."
sudo pacman -S --noconfirm --needed git

infobox "Downloading dotfiles repo..."
if [ ! -d "$HOME/code/000-dotfiles" ]; then
    mkdir -p "$HOME/code"
    git clone "https://github.com/lfkeitel/dotfiles" "$HOME/code/000-dotfiles"
fi

cd "$HOME/code/000-dotfiles"

gpg --recv-keys 465022E743D71E39 # Jonni Westphalen - aurman

infobox "Installing PowerShell..."
./install-powershell.sh

infobox "Setting up Pacman..."
TERM=xterm ./install.ps1 pacman

# TODO: Prompt is user wants packages from my repo
echo "In the following shell, please trust my key ultimately (press Enter)"
sudo /bin/bash -c "pacman-keys --recv-keys E638625F && pacman-keys --edit lee@keitel.xyz"
sudo pacman -S --noconfirm --needed - < "$DIR/pkglist.txt"

install_common_configs() {
    TERM=xterm
    ./install.ps1 zsh
    ./install.ps1 configs
    ./install.ps1 fonts
    ./install.ps1 vscode
    ./install.ps1 vim

    dialog --title "Install GPG Agent" \
        --backtitle "Install GPG Agent" \
        --defaultno \
        --yesno "Would you like to install the GPG Agent?" 7 60

    response=$?
    case $response in
        0) ./install.ps1 gpg -NoKey;;
    esac
}

dialog --title "Are you Lee?" \
    --backtitle "Are you Lee?" \
    --defaultno \
    --yesno "Are you Lee and want to install more customized configs?" 7 60

response=$?

infobox "Installing configs..."
case $response in
    0) TERM=xterm ./install.ps1;;
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
