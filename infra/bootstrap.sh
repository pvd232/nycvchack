#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
state_dir=/var/lib/shared-dev
install -d -m 0755 "$state_dir"
if [ -f "$state_dir/setup-complete" ]; then exit 0; fi
trap 'touch "$state_dir/setup-failed"' ERR

apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Retries=3 update
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Retries=3 install -y --no-install-recommends \
  ca-certificates curl gnupg git gh jq build-essential pkg-config unzip zip xz-utils \
  python3 python3-venv python3-pip openssl \
  xfce4 xfce4-terminal dbus-x11 tigervnc-standalone-server tigervnc-tools \
  novnc websockify fonts-liberation fonts-noto-color-emoji

install -d -m 0755 /etc/apt/keyrings
curl -fsSL --retry 3 https://dl.google.com/linux/linux_signing_key.pub \
  | gpg --dearmor --yes -o /etc/apt/keyrings/google-linux.gpg
printf '%s\n' 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux.gpg] https://dl.google.com/linux/chrome/deb/ stable main' \
  > /etc/apt/sources.list.d/google-chrome.list
curl -fsSL --retry 3 https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | gpg --dearmor --yes -o /etc/apt/keyrings/google-cloud.gpg
printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main' \
  > /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Retries=3 update
apt-get -o DPkg::Lock::Timeout=600 -o Acquire::Retries=3 install -y --no-install-recommends google-chrome-stable google-cloud-cli

node_archive=node-v24.22.1-linux-x64.tar.xz
node_sha=6c172a9ab6718f7b801fb5a7bd486af2ee5e32758086a04b84fcce2aa77095e6
curl -fsSL --retry 3 "https://nodejs.org/dist/v24.22.1/$node_archive" -o "/tmp/$node_archive"
printf '%s  %s\n' "$node_sha" "/tmp/$node_archive" | sha256sum --check -
tar -xJf "/tmp/$node_archive" -C /opt
for executable in node npm npx; do
  ln -sfn "/opt/node-v24.22.1-linux-x64/bin/$executable" "/usr/local/bin/$executable"
done

if ! id dev >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash dev
fi
install -d -m 0755 -o dev -g dev /home/dev/.config /home/dev/.local /home/dev/.local/share
install -d -m 0700 -o dev -g dev /home/dev/.vnc /home/dev/.config/shared-dev
install -d -m 0755 -o dev -g dev /home/dev/.config/autostart /home/dev/.local/bin
install -d -m 0700 -o dev -g dev /home/dev/browser-profile
install -d -m 0770 -o dev -g dev /srv/projects
if [ ! -f /home/dev/.vnc/passwd ]; then
  umask 077
  openssl rand -hex 4 > /home/dev/.config/shared-dev/vnc-password
  tigervncpasswd -f < /home/dev/.config/shared-dev/vnc-password > /home/dev/.vnc/passwd
  chown dev:dev /home/dev/.config/shared-dev/vnc-password /home/dev/.vnc/passwd
  chmod 0600 /home/dev/.config/shared-dev/vnc-password /home/dev/.vnc/passwd
fi

cat > /home/dev/.vnc/xstartup <<'XSTARTUP'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-run-session -- startxfce4
XSTARTUP
chmod 0700 /home/dev/.vnc/xstartup
chown dev:dev /home/dev/.vnc/xstartup

cat > /home/dev/.config/autostart/chrome.desktop <<'CHROME'
[Desktop Entry]
Type=Application
Name=Google Chrome
Exec=/usr/bin/google-chrome-stable --no-first-run --no-default-browser-check --disable-dev-shm-usage --user-data-dir=/home/dev/browser-profile about:blank
Terminal=false
X-GNOME-Autostart-enabled=true
CHROME
chown dev:dev /home/dev/.config/autostart/chrome.desktop

cat > /etc/systemd/system/shared-dev-desktop.service <<'DESKTOP'
[Unit]
Description=Shared development desktop
After=network.target

[Service]
Type=simple
User=dev
Group=dev
WorkingDirectory=/home/dev
RuntimeDirectory=shared-dev
RuntimeDirectoryMode=0700
Environment=HOME=/home/dev USER=dev LOGNAME=dev XDG_RUNTIME_DIR=/run/shared-dev
ExecStart=/usr/bin/tigervncserver -fg :1 -localhost yes -geometry 1600x1000 -depth 24 -SecurityTypes VncAuth -rfbauth /home/dev/.vnc/passwd -xstartup /home/dev/.vnc/xstartup
ExecStop=-/usr/bin/tigervncserver -kill :1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
DESKTOP

cat > /etc/systemd/system/shared-dev-web.service <<'WEB'
[Unit]
Description=Shared development desktop browser access
After=shared-dev-desktop.service
Requires=shared-dev-desktop.service

[Service]
Type=simple
User=dev
Group=dev
ExecStart=/usr/bin/websockify --web=/usr/share/novnc 127.0.0.1:6080 127.0.0.1:5901
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
WEB

if [ ! -d /srv/projects/nycvchack/.git ]; then
  runuser -u dev -- git clone https://github.com/pvd232/nycvchack.git /srv/projects/nycvchack
fi
ln -sfn /usr/share/novnc/vnc.html /usr/share/novnc/index.html
systemctl daemon-reload
systemctl enable --now shared-dev-desktop.service shared-dev-web.service
systemctl is-active --quiet shared-dev-desktop.service
systemctl is-active --quiet shared-dev-web.service
rm -f "$state_dir/setup-failed"
date --iso-8601=seconds > "$state_dir/setup-complete"
