#!/bin/bash
# ------------------------------------------------------------------
#  说明：此脚本设计用于在一个 *已经运行* 的 Docker 容器内部执行。
#  目标：1. 立即配置当前环境并启动服务。
#         2. 尝试在下次登录时自动启动服务（通过 .bashrc）。
# ------------------------------------------------------------------
set -e

echo "=== 容器初始化开始 (运行环境) ==="

# 设置为非交互模式，避免 apt-get, tzdata 等命令卡住
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
echo "==> 2. 更新并安装常用工具..."
apt-get update
apt-get install -yq --no-install-recommends \
    cron nano wget iputils-ping net-tools iproute2 dnsutils socat \
    openssh-server htop unzip locales tzdata

# 清理 apt 缓存（即使在运行的容器中，保持整洁也是好习惯）
apt-get clean
rm -rf /var/lib/apt/lists/*

# 3. 设置时区
echo "==> 3. 设置时区为 Asia/Shanghai..."
# - 优化：简化步骤。设置 /etc/timezone 后，dpkg-reconfigure 会自动处理 /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# 4. 设置中文环境
echo "==> 4. 设置中文环境 (zh_CN.UTF-8)..."
# - 优化：使用 update-locale 命令，这是 Debian/Ubuntu 推荐的方式
locale-gen zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8
export LANG=zh_CN.UTF-8 # 立即在当前 Shell 生效

# 5. 配置 SSH root 登录
echo "==> 5. 配置 SSH root 登录..."
# -----------------------------------------------------------------
# [!! 严重安全警告 !!]
# 在容器中硬编码密码 (root:1224) 是极不安全的实践。
# 强烈建议你改为使用 SSH 密钥（authorized_keys）进行登录。
#
# --- 推荐的密钥配置方式 (请替换为你的公钥) ---
# mkdir -p /root/.ssh
# echo "ssh-rsa YOUR_PUBLIC_KEY_HERE your-key-name" > /root/.ssh/authorized_keys
# chmod 700 /root/.ssh
# chmod 600 /root/.ssh/authorized_keys
# -----------------------------------------------------------------
echo 'root:1224' | chpasswd

# 确保 sshd_config 中 PermitRootLogin 为 yes
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# 6. 启动 cron 和 ssh (立即在当前会话生效)
echo "==> 6. 启动 cron 和 ssh 服务 (当前会话)..."
# - 优化：使用 'service' 命令代替 /etc/init.d 脚本
# - 优化：使用 'start'。如果服务已运行，'start' 通常无害；'restart' 反而可能失败。
service cron start
service ssh start

# 7. 写入 .bashrc 保证容器（以 /bin/bash 登录时）自动启动服务
echo "==> 7. 尝试配置 .bashrc 以便下次登录时自动启动服务..."
# - 优化：明确使用 /root/.bashrc
# - 优化：使用 'start' 代替 'restart'
#
# [重要局限性说明]
# 见脚本底部的 "重要说明"。此方法非常不可靠。
if ! grep -q '# AUTO_START_CRON_SSH' /root/.bashrc; then
cat >> /root/.bashrc <<'EOF'

# AUTO_START_CRON_SSH
# 仅在 Shell 是 PID 1 (即容器的主进程是 /bin/bash) 时尝试启动服务
if [ "$$" -eq 1 ]; then
    echo "==> [.bashrc] 检测到 PID 1 Shell，尝试启动 cron 和 ssh 服务..."
    service cron start
    service ssh start
    export LANG=zh_CN.UTF-8
fi
EOF
fi

echo "✅ 容器初始化完成"
echo "[安全警告] SSH root 密码已设为 '1224'，请立即更改或使用 SSH 密钥！"

cat <<'EOF'
# ------------------------------------------------------------------
# [重要说明：关于服务持久化]
# 
# 你无法控制宿主机，因此你添加的第 7 步 (写入 .bashrc) 是你
# *唯一*能尝试持久化服务的方法，但它有 *严重局限性*：
#
# 1. 它 *不能* 在 `docker restart` 后自动启动服务。
#    容器重启时，它会执行它最初的 CMD/ENTRYPOINT（比如 `sleep infinity`），
#    它 *不会* 运行 `/root/.bashrc`。
#
# 2. 它 *只在* 你下次通过 `docker exec -it <container> /bin/bash`
#    (或者其他方式启动了一个 *交互式 Shell*) 时才可能触发。
#
# 3. 你的脚本 `if [ "$$" -eq 1 ]` 写法，是特指当 `/bin/bash`
#    作为容器的 *主进程* (PID 1) 启动时才运行。
#
# 结论：
# - 你刚才运行的脚本已经成功配置了 *当前* 的容器环境。
# - 但你 *无法* 真正实现 "容器重启后自动启动服务"。
#   这是由 Docker 机制决定的，必须在宿主机上通过 `docker run`
#   (使用正确的 ENTRYPOINT) 才能实现。
# ------------------------------------------------------------------
EOF
