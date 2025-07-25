#!/bin/bash

mkdir -p ~/.local/bin ~/.kube
export EDITOR="/usr/bin/vim"
export PATH="$HOME/.local/bin:$HOME/bin:${PATH}"

find $HOME -mindepth 1 -maxdepth 1 -type f -name '.bash*' | while read -r BFILE; do
  F2REPLACE=$(basename "${BFILE}")
  # echo "$HOME/${F2REPLACE} will be replaced!"
  if [ -f "$HOME/${F2REPLACE}" ]; then
    echo "$HOME/${F2REPLACE} will be replaced!"
  fi
  cp "${F2REPLACE}" "$HOME/${F2REPLACE}"
done

if [ -f /etc/debian_version ]; then
  sudo apt install curl wget unzip mc tree rsync lsof git bash-completion httpie
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

cp .bash* ~/

# install kubectl
if ! command -v kubectl 1>/dev/null 2>&1; then
  echo
  echo
  echo "==================== Installing kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv ./kubectl ~/.local/bin/kubectl
fi

# install kubelogin:
if ! command -v kubelogin 1>/dev/null 2>&1; then
  echo
  echo
  echo "==================== Installing kubelogin"
  wget https://github.com/Azure/kubelogin/releases/download/v0.0.29/kubelogin-linux-amd64.zip
  unzip kubelogin-linux-amd64.zip
  find . -name kubelogin -exec mv {} ~/.local/bin/ \;
fi

# install krew plugin for kubectl
kubectl plugin list | grep krew >/dev/null 2>&1
if [ $? -eq 1 ]; then
  echo
  echo
  echo "==================== Installing krew plugin for kubectl"
  curl -fsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz
  tar zxvf krew-linux_amd64.tar.gz
  ./krew-linux_amd64 install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# install ctx and ns plugins for kubectl
kubectl plugin list 2>/dev/null >/tmp/krew_plugins
grep -w 'krew' /tmp/krew_plugins >/dev/null 2>&1
haveKrew=$?
grep -w 'ctx' /tmp/krew_plugins >/dev/null 2>&1
haveCTX=$?
grep -w 'ns' /tmp/krew_plugins >/dev/null 2>&1
haveNS=$?
echo "krew=${haveKrew}, ctx=${haveCTX}, ns=${haveNS}"
if [ $haveKrew -eq 0 ] && [ $haveCTX -eq 1 ] || [ $haveNS -eq 1 ]; then
  echo
  echo
  echo "==================== Installing ctx and ns plugins for kubectl"
  kubectl krew install ctx
  kubectl krew install ns
fi

if ! command -v helm 1>/dev/null 2>&1; then
  echo
  echo
  echo "==================== Installing helm"
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
fi

if command -v helm 1>/dev/null 2>&1; then
  helm plugin install https://github.com/databus23/helm-diff
fi

# install awscli
if ! command -v aws 1>/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# install tfenv
if ! command -v tfenv 1>/dev/null 2>&1; then
  echo
  echo
  echo "==================== Installing tfenv"
  git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
  ~/.tfenv/bin/tfenv install 1.1.4
  ~/.tfenv/bin/tfenv use 1.1.4
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

chmod go-rwx ~/.kube/config
source ~/.bashrc
