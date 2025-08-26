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

NUMBER_OF_CLIENTS=$(grep -c -E "^#&@ " /etc/default/syncron/*.json)

if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "               ${WB}Extend All Xray Accounts${NC}              "
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "  ${YB}You have no existing clients!${NC}"
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to go back to the menu"
    allxray
fi

clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}Extend All Xray Accounts${NC}              "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Clients with Expiry Dates${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"

# List clients with their expiry dates from all JSON files
grep -E "^#&@ " /etc/default/syncron/*.json | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}Press Enter to go back${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Enter Username: " user

if [ -z $user ]; then
    allxray
else
    read -p "Extend Expiry (days): " masaaktif
    exp=$(grep -wE "^#&@ $user" /etc/default/syncron/*.json | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`

    # Extend the expiration date in all JSON files
    sed -i "/#&@ $user/c\#&@ $user $exp4" /etc/default/syncron/*.json
    systemctl restart xray

    clear
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e "          ${WB}All Xray Accounts Successfully Extended${NC}         "
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo -e " ${YB}Client Name :${NC} $user"
    echo -e " ${YB}Expiry Date :${NC} $exp4"
    echo -e "${BB}————————————————————————————————————————————————————${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to go back to the menu"
    clear
    allxray
fi
