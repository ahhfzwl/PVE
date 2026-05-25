apt update
export DEBIAN_FRONTEND=noninteractive
apt install -y openssh-server cron curl sudo nano wget iputils-ping net-tools iproute2 dnsutils socat htop unzip locales tzdata
echo 'root:1224' | chpasswd && sed -i 's/^#\?Port .*/Port 2095/g;s/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && service ssh restart
