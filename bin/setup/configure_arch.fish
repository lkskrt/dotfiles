#!/usr/bin/env fish

if contains -- -i $argv
    echo "Installing packages"
    sudo pacman -S --needed \
        alacritty \
        cups \
        dunst \
        fisher \
        firefox \
        gnome-calculator \
        gnome-font-viewer \
        gnome-keyring \
        gnome-screenshot \
        feh \
        fwupd \
        helm \
        helmfile \
        i3-wm \
        i3blocks \
        i3lock \
        inkscape \
        jq \
        keepassxc \
        libreoffice-fresh \
        light \
        lightdm \
        lightdm-slick-greeter \
        lxappearance \
        mupdf \
        nautilus \
        ncdu \
        netctl \
        network-manager-applet \
        networkmanager-openvpn \
        nextcloud-client \
        nodejs \
        npm \
        otf-font-awesome \
        pacman-contrib \
        pamixer \
        pavucontrol \
        pipewire \
        pipewire-pulse \
        playerctl \
        podman \
        podman-compose \
        pdftk \
        pwgen \
        ranger \
        rofi \
        rofimoji \
        snapper \
        starship \
        terraform \
        tig \
        traceroute \
        ttf-ibm-plex \
        vlc \
        xautolock
end

if contains -- --aur $argv
    echo "Installing AUR packages"
    yay -S --needed \
        dracula-gtk-theme \
        dracula-icons-git \
        g810-led-git \
        google-chrome \
        i3blocks-contrib-git \
        keybase-bin \
        krew-bin \
        powerline-fonts-git \
        spotify \
        teamviewer \
        vim-plug \
        visual-studio-code-bin \
        zoom
end

if not grep -q greeter-session=lightdm-slick-greeter /etc/lightdm/lightdm.conf
    echo "Configuring lightdm"
    sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
end

if not test -e /etc/X11/xorg.conf.d/00-keyboard.conf
    echo "Adding X keyboard config"
    echo -n 'Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "de"
    Option "XkbModel" "thinkpad"
    Option "XkbVariant" "nodeadkeys"
    Option "XkbOptions" "caps:escape"
EndSection
' >/tmp/00-keyboard.conf
    sudo mv /tmp/00-keyboard.conf /etc/X11/xorg.conf.d/
end

if not test -e /etc/X11/xorg.conf.d/30-touchpad.conf
    echo "Adding X touchpad config"
    echo -n 'Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
EndSection
' >/tmp/30-touchpad.conf
    sudo mv /tmp/30-touchpad.conf /etc/X11/xorg.conf.d/
end

if not test -e /etc/modprobe.d/nobeep.conf
    echo "Disable beeping"
    echo '# Disable beeping
blacklist pcspkr
blacklist snd_pcsp
' >/tmp/nobeep.conf
    sudo mv /tmp/nobeep.conf /etc/modprobe.d/
end

if grep -q 'PasswordAuthentication yes' /etc/ssh/sshd_config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
end

if contains -- --systemd $argv
    echo "Enable systemd units"
    sudo systemctl enable lightdm sshd
    systemctl enable --user pipewire-pulse
end

if not test -e ~/.git
    cd ~
    git clone git@github.com:lkskrt/dotfiles.git
    cp -r dotfiles/* dotfiles/.* .
    rm -rf dotfiles

    fisher update
end

if not test -e ~/.config/i3/config
    mkdir ~/.config/sway
    ~/.config/i3/build
end
