#!/bin/sh

# Configuração
export VIDEO_DRIVER=xf86-video-ati
export USERNAME=joni

# Ativa o repositório multilib
sed -i "/[multilib]/{N;s/^#//;}" /etc/pacman.conf

# Atualiza sistema
pacman -Syu --noconfirm

# Instala pacotes para o sistema
pacman -S --noconfirm sudo xorg-server $VIDEO_DRIVER mesa bash-completion\
    bluez bluez-utils cups ffmpegthumbnailer gnome-keyring i3-wm i3lock\
    i3status

#Cria um usuário normal com permissão de usar sudo
useradd -m -G wheel,video $USERNAME
sed -i "/root ALL=(ALL:ALL) ALL/a\
$USERNAME ALL=(ALL:ALL) ALL" /etc/sudoers
echo "Escolha a senha do novo usuário"
passwd $USERNAME

