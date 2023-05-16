alias ls="ls --color=auto"
#alias grep="grep --color"
#alias egrep="egrep --color"
alias cp=cp
alias sdnow="sudo /sbin/shutdown -h now"
alias vncs="vncserver -geometry 2000x1080"
alias gh='history|grep'
alias cpv='rsync -ah --info=progress2'

alias pingg="ping google.com"
alias ippub="dig +short myip.opendns.com @resolver1.opendns.com"
alias iplocal="ip ad l dev eno1 | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

alias dea='direnv allow .'

if [ -f /etc/redhat-release ]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"


# ----------------------
# Git Aliases
# ----------------------
alias ga='git add'
alias gaa='git add .'
alias gaaa='git add --all'
alias gau='git add --update'
alias gb='git branch'
alias gbd='git branch --delete '
alias gc='git commit'
alias gcm='git commit --message'
alias gcf='git commit --fixup'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout master'
alias gcos='git checkout staging'
alias gcod='git checkout develop'
alias gd='git diff'
alias gda='git diff HEAD'
alias gi='git init'
alias glg='git log --graph --oneline --decorate --all'
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
alias gm='git merge --no-ff'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gp='git pull'
alias gpr='git pull --rebase'
alias gpu='git push'
alias gr='git rebase'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash save'
alias gsw='git switch'

# ----------------------
# Git Functions
# ----------------------
# Git log find by commit message
function glf() { git log --all --grep="$1"; }



## terraform "shortcuts"
alias tf='terraform'
alias tfa='terraform apply'
alias tfay='terraform apply -auto-approve'
alias tfc='terraform console'
alias tfd='terraform destroy'
alias tfdy='terraform destroy -auto-approve'
alias tff='terraform fmt'
alias tffr='terraform fmt -recursive'
alias tffu='terraform force-unlock'
alias tfg='terraform graph'
alias tfim='terraform import'
alias tfin='terraform init'
alias tfinu='terraform init -upgrade'
alias tfo='terraform output'
alias tfp='terraform plan'
alias tfpr='terraform providers'
alias tfr='terraform refresh'
alias tfs='terraform state'
alias tfsh='terraform show'
alias tfsls='terraform state list'
alias tfsmv='terraform state mv'
alias tfsph='terraform state push'
alias tfspl='terraform state pull'
alias tfsrm='terraform state rm'
alias tfssw='terraform state show'
alias tft='terraform taint'
alias tfut='terraform untaint'
alias tfv='terraform validate'
alias tfw='terraform workspace'
alias tfwde='terraform workspace delete'
alias tfwls='terraform workspace list'
alias tfwnw='terraform workspace new'
alias tfwst='terraform workspace select'
alias tfwsw='terraform workspace show'


# MULTITAIL
alias m_qmail="multitail -s 2 -cv qmailtimestr /var/log/qmail/current -cv qmailtimestr /var/log/qmail/smtpd/current"
alias m_mail="multitail -s 2 /var/log/maillog /var/spool/qscan/qmail-queue.log"
alias m_httpd="multitail -s 2 -cS apache /var/log/httpd/access_log -cS apache_error /var/log/httpd/error_log"


### KUBERNETES
alias k='kubectl'
alias kd='kubectl describe'
alias kdd='kubectl describe deployment'
alias kddn='kubectl describe deployment --namespace'
alias kdp='kubectl describe pod'
alias kdpn='kubectl describe pod --namespace'
alias kds='kubectl describe secret'
alias kdsn='kubectl describe secret --namespace'
alias kdsv='kubectl describe service'
alias kdsva='kubectl describe service --all-namespaces'
alias kdsvn='kubectl describe service --namespace'
alias ke='kubectl edit'
alias kg='kubectl get'
alias kga='kubectl get --all-namespaces'
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdn='kubectl get deployment --namespace'
alias kge='kubectl get events --sort-by=.metadata.creationTimestamp'
alias kgen='kubectl get events --sort-by=.metadata.creationTimestamp --namespace'
alias kgn='kubectl get nodes'
alias kgp='kubectl get pod'
alias kgpa='kubectl get pod --all-namespaces'
alias kgpaw='kubectl get pod --all-namespaces -w'
alias kgpn='kubectl get pod --namespace'
alias kgs='kubectl get secret'
alias kgsa='kubectl get secret --all-namespaces'
alias kgsn='kubectl get secret --namespace'
alias kgsv='kubectl get service'
alias kgsva='kubectl get service --all-namespaces'
alias kgsvn='kubectl get service --namespace'
alias kl='kubectl logs'
alias kln='kubectl logs --namespace'
alias kp='kubectl proxy'
alias krrd='kubectl rollout restart deployment'
for i in {0..99}; do
  eval "alias ksdr${i}='kubectl scale deployment --replicas=$i'"
  eval "alias ksdr${i}n='kubectl scale deployment --replicas=$i --namespace'"
done
