#!/bin/bash
###############################################################################
# File: desktop-fedora_install.sh
# Purpose: Provision a Fedora workstation with common productivity, development
#          and DevOps tooling (repos, packages, desktop apps, VSCode, k8s tools,
#          virtualization, media, fonts, etc.).
# Usage:   sudo ./desktop-fedora_install.sh
# Notes:
#   - Requires root (or sudo) for package installation & system config changes.
#   - Environment variables HOMEBAK, MYHOME, SYSBAK optionally point to backup
#     sources for user and system configuration artifacts.
#   - Creates .orig backups for critical config files before replacement.
# Safety Improvements (added):
#   - Root execution check
#   - Backups before mv/cp on /etc configs
#   - Quoting and -y flags on dnf
#   - Logging helpers with color
# TODO:
#   - Parameterize large package groups
#   - Add flags to enable/disable groups
###############################################################################
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "This script must be run as root (sudo)." >&2
  exit 1
fi

color() { local c="$1"; shift || true; printf "\033[%sm%s\033[0m\n" "$c" "$*"; }
info() { color '1;34' "[INFO] $*"; }
warn() { color '1;33' "[WARN] $*"; }
err()  { color '1;31' "[ERR ] $*" >&2; }

info "Starting Fedora workstation provisioning"

cd "$HOME" || true

FEDVER=$(rpm -E %fedora)
info "Detected Fedora version ${FEDVER}"

info "Fetching RPM Fusion & Adobe repo rpms"
wget -q "http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDVER}.noarch.rpm"
wget -q "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDVER}.noarch.rpm"
wget -q http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
dnf -y localinstall rpmfusion* adobe-release* || true

info "Installing base tooling packages"
dnf -y install dnf-plugins-core tree bind-utils lynx dstat iotop tcpdump iptraf telnet nc lftp man rsync net-tools mdadm openssh-clients mc strace lsof wget git lshw hdparm parted bash-completion zip unzip hstr pciutils smartmontools hddtemp jwhois pv pwgen smem htop util-linux || true

info "Installing desktop & productivity packages"
dnf -y install keepassxc sshfs pssh fido2-tools nmap python-pip python-dns p7zip gparted podman-compose.noarch podman-docker.noarch virt-manager meld tigervnc rdesktop transmission wireshark filezilla postfix zabbix-agent terminus* cascadia-code-fonts terminator direnv evtest mpv gnome-mpv audacious audacity flash-plugin ffmpeg firefox thunderbird nm-connection-editor gkrellm-sun wmctrl gnome-tweak-tool gnome-shell-extension* gnome-shell-theme* gdm dconf-editor gconf-editor calibre libreoffice-draw dia gimp-data-extras gimp-resynthesizer ufraw-gimp gimp vim-enhanced gedit xclip || true

if ls synergy_*.rpm >/dev/null 2>&1; then
  info "Installing local synergy RPM(s)"
  dnf -y install synergy_*.rpm || warn "Synergy install failed"
fi

info "Adding Brave browser repository"
dnf -y install dnf-plugins-core >/dev/null 2>&1 || true
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || true
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || true
dnf -y install brave-browser || warn "Brave browser install failed"

info "Configuring VS Code repository"
rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
cat > /etc/yum.repos.d/vscode.repo <<'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
dnf -y check-update || true
dnf -y install code || warn "VS Code install failed"

info "(Optional) Kubernetes repo setup"
cat > /etc/yum.repos.d/kubernetes.repo <<'K8S'
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
K8S

info "Disabling cups service"
systemctl disable --now cups 2>/dev/null || true

# --- User config rsync (guard env vars) ---
if [ -n "${HOMEBAK:-}" ] && [ -n "${MYHOME:-}" ]; then
  if [ -d "${HOMEBAK}/.config/autostart" ]; then
    info "Syncing autostart entries"
    rsync -a "${HOMEBAK}/.config/autostart/" "${MYHOME}/.config/autostart/" || warn "Autostart rsync failed"
  else
    warn "${HOMEBAK}/.config/autostart missing; skipping autostart rsync"
  fi
else
  warn "HOMEBAK or MYHOME not set; skipping autostart rsync"
fi

# --- Zabbix agent config replacement ---
if [ -n "${SYSBAK:-}" ] && [ -f "${SYSBAK}/etc/zabbix_agentd.conf" ]; then
  if [ -f /etc/zabbix_agentd.conf ] && [ ! -f /etc/zabbix_agentd.conf.orig ]; then
    cp /etc/zabbix_agentd.conf /etc/zabbix_agentd.conf.orig
  fi
  cp "${SYSBAK}/etc/zabbix_agentd.conf" /etc/ || warn "Failed to copy zabbix_agentd.conf"
  systemctl enable --now zabbix-agent.service 2>/dev/null || warn "Failed enabling zabbix-agent"
else
  warn "SYSBAK/etc/zabbix_agentd.conf not available; skipping zabbix config"
fi

# --- libvirt config replacement ---
if [ -n "${SYSBAK:-}" ] && [ -d "${SYSBAK}/etc/libvirt" ]; then
  if [ -d /etc/libvirt ] && [ ! -d /etc/libvirt.orig ]; then
    cp -a /etc/libvirt /etc/libvirt.orig
  fi
  cp -a "${SYSBAK}/etc/libvirt" /etc/ || warn "Failed to copy libvirt directory"
  systemctl enable --now libvirtd.service 2>/dev/null || warn "Failed enabling libvirtd"
else
  warn "SYSBAK/etc/libvirt not available; skipping libvirt config"
fi

# --- Minikube ---
if ! command -v minikube >/dev/null 2>&1; then
  info "Installing minikube"
  curl -fsSLo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x /usr/local/bin/minikube || true
else
  info "minikube already installed"
fi

# --- kubelogin (download only reminder) ---
if ! command -v kubelogin >/dev/null 2>&1; then
  info "Fetching kubelogin (manual placement reminder)"
  tmpd=$(mktemp -d)
  ( cd "$tmpd" && wget -q https://github.com/Azure/kubelogin/releases/download/v0.0.28/kubelogin-linux-amd64.zip && unzip -q kubelogin-linux-amd64.zip ) || warn "kubelogin fetch failed"
  find "$tmpd" -type f -name kubelogin || true
  warn "Move the kubelogin binary above into your PATH manually"
else
  info "kubelogin already installed"
fi

# --- VS Code extensions ---
if command -v code >/dev/null 2>&1; then
  info "Installing VS Code extensions"
  extensions=(
    4ops.terraform
    eamodio.gitlens
    fudd.toggle-zen-mode
    lunuan.kubernetes-templates
    mhutchie.git-graph
    moshfeu.compare-folders
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python
    ms-python.vscode-pylance
    redhat.vscode-yaml
    VisualStudioExptTeam.intellicode-api-usage-examples
    VisualStudioExptTeam.vscodeintellicode
    yzhang.markdown-all-in-one
    ZainChen.json
  )
  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" >/dev/null 2>&1 || warn "Failed installing VS Code extension $ext"
  done
else
  warn "code command not found; skipping VS Code extensions"
fi

info "Fedora workstation provisioning complete"
