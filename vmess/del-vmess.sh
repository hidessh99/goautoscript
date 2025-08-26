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

NUMBER_OF_CLIENTS=$(grep -c -E "^#@ " "/etc/default/syncron/vmess.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                ${WB}Delete Vmess Account${NC}                "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
vmess
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                ${WB}Delete Vmess Account${NC}                "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}User  Expired${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
grep -E "^#@ " "/etc/default/syncron/vmess.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Input Username : " user
if [ -z $user ]; then
vmess
else
exp=$(grep -wE "^#@ $user" "/etc/default/syncron/vmess.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^#@ $user $exp/,/^},{/d" /etc/default/syncron/vmess.json
rm -rf /var/www/html/vmess/vmess-$user.txt
rm -rf /user/log-vmess-$user.txt
sed -i "/\b$user\b/d" /etc/vmess/.vmess.db
rm -rf /etc/vmess/$user
rm -rf /etc/limit/vmess/$user
rm -rf /tmp/$user
systemctl restart vipssh@vmess.service
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "           ${WB}Vmess Account Success Deleted${NC}            "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
clear
vmess
fi

# #!/bin/bash

# NC='\e[0m'
# DEFBOLD='\e[39;1m'
# RB='\e[31;1m'
# GB='\e[32;1m'
# YB='\e[33;1m'
# BB='\e[34;1m'
# MB='\e[35;1m'
# CB='\e[35;1m'
# WB='\e[37;1m'
# clear
# NUMBER_OF_CLIENTS=$(grep -c -E "^#@ " "/etc/default/syncron/vmess.json")
# if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
#     clear
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     echo -e "                ${WB}Delete Vmess Account${NC}                "
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     echo -e "  ${YB}You have no existing clients!${NC}"
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     read -n 1 -s -r -p "Press any key to go back to the menu"
#     vmess
# fi
# clear
# echo -e "${BB}————————————————————————————————————————————————————${NC}"
# echo -e "                ${WB}Delete Vmess Account${NC}                "
# echo -e "${BB}————————————————————————————————————————————————————${NC}"
# echo -e " ${YB}User  Expired${NC}  "
# echo -e "${BB}————————————————————————————————————————————————————${NC}"
# grep -E "^#@ " "/etc/default/syncron/vmess.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | awk '{print NR")", $0}'
# echo ""
# echo -e "${YB}Enter the user number to delete or press enter to go back:${NC}"
# echo -e "${BB}————————————————————————————————————————————————————${NC}"
# read -rp "Input User Number : " user_number
# if [ -z "$user_number" ]; then
#     vmess
# elif [[ "$user_number" =~ ^[0-9]+$ && "$user_number" -ge 1 && "$user_number" -le $NUMBER_OF_CLIENTS ]]; then
#     user=$(grep -E "^#@ " "/etc/default/syncron/vmess.json" | awk '{print NR".",$0}' | sed -n "${user_number}"'s/^[0-9]\+\. //p')
#     exp=$(echo "$user" | cut -d ' ' -f 3 | sort | uniq)
#     username=$(echo "$user" | cut -d ' ' -f 2)
#     sed -i "/^#@ $username $exp/,/^},{/d" /etc/default/syncron/vmess.json
#     rm -rf "/var/www/html/vmess/vmess-$username.txt"
#     rm -rf "/user/log-vmess-$username.txt"
#     systemctl restart xray
#     clear
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     echo -e "           ${WB}Vmess Account Successfully Deleted${NC}            "
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     echo -e " ${YB}Client Name :${NC} $username"
#     echo -e " ${YB}Expired On  :${NC} $exp"
#     echo -e "${BB}————————————————————————————————————————————————————${NC}"
#     echo ""
#     read -n 1 -s -r -p "Press any key to go back to the menu"
#     clear
#     vmess
# else
#     echo -e "${RB}Invalid user number!${NC}"
#     read -n 1 -s -r -p "Press any key to go back to the menu"
#     clear
#     vmess
# fi

