#!/bin/bash

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit 1
fi

# 设置默认值
DEFAULT_IP="154.17.237.131"
DEFAULT_PORT="18700"

# 如果用户提供了参数就用参数，没提供就用默认值
NEW_IP="${1:-$DEFAULT_IP}"
NEW_PORT="${2:-$DEFAULT_PORT}"

echo "目标 IP 设为: ${NEW_IP}"
echo "目标端口设为: ${NEW_PORT}"
echo "------------------------------------------------"

echo "正在清理 nat 表 OUTPUT 链中的旧规则..."
iptables -t nat -F OUTPUT

echo "正在添加新的 DNAT 规则..."

# 规则 1: 104.16.0.0/12
iptables -t nat -A OUTPUT -p tcp -d 104.16.0.0/12 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}

# 规则 2: 162.158.0.0/15
iptables -t nat -A OUTPUT -p tcp -d 162.158.0.0/15 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}

# 规则 3: 172.64.0.0/13
iptables -t nat -A OUTPUT -p tcp -d 172.64.0.0/13 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}

echo "iptables 规则更新完毕！"

# 自动保存规则，防止重启失效
echo "正在将规则持久化保存到系统（防止重启丢失）..."
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
elif command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
else
    echo "⚠️ 警告: 未找到持久化工具，重启后规则可能会失效！"
fi

echo "------------------------------------------------"
echo "当前 nat 表状态如下："
iptables -t nat -L OUTPUT -n -v
