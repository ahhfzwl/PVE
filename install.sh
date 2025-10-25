#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

sh -c 'echo "
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free-firmware non-free
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free-firmware non-free
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main contrib non-free-firmware non-free
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main contrib non-free-firmware non-free
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free-firmware non-free
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free-firmware non-free
" > /etc/apt/sources.list'
rm -rf /etc/apt/sources.list.d

apt-get update && \
apt-get install -y ca-certificates cron nano wget iputils-ping net-tools iproute2 dnsutils socat openssh-server htop unzip locales tzdata

echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

locale-gen zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8
export LANG=zh_CN.UTF-8

echo 'root:1224' | chpasswd
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

service cron start
service ssh start

if ! grep -q '# AUTO_START_CRON_SSH' /root/.bashrc; then
cat >> /root/.bashrc <<\EOF

# AUTO_START_CRON_SSH
if [ "$$" -eq 1 ]; then
    service cron start
    service ssh start
    export LANG=zh_CN.UTF-8
fi
EOF
fi
