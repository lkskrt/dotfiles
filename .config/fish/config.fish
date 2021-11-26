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
fish_add_path ~/.npm-global/bin/

abbr -a l ls -lah
abbr -a ll l
abbr -a d docker
abbr -a dc docker-compose
abbr -a p podman
abbr -a tf terraform
abbr -a k kubectl

if test -n "$DESKTOP_SESSION"
  set -x (gnome-keyring-daemon --start | string split "=")
end

# AWS CLI completions: https://github.com/aws/aws-cli/issues/1079#issuecomment-252947755
test -x (which aws_completer); and complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

if test "$USER" != 'root'; and test "$hostname" = 'lukas-laptop'
  set -x DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
end

