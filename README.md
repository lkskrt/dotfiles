# .files

## Setup

### Dotfiles Only

```shell
cd ~
git clone git@github.com:lkskrt/dotfiles.git
cp -r dotfiles/* dotfiles/.* .
rm -rf dotfiles
```

### Whole System

To install Arch on a new system boot into Arch ISO and first download the repo:
```shell
git clone https://github.com/lkskrt/dotfiles.git
```

Install fish:
```shell
pacman -Sy fish
```

Then execute the bootstrap script:
```shell
dotfiles/bin/setup/bootstrap_arch.fish TARGET_DEVICE EFI_SYSTEM_PARTITION_DEVICE
```

The system should now be ready to boot Arch from the target device. Reboot, login and finish setup by executing:
```shell
dotfiles/bin/setup/configure_arch.fish
```

## i3 & sway

To be able to support both i3 and sway the config is split in a common and i3/sway specific part.

Build it first by executing [`~/.config/i3/build`](.config/i3/build).

> ℹ️ Sway config has not been tested for a long time and probably does not work anymore.
