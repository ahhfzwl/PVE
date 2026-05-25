#!/bin/bash -e

sed -i 's/deb.debian.org/mirrors.huaweicloud.com/g' /etc/apt/sources.list.d/debian.sources
apt update
export DEBIAN_FRONTEND=noninteractive
apt install -y cron openssh-server wget curl sudo gpg htop unzip locales tzdata nano iputils-ping net-tools iproute2 dnsutils socat

echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen zh_CN.UTF-8
echo 'LANG=zh_CN.UTF-8' > /etc/default/locale
export LANG=zh_CN.UTF-8
. /etc/default/locale

ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo 'root:1224' | chpasswd
sed -i 's/^#\?Port .*/Port 22/g' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
rm -r /etc/ssh/sshd_config.d
/etc/init.d/cron restart
/etc/init.d/ssh restart

if ! grep -q '# AUTO_START' ~/.bashrc; then
cat >> ~/.bashrc <<'EOF'
# AUTO_START
if [ "$$" -eq 1 ]; then
    /etc/init.d/cron restart
    /etc/init.d/ssh restart
    export LANG=zh_CN.UTF-8
fi
EOF
fi
