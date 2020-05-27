# .files

## Setup

```zsh
cd ~
git clone git@github.com:lkskrt/dotfiles.git
# Use zsh for this to work
mv dotfiles/*(D) .
rmdir dotfiles
```

## i3 & sway

To be able to support both i3 and sway the config is split in a common and i3/sway specific part.

Build it first by executing [`~/.config/i3/build`](.config/i3/build).

> ℹ️ Sway config has not been tested for a long time and probably does not work anymore.
