fish_vi_key_bindings
function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode ctrl-space accept-autosuggestion
    end
end

if type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init fish | source
end

set -x AWS_SDK_LOAD_CONFIG 1
set -x EDITOR vim
set -x VISUAL vim
set -x FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/*"'
set -U fish_greeting
fish_add_path ~/.npm-global/bin/

abbr -a l ls -lah
abbr -a ll l
abbr -a d docker
abbr -a --position anywhere dc docker compose
abbr -a p podman
abbr -a tf terraform
abbr -a k kubectl

abbr -a g git
abbr -a ga git add
abbr -a gau git add -u
abbr -a gaa git add -A
abbr -a gc git commit
abbr -a gd git diff
abbr -a gdc git diff --cached
abbr -a gl git log
abbr -a gm git merge
abbr -a gp git pull
abbr -a gpu git push
abbr -a gr git restore
abbr -a gs git status
abbr -a gst git stash
abbr -a gsw git switch

# AWS CLI completions: https://github.com/aws/aws-cli/issues/1079#issuecomment-252947755
type -q aws_completer; and complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

if test "$USER" != root; and test "$hostname" = lukas-t14s
    set -x DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    # https://github.com/containers/podman/issues/13889#issuecomment-1112454604
    set -x DOCKER_BUILDKIT 0
    alias docker podman
end


# pnpm
set -gx PNPM_HOME "/home/lukas/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
