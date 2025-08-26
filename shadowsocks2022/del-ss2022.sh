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

NUMBER_OF_CLIENTS=$(grep -c -E "^#% " "/etc/default/syncron/shadowsocks2022.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "          ${WB}Delete Shadowsocks 2022 Account${NC}           "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
shadowsocks2022
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "          ${WB}Delete Shadowsocks 2022 Account${NC}           "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}User  Expired${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
grep -E "^#% " "/etc/default/syncron/shadowsocks2022.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Input Username : " user
if [ -z $user ]; then
shadowsocks2022
else
exp=$(grep -wE "^#% $user" "/etc/default/syncron/shadowsocks2022.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^#% $user $exp/,/^},{/d" /etc/default/syncron/shadowsocks2022.json
rm -rf /var/www/html/shadowsocks2022/shadowsocks2022-$user.txt
rm -rf /user/log-ss2022-$user.txt
sed -i "/\b$user\b/d" /etc/shadowsocks2022/.shadowsocks2022.db
rm -rf /etc/shadowsocks2022/$user
rm -rf /etc/limit/shadowsocks2022/$user
rm -rf /tmp/$user
systemctl restart vipssh@shadowsocks2022.service
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "      ${WB}Shadowsocks 2022 Account Success${NC} Deleted${NC}      "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
clear
shadowsocks2022
fi
