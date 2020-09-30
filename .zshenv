if [[ -n "$DESKTOP_SESSION" ]]; then
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
fi


if [[ -a ~/.zshenv_local ]]; then
  . ~/.zshenv_local
fi
