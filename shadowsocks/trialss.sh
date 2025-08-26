#!/bin/bash



domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
cipher="aes-256-gcm"
read -p "Password: " uuid
masaaktif=1
echo ""
echo ""
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
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "              Trial Shadowsocks Account             " | tee -a /user/log-ss-$user.txt
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
