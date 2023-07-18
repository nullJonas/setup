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
mv chroot.sh /mnt/
arch-chroot /mnt ./chroot.sh

# Termina a instalação e desliga o computador
echo -e "\033[1;36m Termina a instalação e desliga o computador \033[m"
umount -R /mnt
shutdown now