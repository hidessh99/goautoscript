#!/bin/bash

NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
clear

domain=$(cat /usr/local/etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}Add Shadowsocks Account${NC}              "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /etc/default/syncron/shadowsocks.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}Add Shadowsocks Account${NC}              "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-ss
fi
done
cipher="aes-256-gcm"
read -p "Password: " uuid
read -p "Quota GB: " Quota
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#shadowsocks$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks.json
sed -i '/#shadowsocks-grpc$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/default/syncron/shadowsocks.json
echo -n "$cipher:$uuid" | base64 -w 0 > /tmp/log
ss_base64=$(cat /tmp/log)
sslink1="ss://${ss_base64}@$domain:443?path=/shadowsocks&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
sslink2="ss://${ss_base64}@$domain:80?path=/shadowsocks&security=none&host=${domain}&type=ws#${user}"
sslink3="ss://${ss_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks-grpc&sni=$domain#${user}"
rm -rf /tmp/log
cat > /var/www/html/shadowsocks/shadowsocks-$user.txt << END
==========================
Shadowsocks WS (CDN) TLS
==========================
- name: SS-$user
type: ss
server: $domain
port: 443
cipher: $cipher
password: $uuid
plugin: v2ray-plugin
plugin-opts:
mode: websocket
tls: true
skip-cert-verify: true
host: $domain
path: "/shadowsocks"
mux: true
==========================
Shadowsocks WS (CDN)
==========================
- name: SS-$user
type: ss
server: $domain
port: 80
cipher: $cipher
password: $uuid
plugin: v2ray-plugin
plugin-opts:
mode: websocket
tls: false
skip-cert-verify: false
host: $domain
path: "/shadowsocks"
mux: true
==========================
Link Shadowsocks Account
==========================
Link TLS : ss://${ss_base64}@$domain:443?path=/shadowsocks&security=tls&host=${domain}&type=ws&sni=${domain}#${user}
==========================
Link NTLS : ss://${ss_base64}@$domain:80?path=/shadowsocks&security=none&host=${domain}&type=ws#${user}
==========================
Link gRPC : ss://${ss_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=shadowsocks-grpc&sni=$domain#${user}
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart vipssh@shadowsocks.service
if [ ! -e /etc/shadowsocks ]; then
  mkdir -p /etc/shadowsocks
fi

if [ -z ${Quota} ]; then
  Quota="0"
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/shadowsocks/${user}
fi
DATADB=$(cat /etc/shadowsocks/.shadowsocks.db | grep "^###" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/shadowsocks/.shadowsocks.db
fi
echo "### ${user} ${exp} ${uuid} 2" >>/etc/shadowsocks/.shadowsocks.db

clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "                 Shadowsocks Account                " | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-ss-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-ss-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-ss-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-ss-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-ss-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-ss-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-ss-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-ss-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-ss-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-ss-$user.txt
echo -e "Cipher        : ${cipher}" | tee -a /user/log-ss-$user.txt
echo -e "Password      : $uuid" | tee -a /user/log-ss-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-ss-$user.txt
echo -e "Path          : /shadowsocks" | tee -a /user/log-ss-$user.txt
echo -e "ServiceName   : shadowsocks-grpc" | tee -a /user/log-ss-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link TLS      : ${sslink1}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link NTLS     : ${sslink2}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link gRPC     : ${sslink3}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Format Clash  : http://$domain:81/shadowsocks/shadowsocks-$user.txt" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
shadowsocks
