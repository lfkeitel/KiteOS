#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
sudo pacman -S --noconfirm --needed git

if [ ! -d "$HOME/code/000-dotfiles" ]; then
    mkdir -p "$HOME/code"
    git clone "https://github.com/lfkeitel/dotfiles" "$HOME/code/000-dotfiles"
fi

cd "$HOME/code/000-dotfiles"
./install-powershell.sh

TERM=xterm ./install.ps1 pacman
sudo pacman -S --needed - < "$DIR/pkglist.txt"

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
case $response in
    0) TERM=xterm ./install.ps1;;
    1) install_common_configs;;
esac