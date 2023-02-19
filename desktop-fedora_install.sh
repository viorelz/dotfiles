#!/bin/bash

cd

wget http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
wget http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
wget http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
dnf localinstall rpmfusion* adobe-release* -y

dnf install\
  hddtemp keepassxc sshfs pssh fido2-tools nmap\
  python-pip python-dns p7zip\
  podman-compose.noarch podman-docker.noarch virt-manager\
  meld mc tigervnc rdesktop transmission wireshark\
  filezilla lftp postfix zabbix-agent\
  terminus* cascadia-code-fonts terminator direnv evtest\
  mpv gnome-mpv audacious audacity flash-plugin ffmpeg\
  firefox thunderbird\
  nm-connection-editor gkrellm-sun wmctrl gnome-tweak-tool\
  gnome-shell-extension* gnome-shell-theme* gdm dconf-editor gconf-editor\
  calibre libreoffice-draw\
  dia gimp-data-extras gimp-resynthesizer ufraw-gimp gimp\
  vim-enhanced gedit

dnf install \
  synergy_*.rpm


rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
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

dnf install -y kubectl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


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
