#!/bin/bash

NEW_IP="${1:-64.186.238.236}"
NEW_PORT="${2:-443}"

echo "目标 IP 设为: ${NEW_IP}"
echo "目标端口设为: ${NEW_PORT}"
echo "------------------------------------------------"

echo "正在清理 nat 表 OUTPUT 链中的旧规则..."
iptables -t nat -F OUTPUT

echo "正在添加新的 DNAT 规则..."

iptables -t nat -A OUTPUT -p tcp -d 104.16.0.0/12 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}
iptables -t nat -A OUTPUT -p tcp -d 162.158.0.0/15 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}
iptables -t nat -A OUTPUT -p tcp -d 172.64.0.0/13 -j DNAT --to-destination ${NEW_IP}:${NEW_PORT}

echo "iptables 规则更新完毕！"

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
