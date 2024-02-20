#!/usr/bin/env fish

set device $argv[1]
if test -z "$device"
    echo "Specify target device" >&2
    exit 1
end

if not test -b "$device"
    echo "$device is not a block device" >&2
    exit 1
end

set esp $argv[2]
if test -z "$esp"
    echo "Specify ESP" >&2
    exit 1
end

if not test -b "$esp"
    echo "$esp is not a block device" >&2
    exit 1
end

set step $argv[3]
if test -z "$step"
    set step 0
end

# Disable annoying beeps
rmmod pcspkr &>/dev/null

set keymapBasePath /usr/share/kbd/keymaps
# Includes do not work without being in the same directory: https://unix.stackexchange.com/a/630050
zcat $keymapBasePath/i386/qwertz/de-latin1-nodeadkeys.map.gz >$keymapBasePath/de-latin1-nodeadkeys.map
zcat $keymapBasePath/i386/qwertz/de-latin1.map.gz >$keymapBasePath/de-latin1.map
set keymapCustomPath $keymapBasePath/de-custom.map
echo -n 'include "de-latin1-nodeadkeys.map"
keycode 58 = Escape
' >$keymapCustomPath
loadkeys $keymapCustomPath

set mapperName root
set mapperDevice /dev/mapper/$mapperName
set mountPath /mnt

if test $step -le 0
    echo "Encrypting $device"
    cryptsetup luksFormat $device

    echo "Decrypting $device"
    cryptsetup open $device $mapperName

    echo "Formatting $mapperDevice"
    mkfs.btrfs $mapperDevice

    echo "Mounting $mapperDevice to $mountPath"
    mount $mapperDevice $mountPath

    echo "Creating subvolumes"
    # https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Btrfs_subvolumes_with_swap
    # https://wiki.archlinux.org/title/Snapper#Suggested_filesystem_layout
    btrfs subvolume create $mountPath/@
    btrfs subvolume create $mountPath/@home
    btrfs subvolume create $mountPath/@snapshots
    btrfs subvolume create $mountPath/@logs
    btrfs subvolume create $mountPath/@swap

    echo Unmounting
    umount -R $mountPath
end

if not test -e $mapperDevice
    echo "Decrypting $device"
    cryptsetup open $device $mapperName
end

echo "Mounting @ subvolume to $mountPath"
mount $mapperDevice -o subvol=@ $mountPath

if not test -e $mountPath/boot
    echo "Creating mount points in $mountPath"
    mkdir -p $mountPath/boot
    mkdir -p $mountPath/home
    mkdir -p $mountPath/.snapshots
    mkdir -p $mountPath/var/log
    mkdir -p $mountPath/swap
end

echo "Mounting other subvolumes"
mount $esp $mountPath/boot
mount $mapperDevice -o subvol=@home $mountPath/home
mount $mapperDevice -o subvol=@snapshots $mountPath/.snapshots
mount $mapperDevice -o subvol=@logs $mountPath/var/log
mount $mapperDevice -o subvol=@swap $mountPath/swap

set swapFile $mountPath/swap/file
if not test -e $swapFile
    echo "Setting up swap file"
    # https://wiki.archlinux.org/title/Btrfs#Swap_file
    btrfs filesystem mkswapfile --size 16g --uuid clear $mountPath/swap/file
end
swapon $swapFile

if not test -e $mountPath/var/cache/pacman/pkg
    echo "Creating subvolumes of @"
    # Excluded from @ snapshots
    mkdir -p $mountPath/var/cache/pacman
    btrfs subvolume create $mountPath/var/cache/pacman/pkg
    btrfs subvolume create $mountPath/var/tmp
end

if test $step -le 1
    echo "Starting pacstrap"
    pacstrap $mountPath \
        base \
        base-devel \
        linux \
        linux-firmware \
        bluez \
        bluez-utils \
        btrfs-progs \
        fish \
        git \
        htop \
        iputils \
        networkmanager \
        ufw \
        gvim
end

if not grep -q btrfs $mountPath/etc/fstab
    echo "Generating fstab"
    genfstab -U $mountPath >>$mountPath/etc/fstab
end

if not test -e $mountPath/etc/localtime
    echo "Setting clock"
    arch-chroot $mountPath ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
    arch-chroot $mountPath hwclock --systohc
    arch-chroot $mountPath timedatectl set-ntp true
end

if not test -e $mountPath/etc/locale.conf
    echo "Generating locale"
    sed -i 's/#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' $mountPath/etc/locale.gen
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' $mountPath/etc/locale.gen
    arch-chroot $mountPath locale-gen

    echo -n "LANG=en_US.UTF-8
LC_NUMERIC=de_DE.UTF-8
LC_TIME=de_DE.UTF-8
LC_MONETARY=de_DE.UTF-8
LC_PAPER=de_DE.UTF-8
LC_MEASUREMENT=de_DE.UTF-8
" >$mountPath/etc/locale.conf
end

if not test -e $mountPath$keymapCustomPath
    echo "Configuring keymap"
    cp $keymapBasePath/de-*.map $mountPath$keymapBasePath
    echo "KEYMAP=de-custom" >$mountPath/etc/vconsole.conf
    arch-chroot $mountPath mkinitcpio -P
end

if not test -e $mountPath/etc/hostname
    read -l -P 'Enter hostname:' name
    echo $name >$mountPath/etc/hostname
end

if not test -e $mountPath/boot/loader/entries/arch.conf
    bootctl install
    mkdir $mountPath/boot/loader/entries
    set cryptdeviceUuid (blkid -s UUID -o value $device)

    set cpuVendor amd
    if grep -q Intel /proc/cpuinfo
        set cpuVendor intel
    end

    arch-chroot $mountPath pacman -S $cpuVendor-ucode

    echo -n "title   Arch Linux
linux   /vmlinuz-linux
initrd  /$cpuVendor-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=$cryptdeviceUuid:$mapperName root=$mapperDevice rootfstype=btrfs rootflags=subvol=@ add_efi_memmap
" >$mountPath/boot/loader/entries/arch.conf
end

if not test -e $mountPath/etc/mkinitcpio.conf.bak
    cp $mountPath/etc/mkinitcpio.conf $mountPath/etc/mkinitcpio.conf.bak
    sed -i 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)/' $mountPath/etc/mkinitcpio.conf
    arch-chroot $mountPath mkinitcpio -P
end

arch-chroot $mountPath systemctl enable NetworkManager

read -l -P 'Enter username:' username
if not test -e $mountPath/home/$username
    arch-chroot $mountPath useradd -m -G wheel,video -s /usr/bin/fish $username
    arch-chroot $mountPath passwd $username
    echo "Set root passwd:"
    arch-chroot $mountPath passwd root
end

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' $mountPath/etc/sudoers

if not test -e $mountPath/usr/bin/yay
    echo "Installing yay"
    arch-chroot $mountPath sudo -u $username sh -c 'git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si'
    rm -rf $mountPath/tmp/yay
end
