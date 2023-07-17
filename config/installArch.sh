#!/bin/sh

# Configuração
DEVICE=/dev/nvme0n1
PRE=p
HOSTNAME=lenovinho
MICROCODE=amd-ucode

# Ativa sincronização do relógio
timedatectl set-ntp true

# Particiona o disco
parted $DEVICE mklabel gpt
parted $DEVICE mkpart boot fat32 1MiB 512MiB
parted $DEVICE mkpart swap linux-swap 512MiB 4608MiB
parted $DEVICE mkpart root ext4 4608MiB 100%
parted $DEVICE set 1 esp on

# Formata as partições
mkfs.fat -F 32 "$DEVICE""$PRE"1
mkswap "$DEVICE""$PRE"2
mkfs.ext4 "$DEVICE""$PRE"3

# Monta as partições
mount "$DEVICE""$PRE"3 /mnt
mkdir /mnt/boot
mount "$DEVICE""$PRE"3 /mnt/boot

# Liga o swap
swapon "$DEVICE""$PRE"2

# Seleciona os mirrors mais rápidos para download
curl -o mirrorlist "https://archlinux.org/mirrorlist/?country=BR&use_mirror_status=on"
sed -e 's/^#Server/Server/' -e '/^#/d' mirrorlist > /etc/pacman.d/mirrorlist.backup
pacman -S --noconfirm pacman-contrib
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Instala o kernel e pacotes básicos
pacstrap /mnt base base-devel linux linux-firmware

# Gera o arquivo fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Faz o chroot
arch-chroot /mnt

# Configura o idioma e o fuso horário
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

# Configura a rede
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1    localhost    $HOSTNAME" >> /etc/hosts
echo "::1          localhost    $HOSTNAME" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME" >> /etc/hosts
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Instala o bootloader e microcode
pacman -S --noconfirm grub-efi-x86_64 efibootmgr $MICROCODE
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Define a senha do root
echo "Escolha uma senha para o usuário root"
passwd

# Termina a instalação e desliga o computador
exit
umount -R /mnt
shutdown now