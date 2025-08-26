#!/bin/bash

cd
clear

# Removed telegram notification functions

IP=$(wget -qO- ipinfo.io/ip);
domain=$(cat /usr/local/etc/xray/domain)
date=$(date +"%Y-%m-%d")

rm -rf /root/backup
mkdir -p /root/backup
mkdir -p /root/backup/limit
mkdir -p /root/backup/html

echo "Mohon Menunggu, Proses Backup sedang berlangsung !!"

cp -r /usr/local/etc/xray/ backup/
cp -r /etc/default/syncron/ backup/

cp -r /etc/allxray/ backup/
cp -r /etc/vmess/ backup/
cp -r /etc/vless/ backup/
cp -r /etc/trojan/ backup/
cp -r /etc/shadowsocks/ backup/
cp -r /etc/shadowsocks2022/ backup/
cp -r /etc/socks/ backup/
cp -r /etc/ssh/ backup/

cp /etc/passwd backup/
cp /etc/group backup/
cp /etc/shadow backup/
cp /etc/gshadow backup/

cp -r /var/www/html/allxray/ backup/html/allxray
cp -r /var/www/html/vmess/ backup/html/vmess
cp -r /var/www/html/vless/ backup/html/vless
cp -r /var/www/html/trojan/ backup/html/trojan
cp -r /var/www/html/shadowsocks/ backup/html/shadowsocks
cp -r /var/www/html/shadowsocks2022/ backup/html/shadowsocks2022
cp -r /var/www/html/socks5/ backup/html/socks
cp -r /var/www/html/ssh/ backup/html/ssh

cp -r /etc/limit/vmess/ backup/limit/vmess
cp -r /etc/limit/vless/ backup/limit/vless
cp -r /etc/limit/trojan/ backup/limit/trojan
cp -r /etc/limit/shadowsocks/ backup/limit/shadowsocks
cp -r /etc/limit/shadowsocks2022/ backup/limit/shadowsocks2022
cp -r /etc/limit/socks/ backup/limit/socks

cd /root
zip -r "$domain-$date.zip" backup > /dev/null 2>&1

# Removed telegram notification calls
rm -rf /root/backup
rm -r /root/$domain-$date.zip
clear
echo "Proses Backup telah selesai."
