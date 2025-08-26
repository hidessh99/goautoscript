#!/bin/bash



domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
pass=`echo $RANDOM | head -c4`
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#socks$/a\#÷ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
sed -i '/#socks-grpc$/a\#÷ '"$user $exp"'\
},{"user": "'""$user""'","pass": "'""$pass""'","email": "'""$user""'"' /etc/default/syncron/socks.json
echo -n "$user:$pass" | base64 > /tmp/log
socks_base64=$(cat /tmp/log)
sockslink1="socks://$socks_base64@$domain:443?path=/socks5&security=tls&host=$domain&type=ws&sni=$domain#$user"
sockslink2="socks://$socks_base64@$domain:80?path=/socks5&security=none&host=$domain&type=ws#$user"
sockslink3="socks://$socks_base64@$domain:443?security=tls&encryption=none&type=grpc&serviceName=socks5-grpc&sni=$domain#$user"
rm -rf /tmp/log
cat > /var/www/html/socks5/socks5-$user.txt << EOF
========================
Format Json Socks5
========================
{
"inbounds": [],
"outbounds": [
{
"mux": {
"enabled": true
},
"protocol": "socks",
"settings": {
"servers": [
{
"address": "$domain",
"port": 443,
"users": [
{
"level": 8,
"pass": "$pass",
"user": "$user"
}
]
}
]
},
"streamSettings": {
"network": "ws",
"security": "tls",
"tlsSettings": {
"allowInsecure": true,
"serverName": "$domain"
},
"wsSettings": {
"headers": {
"Host": "$domain"
},
"path": "/socks5"
}
},
"tag": "XRAY"
}
],
"policy": {
"levels": {
"8": {
"connIdle": 300,
"downlinkOnly": 1,
"handshake": 4,
"uplinkOnly": 1
}
}
}
}
===============================
Link Socks5 Account
===============================
Link TLS : socks://$socks_base64@$domain:443?path=/socks5&security=tls&host=$domain&type=ws&sni=$domain#$user
==============================
Link NTLS : socks://$socks_base64@$domain:80?path=/socks5&security=none&host=$domain&type=ws#$user
==============================
Link gRPC : socks://$socks_base64@$domain:443?security=tls&encryption=none&type=grpc&serviceName=socks5-grpc&sni=$domain#$user
==============================
EOF
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart vipssh@socks.service
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "               Trial Socks5 Account                 " | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Username      : ${user}" | tee -a /user/log-socks5-$user.txt
echo -e "Password      : ${pass}" | tee -a /user/log-socks5-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-socks5-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-socks5-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-socks5-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-socks5-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-socks5-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-socks5-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-socks5-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-socks5-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-socks5-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-socks5-$user.txt
echo -e "Path          : /socks5" | tee -a /user/log-socks5-$user.txt
echo -e "ServiceName   : socks5-grpc" | tee -a /user/log-socks5-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link TLS      : ${sockslink1}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link NTLS     : ${sockslink2}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Link gRPC     : ${sockslink3}" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo -e "Format JSON   : http://$domain:81/socks5/socks5-$user.txt" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-socks5-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
echo " " | tee -a /user/log-socks5-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
socks
