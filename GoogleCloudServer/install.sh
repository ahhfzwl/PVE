#!/bin/bash

apt update
apt install -y ipset vnstat
CRON_JOB="* * * * * /usr/bin/vnstat -i ens4 --alert 0 3 m tx 200 GiB || /usr/sbin/poweroff"
( crontab -l 2>/dev/null | grep -v "$CRON_JOB" ; echo "$CRON_JOB" ) | crontab -
