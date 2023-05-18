#!/bin/bash

mkdir -p .local/bin .kube
export EDITOR="/usr/bin/vim"
export PATH="$HOME/.local/bin:$HOME/bin:${PATH}"

#### check internet connection
###############################

if [ -f /etc/debian_version ]; then
  sudo apt install wget curl unzip
fi

if ! command -v wget 1>/dev/null 2>&1; then
  echo "Please install wget"
  exit 1
fi

if ! command -v curl 1>/dev/null 2>&1; then
  echo "Please install curl"
  exit 1
fi

if ! command -v unzip 1>/dev/null 2>&1; then
  echo "Please install unzip"
  exit 1
fi



# install kubectl
if ! command -v kubectl 1>/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mkdir -p ~/.local/bin
  mv ./kubectl ~/.local/bin/kubectl
fi

# install kubelogin:
if ! command -v kubelogin 1>/dev/null 2>&1; then
  wget https://github.com/Azure/kubelogin/releases/download/v0.0.29/kubelogin-linux-amd64.zip
  unzip kubelogin-linux-amd64.zip
  find . -name kubelogin -exec mv {} ~/.local/bin/ \;
fi

# install krew plugin for kubectl
kubectl plugin list | grep krew > /dev/null 2>&1
if [ $? -gt 1 ]; then
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# install ctx and ns plugins for kubectl
kubectl plugin list | grep krew > /dev/null 2>&1
if [ $? -gt 0 ]; then
  kubectl krew install ctx
  kubectl krew install ns
fi

if ! command -v helm 1>/dev/null 2>&1; then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
fi

# install awscli
if ! command -v aws 1>/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi


# install tfevn
if ! command -v tfenv 1>/dev/null 2>&1; then
  git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
  tfenv install 1.1.4
  tfenv use 1.1.4
fi


if command -v direnv 1>/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

if command -v kubectl 1>/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -F __start_kubectl k
fi

if command -v helm 1>/dev/null 2>&1; then
  source <(helm completion bash)
fi

# export PATH="$HOME/.local/bin:$HOME/bin:${PATH}:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

grep kubectl ~/.bashrc > /dev/null 2>&1
if [ $? -gt 0 ]; then
  cat << EOF >> ~/.bashrc
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
EOF
fi

if [ ! -f ~/.kube/config ]; then
  cat << EOF > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: XXXXXXXXXXXXXXX
    server: https://api.backbone-stg.euc1.srcloud.io
  name: backbone-stg
contexts:
- context:
    cluster: backbone-stg
    namespace: common-iam-stg
    user: kubernetes-ad-user
  name: backbone-stg
current-context: backbone-stg
kind: Config
preferences: {}
users:
- name: kubernetes-ad-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - get-token
      - --environment
      - AzurePublicCloud
      - --server-id
      - 8cad818e-156b-4063-8996-fc603d8817b5
      - --client-id
      - 75c5d15e-382e-4307-83fe-ad38aa2a4685
      - --tenant-id
      - SportradarAG.onmicrosoft.com
      command: kubelogin
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false
EOF
fi

