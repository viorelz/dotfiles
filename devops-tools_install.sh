#!/bin/bash
###############################################################################
# File: devops-tools_install.sh
# Purpose: Bootstrap a Linux environment with common DevOps tooling
#          (kubectl, kubelogin, krew+plugins, helm+plugins, awscli, tfenv).
# Usage:   ./devops-tools_install.sh
# Features:
#   - Safe, idempotent installs (skips tools already present)
#   - Optional installs controlled by env flags (set to 0 to skip):
#       INSTALL_KUBECTL=1 INSTALL_KUBELOGIN=1 INSTALL_KREW=1 \
#       INSTALL_HELM=1 INSTALL_AWSCLI=1 INSTALL_TFENV=1
#   - Parameterized Terraform version via TF_VERSION (default 1.1.4)
#   - Copies repository .bash* files into $HOME (overwrites, no backup here)
#   - Adds shell completions for kubectl & helm when available
#   - Minimal logging with color (silently continues on non-critical steps)
# Requirements:
#   - bash, curl, wget, unzip present (apt install if Debian-based)
#   - Network access; sudo for some global installs (awscli)
# Exit Codes:
#   0 success; non-zero on missing critical prerequisite or failing command
###############################################################################
set -euo pipefail

# ------------------------------- Configuration ------------------------------
INSTALL_KUBECTL=${INSTALL_KUBECTL:-1}
INSTALL_KUBELOGIN=${INSTALL_KUBELOGIN:-1}
INSTALL_KREW=${INSTALL_KREW:-1}
INSTALL_HELM=${INSTALL_HELM:-1}
INSTALL_AWSCLI=${INSTALL_AWSCLI:-1}
INSTALL_TFENV=${INSTALL_TFENV:-1}
TF_VERSION=${TF_VERSION:-1.1.4}

export EDITOR="/usr/bin/vim"
export PATH="$HOME/.local/bin:$HOME/bin:${PATH}"
mkdir -p "$HOME/.local/bin" "$HOME/.kube"

# ------------------------------- Logging helpers ----------------------------
color() { local c="$1"; shift || true; printf "\033[%sm%s\033[0m\n" "$c" "$*"; }
info() { color '1;34' "[INFO] $*"; }
warn() { color '1;33' "[WARN] $*"; }
err()  { color '1;31' "[ERR ] $*" >&2; }

# ------------------------------- Prerequisites ------------------------------
if [ -f /etc/debian_version ]; then
  info "Debian-based system detected; ensuring base packages via apt"
  sudo apt update -y >/dev/null 2>&1 || true
  sudo apt install -y curl wget unzip git bash-completion jq >/dev/null 2>&1 || true
fi

for bin in wget curl unzip; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    err "Required command '$bin' not found. Install it and re-run."; exit 1
  fi
done

# ------------------------------- Dotfiles copy ------------------------------
info "Copying repository .bash* files into HOME (overwrites)"
shopt -s nullglob
for f in .bash*; do
  [ -f "$f" ] || continue
  if [ -f "$HOME/$f" ]; then
    warn "$HOME/$f will be replaced"
  fi
  cp "$f" "$HOME/$f"
done
shopt -u nullglob

# ------------------------------- kubectl ------------------------------------
if [ "$INSTALL_KUBECTL" = "1" ]; then
  if command -v kubectl >/dev/null 2>&1; then
    info "kubectl already installed ($(kubectl version --client --short 2>/dev/null || echo present))"
  else
    info "Installing kubectl"
    curl -fsSL -o kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl "$HOME/.local/bin/kubectl"
  fi
else
  info "Skipping kubectl (INSTALL_KUBECTL=0)"
fi

# ------------------------------- kubelogin ----------------------------------
if [ "$INSTALL_KUBELOGIN" = "1" ]; then
  if command -v kubelogin >/dev/null 2>&1; then
    info "kubelogin already installed"
  else
    info "Installing kubelogin"
    tmpdir=$(mktemp -d)
    ( cd "$tmpdir" && \
      wget -q https://github.com/Azure/kubelogin/releases/download/v0.0.29/kubelogin-linux-amd64.zip && \
      unzip -q kubelogin-linux-amd64.zip && \
      find . -name kubelogin -exec mv {} "$HOME/.local/bin/" \; )
    rm -rf "$tmpdir"
  fi
else
  info "Skipping kubelogin (INSTALL_KUBELOGIN=0)"
fi

# ------------------------------- krew + plugins -----------------------------
if [ "$INSTALL_KREW" = "1" ]; then
  have_kubectl=0; command -v kubectl >/dev/null 2>&1 || have_kubectl=1
  if [ $have_kubectl -ne 0 ]; then
    warn "kubectl not present; skipping krew installation"
  else
    if kubectl plugin list 2>/dev/null | grep -q '\bkrew\b'; then
      info "krew already installed"
    else
      info "Installing krew"
      tmpdir=$(mktemp -d)
      ( cd "$tmpdir" && \
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" && \
        tar zxf krew-linux_amd64.tar.gz && \
        ./krew-linux_amd64 install krew )
      rm -rf "$tmpdir"
      export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    fi
    # ctx & ns
    if kubectl plugin list 2>/dev/null | grep -qw ctx && kubectl plugin list 2>/dev/null | grep -qw ns; then
      info "ctx and ns plugins already installed"
    else
      info "Installing ctx and ns plugins"
      kubectl krew install ctx ns || warn "Failed installing ctx/ns"
    fi
  fi
else
  info "Skipping krew (INSTALL_KREW=0)"
fi

# ------------------------------- helm + plugin ------------------------------
if [ "$INSTALL_HELM" = "1" ]; then
  if command -v helm >/dev/null 2>&1; then
    info "helm already installed"
  else
    info "Installing helm"
    tmpfile=$(mktemp)
    curl -fsSL -o "$tmpfile" https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 "$tmpfile" && "$tmpfile" >/dev/null 2>&1 || "$tmpfile"
    rm -f "$tmpfile"
  fi
  if command -v helm >/dev/null 2>&1; then
    if helm plugin list 2>/dev/null | grep -q 'diff'; then
      info "helm-diff plugin already installed"
    else
      info "Installing helm-diff plugin"
      helm plugin install https://github.com/databus23/helm-diff || warn "helm-diff install failed"
    fi
  fi
else
  info "Skipping helm (INSTALL_HELM=0)"
fi

# ------------------------------- awscli v2 ----------------------------------
if [ "$INSTALL_AWSCLI" = "1" ]; then
  if command -v aws >/dev/null 2>&1; then
    info "awscli already installed"
  else
    info "Installing awscli v2"
    tmpdir=$(mktemp -d)
    ( cd "$tmpdir" && curl -fsSL -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && unzip -q awscliv2.zip && sudo ./aws/install ) || err "awscli install failed"
    rm -rf "$tmpdir"
  fi
else
  info "Skipping awscli (INSTALL_AWSCLI=0)"
fi

# ------------------------------- tfenv + terraform --------------------------
if [ "$INSTALL_TFENV" = "1" ]; then
  if command -v tfenv >/dev/null 2>&1; then
    info "tfenv already installed"
  else
    info "Installing tfenv"
    git clone --depth=1 https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
  fi
  if command -v tfenv >/dev/null 2>&1; then
    if tfenv list | grep -q "${TF_VERSION}"; then
      info "Terraform ${TF_VERSION} already installed"
    else
      info "Installing Terraform ${TF_VERSION} via tfenv"
      "$HOME/.tfenv/bin/tfenv" install "${TF_VERSION}" || warn "Failed terraform install"
    fi
    "$HOME/.tfenv/bin/tfenv" use "${TF_VERSION}" || true
  fi
else
  info "Skipping tfenv/Terraform (INSTALL_TFENV=0)"
fi

# ------------------------------- Completions --------------------------------
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash) 2>/dev/null || true
  complete -F __start_kubectl k 2>/dev/null || true
fi

if command -v helm >/dev/null 2>&1; then
  source <(helm completion bash) 2>/dev/null || true
fi

chmod go-rwx "$HOME/.kube/config" 2>/dev/null || true
info "Sourcing ~/.bashrc to load new environment (non-fatal if fails)"
source "$HOME/.bashrc" 2>/dev/null || true

info "DevOps tool bootstrap complete."
