#!/bin/sh

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

# Sai do chroot
exit