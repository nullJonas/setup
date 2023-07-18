#!/bin/sh

# Configuração
DEVICE=/dev/nvme0n1
PRE=p
HOSTNAME=lenovinho
MICROCODE=amd-ucode

# Ativa sincronização do relógio
echo -e "\033[1;36m Ativa sincronização do relógio \033[m"
timedatectl set-ntp true

# Particiona o disco
echo -e "\033[1;36m Particiona o disco \033[m"
parted $DEVICE mklabel gpt
parted $DEVICE mkpart boot fat32 1MiB 512MiB
parted $DEVICE mkpart swap linux-swap 512MiB 4608MiB
parted $DEVICE mkpart root ext4 4608MiB 100%
parted $DEVICE set 1 esp on

# Formata as partições
echo -e "\033[1;36m Formata as partições \033[m"
mkfs.fat -F 32 "$DEVICE""$PRE"1
mkswap "$DEVICE""$PRE"2
mkfs.ext4 "$DEVICE""$PRE"3

# Monta as partições
echo -e "\033[1;36m Monta as partições \033[m"
mount "$DEVICE""$PRE"3 /mnt
mkdir /mnt/boot
mount "$DEVICE""$PRE"1 /mnt/boot

# Liga o swap
echo -e "\033[1;36m Liga o swap \033[m"
swapon "$DEVICE""$PRE"2

# Seleciona os mirrors mais rápidos para download
echo -e "\033[1;36m Seleciona os mirrors mais rápidos para download \033[m"
curl -o mirrorlist "https://archlinux.org/mirrorlist/?country=BR&use_mirror_status=on"
sed -e 's/^#Server/Server/' -e '/^#/d' mirrorlist > /etc/pacman.d/mirrorlist.backup
pacman -S --noconfirm pacman-contrib
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Instala o kernel e pacotes básicos
echo -e "\033[1;36m Instala o kernel e pacotes básicos \033[m"
pacstrap /mnt base base-devel linux linux-firmware

# Gera o arquivo fstab
echo -e "\033[1;36m Gera o arquivo fstab \033[m"
genfstab -U /mnt >> /mnt/etc/fstab

# Faz o chroot
echo -e "\033[1;36m Faz o chroot \033[m"
arch-chroot /mnt

# Configura o idioma e o fuso horário
echo -e "\033[1;36m Configura o idioma e o fuso horário \033[m"
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

# Configura a rede
echo -e "\033[1;36m Configura a rede \033[m"
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1    localhost    $HOSTNAME" >> /etc/hosts
echo "::1          localhost    $HOSTNAME" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME" >> /etc/hosts
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Instala o bootloader e microcode
echo -e "\033[1;36m Instala o bootloader e microcode \033[m"
pacman -S --noconfirm grub-efi-x86_64 efibootmgr $MICROCODE
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Define a senha do root
echo -e "\033[1;36m Define a senha do root \033[m"
echo "Escolha uma senha para o usuário root"
passwd

# Termina a instalação e desliga o computador
echo -e "\033[1;36m Termina a instalação e desliga o computador \033[m"
exit
umount -R /mnt
shutdown now