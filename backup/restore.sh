#!/bin/bash
clear

# Token bot Telegram
TOKEN="5813428539:AAGYOn5lRxkQGLPztqywj4ePcyNrSOgMDSE"
# ID chat
CHAT_ID="1496322138"

get_last_file_id() {
    updates=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates")
    file_id=$(echo "$updates" | jq -r '.result[-1].message.document.file_id')
    echo "$file_id"
}

get_file() {
    file_id=$(get_last_file_id)

    if [[ -n "$file_id" ]]; then
        file_name=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates" | jq -r '.result[].message.document | select(.file_id == "'$file_id'") | .file_name')
        response=$(curl -s "https://api.telegram.org/bot$TOKEN/getFile?file_id=$file_id")
        file_path=$(echo "$response" | jq -r '.result.file_path')
        download_url="https://api.telegram.org/file/bot$TOKEN/$file_path"
        curl -s -o "$file_name" "$download_url"

        # Proses restore file di sini
    else
        echo "File tidak ditemukan."
    fi
}

get_file
