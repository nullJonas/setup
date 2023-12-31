#!/bin/sh

# Configuração
export VIDEO_DRIVER=xf86-video-ati
export GPU_TYPE=radeon
export USERNAME=joni

# Ativa o repositório multilib
echo -e "\033[1;36m Ativa o repositório multilib \033[m"
sed -i '/\[multilib\]/,+1 s/^#//' /etc/pacman.conf

# Atualiza sistema
echo -e "\033[1;36m Atualiza sistema \033[m"
pacman -Syu --noconfirm

# Cria um usuário normal com permissão para usar sudo sem senha
echo -e "\033[1;36m Cria um usuário normal com permissão de usar sudo \033[m"
useradd -m -G wheel,video $USERNAME
sed -i "/root ALL=(ALL:ALL) ALL/a\
$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers
echo "Escolha a senha do novo usuário"
passwd $USERNAME



# ======================================================================
# ====================== INSTALANDO OS PACOTES =========================
# ======================================================================
echo -e "\033[1;36m INSTALANDO OS PACOTES... \033[m"

# Ambiente gráfico (com i3wm)
pacman -S --noconfirm xorg-server $VIDEO_DRIVER mesa i3-wm i3lock i3status\
    picom rofi xorg-xbacklight xorg-xclipboard xorg-xinit xorg-xinput\
    xorg-xkill xorg-xrandr nitrogen alacritty

# Fontes
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# Programas que eu uso
pacman -S --noconfirm ark btop cmus discord firefox flameshot imv\
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
    smartmontools thunar-archive-plugin tumbler unzip wget xdg-utils zip

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
# pacman -S --noconfirm bluez bluez-utils

# Instala yay para poder baixar pacotes da AUR
echo -e "\033[1;36m Instala yay para poder baixar pacotes da AUR \033[m"
pacman -S --noconfirm go
cd /home/$USERNAME
su -c "
git clone https://aur.archlinux.org/yay.git && \
cd yay && \
makepkg -sic --noconfirm --needed && \
cd .. && \
rm -rf yay" $USERNAME
cd ~/setup

# Copia arquivos de configuração
echo -e "\033[1;36m Copia arquivos de configuração \033[m"
mkdir /home/$USERNAME/.config
cp config/picom.conf /etc/xdg/
cp -r config/i3 /home/$USERNAME/.config/
cp -r config/flameshot /home/$USERNAME/.config/
cp -r config/yay /home/$USERNAME/.config/
cp config/.bashrc /home/$USERNAME/
cp config/.xinitrc /home/$USERNAME/
cp config/30-touchpad.conf /etc/X11/xorg.conf.d/

# Instala pacotes da AUR que eu uso
echo -e "\033[1;36m Instala pacotes da AUR que eu uso \033[m"
su -c "LANG=C yay --noprovides --answerdiff None --answerclean None --mflags \
    "--noconfirm" -S epson-inkjet-printer-escpr minecraft-launcher \
    mkinitcpio-numlock osu-lazer-bin visual-studio-code-bin" $USERNAME

# Faz o usuário precisar de senha para usar sudo
sed -i "/$USERNAME/d" /etc/sudoers
sed -i "/root ALL=(ALL:ALL) ALL/a\
$USERNAME ALL=(ALL:ALL) ALL" /etc/sudoers

# Baixa e seta o wallpaper
echo -e "\033[1;36m Baixa e seta o wallpaper \033[m"
mkdir -p /home/$USERNAME/images/wallpapers
wget https://wallpapercave.com/wp/wp4162242.png\
    -O /home/$USERNAME/images/wallpapers/celeste.png
# Não da pra setar o wallpaper antes de entrar no xorg
# su -c "nitrogen --set-zoom-fill ~/images/wallpapers/celeste.png" $USERNAME

# Ajeita as permissões da home do usuário
echo -e "\033[1;36m Ajeita as permissões da home do usuário \033[m"
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Escolhe o thunar como gerenciador de arquivos padrão
echo -e "\033[1;36m Escolhe o thunar como gerenciador de arquivos padrão \033[m"
mkdir ~/.config
xdg-mime default thunar.desktop inode/directory
su -c "xdg-mime default thunar.desktop inode/directory" $USERNAME

# Liga o timer para fazer a nivelação de desgaste no SSD semanalemente
echo -e "\033[1;36m Liga o timer para fazer a nivelação de desgaste no SSD semanalmente \033[m"
systemctl enable fstrim.timer

# Limpeza
cd ..
rm -rf setup

# TODO:
# --configurar temas
# --ligar numlock no boot