#!/bin/bash

cd

wget http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
wget http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
wget http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
dnf localinstall rpmfusion* adobe-release* -y

dnf install dnf-plugins-core tree bind-utils lynx dstat iotop tcpdump iptraf telnet nc lftp man rsync net-tools mdadm openssh-clients mc strace lsof wget git lshw hdparm parted bash-completion zip unzip hstr pciutils smartmontools hddtemp jwhois pv pwgen smem htop util-linux

dnf install keepassxc sshfs pssh fido2-tools nmap python-pip python-dns p7zip gparted podman-compose.noarch podman-docker.noarch virt-manager meld tigervnc rdesktop transmission wireshark filezilla postfix zabbix-agent terminus* cascadia-code-fonts terminator direnv evtest mpv gnome-mpv audacious audacity flash-plugin ffmpeg firefox thunderbird nm-connection-editor gkrellm-sun wmctrl gnome-tweak-tool gnome-shell-extension* gnome-shell-theme* gdm dconf-editor gconf-editor calibre libreoffice-draw dia gimp-data-extras gimp-resynthesizer ufraw-gimp gimp vim-enhanced gedit xclip

dnf install \
  synergy_*.rpm

dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install brave-browser

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" >/etc/yum.repos.d/vscode.repo
dnf check-update
dnf install code -y

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak install flathub org.telegram.desktop

systemctl disable --now cups

rsync -a "${HOMEBAK}/.config/autostart/" "${MYHOME}/.config/autostart/"

mv /etc/zabbix_agentd.conf /etc/zabbix_agentd.conf.orig
cp "${SYSBAK}/etc/zabbix_agentd.conf" /etc
systemctl enable --now zabbix-agent.service

mv /etc/libvirt /etc/libvirt.orig
cp "${SYSBAK}/etc/libvirt" /etc
systemctl enable --now libvirtd.service

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

wget https://github.com/Azure/kubelogin/releases/download/v0.0.28/kubelogin-linux-amd64.zip
unzip kubelogin-linux-amd64.zip
echo "Remember to move the kubelogin binary to your favorite bin location:"
find ./bin -type f

# ## install kubectl krew plugin
# (
#   set -x; cd "$(mktemp -d)" &&
#   OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
#   ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
#   KREW="krew-${OS}_${ARCH}" &&
#   curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
#   tar zxvf "${KREW}.tar.gz" &&
#   ./"${KREW}" install krew
# )
# export PATH="$HOME/.krew/bin:$PATH"

# kubectl krew install ctx
# kubectl krew install ns

rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf install code

# install vscode extentions
# code --list-extensions | xargs -L 1 echo code --install-extension
code --install-extension 4ops.terraform
code --install-extension eamodio.gitlens
code --install-extension fudd.toggle-zen-mode
code --install-extension lunuan.kubernetes-templates
code --install-extension mhutchie.git-graph
code --install-extension moshfeu.compare-folders
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension redhat.vscode-yaml
code --install-extension VisualStudioExptTeam.intellicode-api-usage-examples
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension yzhang.markdown-all-in-one
code --install-extension ZainChen.json
