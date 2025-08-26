#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset warna

clear

# Removed telegram bot configuration

show_menu() {
    echo "Menu:"
    echo "1. Backup"
    echo "2. Restore"
    echo "3. Membersihkan Offset"
    echo "0. Keluar"
}

backup() {
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
}

restore() {
    echo "Restore functionality requires manual upload of backup file."
    echo "Please manually upload and extract your backup file to restore."
}

cleanup_offset() {
    echo "Cleanup functionality removed (was telegram-dependent)."
}

clear
show_menu

while true; do
    read -p "Masukkan pilihan (0-3): " choice

    case $choice in
        0)
            break
            ;;
        1)
			cd
            backup
            ;;
        2)
			cd
            restore
            ;;
        3)
			cd
            cleanup_offset
            ;;
        *)
            echo "Pilihan tidak valid."
            ;;
    esac

    echo
    show_menu
done

exit 0
