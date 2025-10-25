#!/bin/bash
set -e

echo "=== 容器初始化开始 ==="

export DEBIAN_FRONTEND=noninteractive

# 1. 替换国内源（清华 http 源）
cp /etc/apt/sources.list /etc/apt/sources.list.bak || true
cat > /etc/apt/sources.list << 'EOF'
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

# 2. 更新并安装常用工具
apt-get update
# **注意：在安装列表里添加 locale-all，确保所有 locale 被安装，虽然不是必须，但可以更保险**
apt-get install -yq \
    cron nano wget iputils-ping net-tools iproute2 dnsutils socat \
    openssh-server htop unzip locales tzdata 

# **优化：先设置中文环境 (4) 再设置时区 (3)**

# 4. 设置中文环境
# 确保 locale-gen 在任何可能用到 locale 的程序运行之前完成
echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen # 确保 locale 文件中包含 zh_CN.UTF-8
locale-gen zh_CN.UTF-8
echo 'LANG=zh_CN.UTF-8' > /etc/default/locale
export LANG=zh_CN.UTF-8
# 尝试重新加载 locale，虽然在脚本里不一定完全必要，但有助于即时生效
. /etc/default/locale

# 3. 设置时区
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
# 重新配置 tzdata，此时 locale 应该已经生效
dpkg-reconfigure -f noninteractive tzdata

# 5. 配置 SSH root 登录
echo 'root:1224' | chpasswd
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# 6. 启动 cron 和 ssh
/etc/init.d/cron restart
/etc/init.d/ssh restart

# 7. 写入 .bashrc 保证容器重启后自动启动服务 (如果容器作为 /bin/bash 启动)
if ! grep -q '# AUTO_START_CRON_SSH' ~/.bashrc; then
cat >> ~/.bashrc <<'EOF'

# AUTO_START_CRON_SSH
if [ "$$" -eq 1 ]; then
    /etc/init.d/cron restart
    /etc/init.d/ssh restart
    # 再次确保 LANG 变量设置，特别是对于交互式 Shell
    export LANG=zh_CN.UTF-8
fi
EOF
fi

echo "✅ 容器初始化完成，cron 和 ssh 已启动"
