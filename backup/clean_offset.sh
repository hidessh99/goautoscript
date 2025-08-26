#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset warna
clear

source /home/autobackup.conf

cleanup_updates() {
    response=$(curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates")
    update_ids=$(echo "$response" | jq -r '.result[].update_id')

    for id in $update_ids; do
        curl -s "https://api.telegram.org/bot$RECEIVER_TOKEN/getUpdates?offset=$((id + 1))"
    done
}

cleanup_updates
