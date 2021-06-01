fish_vi_key_bindings
function fish_user_key_bindings
  for mode in insert default visual
    bind -M $mode -k nul forward-char
  end
end

starship init fish | source

set -x AWS_SDK_LOAD_CONFIG 1
set -x EDITOR vim
set -x VISUAL vim
set -U fish_greeting

alias ll='ls -lah'
alias l='ll'

alias d='docker'
alias dc='docker-compose'

alias tf='terraform'

alias k='kubectl'

if test -n "$DESKTOP_SESSION"
  set -x (gnome-keyring-daemon --start | string split "=")
end
