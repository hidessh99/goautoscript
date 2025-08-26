#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset warna
clear

# Mendapatkan alamat IP
IP=$(wget -qO- ipinfo.io/ip)

# Memeriksa status autobackup
cek=$(grep -c -E "^# BEGIN_Backup" /etc/crontab)
if [[ "$cek" = "1" ]]; then
    sts="${GREEN}[ON]${NC}"
else
    sts="${RED}[OFF]${NC}"
fi

# Fungsi untuk memulai autobackup
function start() {
    # Memeriksa apakah file konfigurasi sudah ada
    if [[ ! -f "/home/autobackup.conf" ]]; then
        echo "Please enter your receiver bot token"
        read -rp "Token: " -e receiver_token
        echo "Please enter your chat ID"
        read -rp "Chat ID: " -e chat_id
        echo "RECEIVER_TOKEN=$receiver_token" > /home/autobackup.conf
        echo "CHAT_ID=$chat_id" >> /home/autobackup.conf
    fi

    # Menambahkan entri ke crontab untuk menjalankan backup
    cat <<EOF >> /etc/crontab
# BEGIN_Backup
5 0 * * * root backup
# END_Backup
EOF

    # Merestart cron service
    service cron restart
    sleep 1
    clear
    echo "Autobackup has been started"
    echo "Data will be backed up automatically at 00:05 GMT +7"
    exit 0
}

# Fungsi untuk menghentikan autobackup
function stop() {
    # Menghapus entri crontab untuk backup
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    # Merestart cron service
    service cron restart
    sleep 1
    clear
    echo "Autobackup has been stopped"
    exit 0
}

# Fungsi untuk mengubah token bot penerima
function change_receiver_token() {
    echo "Please enter your receiver bot token"
    read -rp "Token: " -e receiver_token
    sed -i "s/^RECEIVER_TOKEN=.*/RECEIVER_TOKEN=$receiver_token/" /home/autobackup.conf
    clear
    echo "Receiver bot token has been changed"
}

# Fungsi untuk mengubah chat ID
function change_chat_id() {
    echo "Please enter your chat ID"
    read -rp "Chat ID: " -e chat_id
    sed -i "s/^CHAT_ID=.*/CHAT_ID=$chat_id/" /home/autobackup.conf
    clear
    echo "Chat ID has been changed"
}

# Fungsi untuk mengirim pesan uji ke bot
function test_message() {
    # Membaca token bot penerima dan chat ID dari file konfigurasi
    source /home/autobackup.conf
    if [[ "$RECEIVER_TOKEN" = "" || "$CHAT_ID" = "" ]]; then
        echo "Please set the receiver token and chat ID in /home/autobackup.conf file"
        exit 1
    fi

    # Mengirim pesan uji ke bot
    curl -s -X POST "https://api.telegram.org/bot$RECEIVER_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=This is a test message from autobackup script\nIP: $IP\nDate: $(date +"%Y-%m-%d")"

    clear
    echo "Test message has been sent"
}

clear
echo "=============================="
echo -e "     Autobackup Data $sts     "
echo "=============================="
echo "1. Start Autobackup"
echo "2. Stop Autobackup"
echo "3. Change Receiver Bot Token"
echo "4. Change Chat ID"
echo "5. Test Send Message"
echo "=============================="
read -rp "Please enter the correct number: " -e num

case $num in
    1) start ;;
    2) stop ;;
    3) change_receiver_token ;;
    4) change_chat_id ;;
    5) test_message ;;
    *) clear ;;
esac
