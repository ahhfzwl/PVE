#!/bin/bash
set -e

echo "=== 容器初始化开始 ==="

# 设置为非交互模式，避免 apt-get 等命令卡住
export DEBIAN_FRONTEND=noninteractive

# 1. 替换国内源（清华 https 源）
# 使用 cat <<EOF 结构更清晰
cat <<EOF > /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# 2. 更新并安装常用工具
# - 优化：增加 --no-install-recommends 减少不必要的包，减小镜像体积
# - 优化：安装后清理 apt 缓存，减小镜像体积
apt-get update
apt-get install -yq --no-install-recommends \
    cron nano wget iputils-ping net-tools iproute2 dnsutils socat \
    openssh-server htop unzip locales tzdata
apt-get clean
rm -rf /var/lib/apt/lists/*

# 3. 设置时区
# - 优化：简化步骤。设置 /etc/timezone 后，dpkg-reconfigure 会自动处理 /etc/localtime 软链接
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# 4. 设置中文环境
# - 优化：使用 update-locale 命令，这是 Debian/Ubuntu 推荐的方式
locale-gen zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8
export LANG=zh_CN.UTF-8 # 立即在当前会话生效

# 5. 配置 SSH root 登录
# [!! 严重安全警告 !!]
# 在镜像中硬编码密码 (root:1224) 是极不安全的实践。
# 任何人拿到你的镜像都可以轻易登录。
# 强烈建议使用 SSH 密钥（authorized_keys）进行登录。
# --- 推荐的密钥配置方式 (请替换为你的公钥) ---
# mkdir -p /root/.ssh
# echo "ssh-rsa YOUR_PUBLIC_KEY_HERE your-key-name" > /root/.ssh/authorized_keys
# chmod 700 /root/.ssh
# chmod 600 /root/.ssh/authorized_keys
# ------------------------------------------------
echo 'root:1224' | chpasswd

# 确保 sshd_config 中 PermitRootLogin 为 yes
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# 6. 启动 cron 和 ssh
# [注意] 
# 如果此脚本在 'docker build' 的 RUN 指令中运行，
# 在此启动的服务会在该层构建完成后被停止，这一步是无效的。
# 真正的服务启动应该由 Docker 容器的 Entrypoint 或 CMD 来处理。
# 参见第 7 步的说明。
# 
# - 优化：使用 'service' 命令代替 /etc/init.d 脚本
echo "==> 步骤 6：尝试启动服务（仅在构建层中有效）"
service cron start
service ssh start

# 7. 写入 .bashrc 保证容器（以 /bin/bash 启动时）自动启动服务
# [注意] 
# 这是一个常见的技巧，但并非最佳实践。
# 它只在容器的 PID 1 进程是 bash (如 'docker run -it image /bin/bash') 时才有效。
# 如果使用 'docker run -d image' 或自定义 CMD，此脚本不会运行。
# 最佳实践是使用一个专门的 entrypoint.sh 脚本来启动服务并 'exec' 传入的 CMD。
#
# - 优化：
#   - 使用 'start' 而不是 'restart'，因为此时服务并未运行。
#   - 明确使用 /root/.bashrc，因为此脚本必须以 root 身份运行。
if ! grep -q '# AUTO_START_CRON_SSH' /root/.bashrc; then
cat >> /root/.bashrc <<'EOF'

# AUTO_START_CRON_SSH
# 检查是否为 PID 1 (通常在 'docker run -it ... /bin/bash' 时)
if [ "$$" -eq 1 ]; then
    echo "==> [From .bashrc] 正在启动 cron 和 ssh 服务..."
    service cron start
    service ssh start
    export LANG=zh_CN.UTF-8
fi
EOF
fi

echo "✅ 容器初始化完成"
echo "[安全警告] SSH root 密码已设为 '1224'，请立即更改或使用 SSH 密钥！"
