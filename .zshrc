setopt autocd
# setopt complete_aliases

export KEYTIMEOUT=1
bindkey -v

autoload -Uz compinit promptinit
compinit
promptinit

zstyle :compinstall filename '/home/lukas/.zshrc'
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh

#antigen theme agnoster
#antigen theme sorin
export SPACESHIP_BATTERY_SHOW=false
export SPACESHIP_PHP_SHOW=false
export SPACESHIP_KUBECTL_SHOW=true
export SPACESHIP_KUBECTL_VERSION_SHOW=false
export SPACESHIP_EXIT_CODE_SHOW=true
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

antigen bundle docker
antigen bundle command-not-found
# antigen bundle vi-mode
antigen bundle softmoth/zsh-vim-mode

antigen bundle zsh-users/zsh-autosuggestions
bindkey '^ ' autosuggest-accept

#antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

export AWS_SDK_LOAD_CONFIG=1
export EDITOR="vim"
export TERM=xterm-256color
export VISUAL="vim"

if [[ -a /bin/aws_zsh_completer.sh ]]; then
  . /bin/aws_zsh_completer.sh
fi

alias ll='ls -lah'
alias l='ll'

alias d='docker'
alias dc='docker-compose'

alias tf='terraform'
alias tfg='terraform graph | dot -Tsvg > graph.svg'
alias tfp='terraform plan'
alias tfa='terraform apply'

alias k='kubectl'
alias kdcm='kubectl describe configmap'
alias kdcj='kubectl describe cronjob'
alias kdd='kubectl describe deploy'
alias kdj='kubectl describe job'
alias kdn='kubectl describe node'
alias kgns='kubectl describe ns'
alias kdp='kubectl describe pod'
alias kgrs='kubectl describe rs'
alias kds='kubectl describe secret'
alias kdsvc='kubectl describe service'

alias ke='kubectl exec -it'

alias krmp='kubectl delete pod'

alias kgcm='kubectl get configmap'
alias kgcj='kubectl get cronjob'
alias kgd='kubectl get deploy'
alias kgj='kubectl get job'
alias kgn='kubectl get node'
alias kgns='kubectl get ns'
alias kgp='kubectl get pod'
alias kgrs='kubectl get rs'
alias kgs='kubectl get secret'
alias kgsvc='kubectl get service'

alias kl='kubectl logs'
alias kgr='kubectl describe nodes | grep -A 9 -e "^Allocated resources"'
alias kgnp='kubectl describe nodes | grep -e "^Non-terminated Pods"'
