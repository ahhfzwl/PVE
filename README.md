apt -y autoremove ufw iptables
#下载sing-box
```sh
curl -LkO -H "Host: github.com" --resolve g.com:443:20.27.177.113 "$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep -o "https://github.com/SagerNet/sing-box/releases/download/.*/sing-box-.*-linux-$(uname -m | sed 's/x86_/amd/; s/aarch/arm/').tar.gz" | sort -V | head -n 1 | sed 's/github/g/' )"
```
