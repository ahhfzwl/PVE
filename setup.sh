#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

cat > /etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

apt-get update && \
apt-get install -yq --no-install-recommends \
    cron nano wget iputils-ping net-tools iproute2 dnsutils socat \
    openssh-server htop unzip locales tzdata && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

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
