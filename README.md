#找到 容器>选项>功能>嵌套 勾上

#停止容器
```sh
pct stop 100
```
#添加TUN
```sh
pct set 100 --dev0 /dev/net/tun
```
#挂载目录
```sh
pct set 100 -mp0 /share,mp=/share
```
#启动容器
```sh
pct start 100
```
```sh
wget -O $HOME/.dynv6.sh https://gist.githubusercontent.com/ahhfzwl/d3c6c51c2d41cd624ed7e279592aebe6/raw/33eb8aa1b1ccbc4c0a15c0891125bf3a0b0a862c/dynv6.sh
chmod +x $HOME/.dynv6.sh
token=tVfZgfE19REdPwy2jThrfCm58URR $HOME/.dynv6.sh cfnat.dynv6.net
```
```
apt -y autoremove ufw iptables
```
```sh
curl -LkO -H "Host: github.com" --resolve g.com:443:20.27.177.113 "$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep -o "https://github.com/SagerNet/sing-box/releases/download/.*/sing-box-.*-linux-$(uname -m | sed 's/x86_/amd/; s/aarch/arm/').tar.gz" | sort -V | head -n 1 | sed 's/github/g/' )"
```
