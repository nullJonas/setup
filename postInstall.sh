#!/bin/sh

# Configuração
export VIDEO_DRIVER=xf86-video-ati
export GPU_TYPE=radeon
export USERNAME=joni

# Ativa o repositório multilib
sed -i '/\[multilib\]/,+1 s/^#//' /etc/pacman.conf

# Atualiza sistema
pacman -Syu --noconfirm

# Instala sudo
pacman -S --noconfirm sudo

#Cria um usuário normal com permissão de usar sudo
useradd -m -G wheel,video $USERNAME
sed -i "/root ALL=(ALL:ALL) ALL/a\
$USERNAME ALL=(ALL:ALL) ALL" /etc/sudoers
echo "Escolha a senha do novo usuário"
passwd $USERNAME



# ======================================================================
# ====================== INSTALANDO OS PACOTES =========================
# ======================================================================

# Ambiente gráfico (com i3wm)
pacman -S --noconfirm xorg-server $VIDEO_DRIVER mesa i3-wm i3lock i3status\
    picom rofi xorg-xbacklight xorg-xclipboard xorg-xinit xorg-xinput\
    xorg-xkill xorg-xrandr nitrogen alacritty

# Fontes
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# Programas que eu uso
pacman -S --noconfirm ark blender btop cmus discord firefox flameshot imv\
    kdeconnect keepassxc krita mpv obsidian simple-scan steam thunar\
    torbrowser-launcher yt-dlp

# Som
pacman -S --noconfirm pipewire-audio pipewire-pulse pipewire-alsa pavucontrol\

# Economia de bateria
pacman -S --noconfirm tlp tlp-rdw

# Montagem automática de discos
pacman -S --noconfirm udiskie udisks2

# Programação
pacman -S --noconfirm gdb git python-pip julia nodejs npm

# Pacotes aleatórios que são úteis
pacman -S --noconfirm bash-completion ffmpegthumbnailer gnome-keyring numlockx\
    pacman-contrib imagemagick light lshw lxappearance man-db neofetch\
    smartmontools thunar-archive-plugin tumbler unzip wget zip

# Suporte para jogos com o wine
pacman -S --noconfirm lib32-mesa lib32-vulkan-"$GPU_TYPE" vulkan-"$GPU_TYPE" wine\
    winetricks

# Suporte para MTP
pacman -S --noconfirm mtpfs gvfs-mtp

# Suporte para ntfs
pacman -S --noconfirm ntfs-3g

# Suporte para impressão
pacman -S --noconfirm cups

# Suporte para bluetooth
pacman -S --noconfirm bluez bluez-utils



# Instala yay para poder baixar pacotes da AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sic --noconfirm --needed
cd ..
rm -rf yay

# Copia arquivos de configuração
mkdir /home/$USERNAME/.config
cp config/picom.conf /etc/xdg/
cp -r config/i3 /home/$USERNAME/.config/
cp -r config/flameshot /home/$USERNAME/.config/
cp -r config/yay /home/$USERNAME/.config/
cp config/.bashrc /home/$USERNAME/
cp config/.xinitrc /home/$USERNAME/

# Instala pacotes da AUR que eu uso
yay -Sc --clean epson-inkjet-printer-escpr minecraft-launcher \
    mkinitcpio-numlock osu-lazer-bin visual-studio-code-bin

# Baixa e seta o wallpaper
mkdir -p /home/$USERNAME/images/wallpapers
wget https://wallpapercave.com/wp/wp4162242.png\
    -O /home/$USERNAME/images/wallpapers/celeste.png

# Ajeita as permissões da home do usuário
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Escolhe o thunar como gerenciador de arquivos padrão
xdg-mime default thunar.desktop inode/directory
su -c "xdg-mime default thunar.desktop inode/directory" $USERNAME

# Faz a nivelação de desgaste no SSD semanalemente
systemctl enable fstrim.timer

# TODO:
# --configurar temas
# --ligar numlock no boot
# --não travar touchpad enquanto digita
# --