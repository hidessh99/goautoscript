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

NUMBER_OF_CLIENTS=$(grep -c -E "^#= " "/etc/default/syncron/vless.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}Delete Vless Account${NC}               "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
vless
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                 Delete Vless Account               "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}User  Expired${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
grep -E "^#= " "/etc/default/syncron/vless.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Input Username : " user
if [ -z $user ]; then
vless
else
exp=$(grep -wE "^#= $user" "/etc/default/syncron/vless.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^#= $user $exp/,/^},{/d" /etc/default/syncron/vless.json
rm -rf /var/www/html/vless/vless-$user.txt
rm -rf /user/log-vless-$user.txt
sed -i "/\b$user\b/d" /etc/vless/.vless.db
rm -rf /etc/vless/$user
rm -rf /etc/limit/vless/$user
rm -rf /tmp/$user
systemctl restart vipssh@vless.service
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "            ${WB}Vless Account Success Deleted${NC}           "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
clear
vless
fi
