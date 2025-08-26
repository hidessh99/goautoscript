#!/bin/bash

# ACME.sh Installation and Management Script
# Following project specifications: absolute paths, user input preferences, URL transformation

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

# Function 1: Install ACME.sh
function install_acme() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Installing ACME.sh...${NC}"
    
    # Check if already installed
    if [ -d "/root/.acme.sh" ]; then
        echo -e "${YB}[ WARNING ]${NC} ACME.sh is already installed at /root/.acme.sh"
        read -p "Do you want to reinstall? (y/n): " reinstall
        if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
            echo -e "${RB}[ CANCELLED ]${NC} Installation cancelled"
            return
        fi
        rm -rf /root/.acme.sh
    fi
    
    # Install required packages
    echo -e "${GB}[ INFO ]${NC} Installing required packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y socat curl cron >/dev/null 2>&1
    
    # Download and install acme.sh
    echo -e "${GB}[ INFO ]${NC} Downloading ACME.sh from official repository..."
    curl -s https://get.acme.sh | sh >/dev/null 2>&1
    
    # Verify installation
    if [ -d "/root/.acme.sh" ] && [ -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${GB}[ SUCCESS ]${NC} ACME.sh installed successfully at /root/.acme.sh"
        
        # Set default CA
        /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1
        echo -e "${GB}[ INFO ]${NC} Default CA set to Let's Encrypt"
        
        # Enable auto-upgrade
        /root/.acme.sh/acme.sh --upgrade --auto-upgrade >/dev/null 2>&1
        echo -e "${GB}[ INFO ]${NC} Auto-upgrade enabled"
    else
        echo -e "${RB}[ ERROR ]${NC} ACME.sh installation failed"
        return 1
    fi
}

# Function 2: Update ACME.sh
function update_acme() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Updating ACME.sh...${NC}"
    
    # Check if ACME.sh is installed
    if [ ! -d "/root/.acme.sh" ] || [ ! -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${RB}[ ERROR ]${NC} ACME.sh is not installed. Please install it first."
        read -p "Do you want to install ACME.sh now? (y/n): " install_now
        if [[ $install_now == "y" || $install_now == "Y" ]]; then
            install_acme
        fi
        return
    fi
    
    echo -e "${GB}[ INFO ]${NC} Current ACME.sh version:"
    /root/.acme.sh/acme.sh --version
    
    echo -e "${GB}[ INFO ]${NC} Updating to latest version..."
    cd /root/.acme.sh
    ./acme.sh --upgrade >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GB}[ SUCCESS ]${NC} ACME.sh updated successfully"
        echo -e "${GB}[ INFO ]${NC} New ACME.sh version:"
        ./acme.sh --version
    else
        echo -e "${RB}[ ERROR ]${NC} Failed to update ACME.sh"
        return 1
    fi
}

# Function 3: Configure ACME.sh
function configure_acme() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Configuring ACME.sh...${NC}"
    
    # Check if ACME.sh is installed
    if [ ! -d "/root/.acme.sh" ] || [ ! -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${RB}[ ERROR ]${NC} ACME.sh is not installed. Please install it first."
        read -p "Do you want to install ACME.sh now? (y/n): " install_now
        if [[ $install_now == "y" || $install_now == "Y" ]]; then
            install_acme
        fi
        return
    fi
    
    cd /root/.acme.sh
    
    echo -e "${GB}[ INFO ]${NC} Current configuration:"
    ./acme.sh --info
    
    echo ""
    echo -e "${YB}Configuration Options:${NC}"
    echo "1. Set default CA server"
    echo "2. Configure email for notifications"
    echo "3. Enable/Disable auto-upgrade"
    echo "4. Set log level"
    echo "5. Show current configuration"
    echo "0. Exit configuration"
    
    while true; do
        echo ""
        read -p "Choose configuration option (0-5): " config_option
        
        case $config_option in
            1)
                echo ""
                echo "Available CA servers:"
                echo "1. Let's Encrypt (letsencrypt)"
                echo "2. ZeroSSL (zerossl)"
                echo "3. Buypass (buypass)"
                echo "4. SSL.com (sslcom)"
                read -p "Choose CA server (1-4): " ca_choice
                
                case $ca_choice in
                    1) ca_server="letsencrypt" ;;
                    2) ca_server="zerossl" ;;
                    3) ca_server="buypass" ;;
                    4) ca_server="sslcom" ;;
                    *) echo -e "${RB}[ ERROR ]${NC} Invalid choice"; continue ;;
                esac
                
                ./acme.sh --set-default-ca --server $ca_server
                echo -e "${GB}[ SUCCESS ]${NC} Default CA set to $ca_server"
                ;;
            2)
                read -p "Enter email for notifications: " email
                if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    ./acme.sh --register-account -m $email
                    echo -e "${GB}[ SUCCESS ]${NC} Email configured: $email"
                else
                    echo -e "${RB}[ ERROR ]${NC} Invalid email format"
                fi
                ;;
            3)
                read -p "Enable auto-upgrade? (y/n): " auto_upgrade
                if [[ $auto_upgrade == "y" || $auto_upgrade == "Y" ]]; then
                    ./acme.sh --upgrade --auto-upgrade
                    echo -e "${GB}[ SUCCESS ]${NC} Auto-upgrade enabled"
                else
                    ./acme.sh --upgrade --auto-upgrade 0
                    echo -e "${GB}[ SUCCESS ]${NC} Auto-upgrade disabled"
                fi
                ;;
            4)
                echo ""
                echo "Log levels:"
                echo "1. Error only"
                echo "2. Info (default)"
                echo "3. Debug"
                read -p "Choose log level (1-3): " log_choice
                
                case $log_choice in
                    1) log_level="1" ;;
                    2) log_level="2" ;;
                    3) log_level="3" ;;
                    *) echo -e "${RB}[ ERROR ]${NC} Invalid choice"; continue ;;
                esac
                
                export LE_CONFIG_HOME="/root/.acme.sh"
                echo "LE_WORKING_DIR=\"/root/.acme.sh\"" > /root/.acme.sh/account.conf
                echo "LOG_LEVEL=\"$log_level\"" >> /root/.acme.sh/account.conf
                echo -e "${GB}[ SUCCESS ]${NC} Log level set to $log_level"
                ;;
            5)
                echo ""
                echo -e "${YB}Current ACME.sh Configuration:${NC}"
                ./acme.sh --info
                ./acme.sh --version
                ;;
            0)
                echo -e "${GB}[ INFO ]${NC} Exiting configuration"
                break
                ;;
            *)
                echo -e "${RB}[ ERROR ]${NC} Invalid option. Please choose 0-5."
                ;;
        esac
}

# ================================
# SSL CERTIFICATE FUNCTIONS
# ================================

# Function 4: Install Certificate
function install_certificate() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Installing SSL Certificate...${NC}"
    
    if [ ! -d "/root/.acme.sh" ] || [ ! -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${RB}[ ERROR ]${NC} ACME.sh is not installed. Please install it first."
        return 1
    fi
    
    read -p "Enter domain name: " domain
    if [[ -z "$domain" ]]; then
        echo -e "${RB}[ ERROR ]${NC} Domain name cannot be empty"
        return 1
    fi
    
    echo -e "${YB}Installation Options:${NC}"
    echo "1. Standalone (port 80 must be free)"
    echo "2. Webroot (specify web directory)"
    echo "3. DNS API (Cloudflare)"
    
    read -p "Choose method (1-3): " method
    
    cd /root/.acme.sh
    
    case $method in
        1)
            systemctl stop nginx >/dev/null 2>&1
            ./acme.sh --issue -d $domain --standalone --keylength ec-256
            ;;
        2)
            read -p "Enter webroot directory: " webroot
            ./acme.sh --issue -d $domain --webroot $webroot --keylength ec-256
            ;;
        3)
            read -p "Enter Cloudflare API Key: " cf_key
            read -p "Enter Cloudflare Email: " cf_email
            export CF_Key="$cf_key"
            export CF_Email="$cf_email"
            ./acme.sh --issue -d $domain --dns dns_cf --keylength ec-256
            ;;
        *)
            echo -e "${RB}[ ERROR ]${NC} Invalid method"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        mkdir -p /usr/local/etc/xray
        ./acme.sh --installcert -d $domain \
            --fullchainpath /usr/local/etc/xray/fullchain.crt \
            --keypath /usr/local/etc/xray/private.key \
            --reloadcmd "systemctl restart nginx; systemctl restart xray"
        echo -e "${GB}[ SUCCESS ]${NC} Certificate installed for $domain"
    else
        echo -e "${RB}[ ERROR ]${NC} Failed to install certificate"
    fi
}

# Function 5: Renew Certificate
function renew_certificate() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Renewing SSL Certificate...${NC}"
    
    if [ ! -d "/root/.acme.sh" ] || [ ! -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${RB}[ ERROR ]${NC} ACME.sh is not installed."
        return 1
    fi
    
    cd /root/.acme.sh
    ./acme.sh --list
    
    read -p "Enter domain to renew (or 'all'): " domain
    
    if [[ "$domain" == "all" ]]; then
        ./acme.sh --renew-all --force
    else
        systemctl stop nginx >/dev/null 2>&1
        ./acme.sh --renew -d $domain --force
        systemctl start nginx >/dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GB}[ SUCCESS ]${NC} Certificate renewed successfully"
    else
        echo -e "${RB}[ ERROR ]${NC} Failed to renew certificate"
    fi
}

# Function 6: Issue New Certificate
function issue_new_certificate() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Issuing New SSL Certificate...${NC}"
    
    if [ ! -d "/root/.acme.sh" ] || [ ! -f "/root/.acme.sh/acme.sh" ]; then
        echo -e "${RB}[ ERROR ]${NC} ACME.sh is not installed."
        return 1
    fi
    
    read -p "Enter domain name: " domain
    if [[ -z "$domain" ]]; then
        echo -e "${RB}[ ERROR ]${NC} Domain name cannot be empty"
        return 1
    fi
    
    echo -e "${YB}Certificate Types:${NC}"
    echo "1. Single domain"
    echo "2. Multiple domains"
    echo "3. Wildcard domain"
    
    read -p "Choose type (1-3): " cert_type
    
    cd /root/.acme.sh
    
    case $cert_type in
        1)
            install_certificate
            ;;
        2)
            domains="-d $domain"
            while true; do
                read -p "Enter additional domain (Enter to finish): " add_domain
                if [[ -z "$add_domain" ]]; then
                    break
                fi
                domains="$domains -d $add_domain"
            done
            systemctl stop nginx >/dev/null 2>&1
            ./acme.sh --issue $domains --standalone --keylength ec-256
            ;;
        3)
            read -p "Enter root domain: " root_domain
            read -p "Enter Cloudflare API Key: " cf_key
            read -p "Enter Cloudflare Email: " cf_email
            export CF_Key="$cf_key"
            export CF_Email="$cf_email"
            ./acme.sh --issue -d "*.$root_domain" -d "$root_domain" --dns dns_cf --keylength ec-256
            ;;
        *)
            echo -e "${RB}[ ERROR ]${NC} Invalid type"
            return 1
            ;;
    esac
}

# ================================
# DOMAIN MANAGEMENT FUNCTIONS
# ================================

# Function 7: Add Domain
function add_domain() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Adding Domain...${NC}"
    
    read -p "Enter domain name: " domain
    if [[ -z "$domain" ]]; then
        echo -e "${RB}[ ERROR ]${NC} Domain name cannot be empty"
        return 1
    fi
    
    # Validate domain format
    if [[ ! $domain =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RB}[ ERROR ]${NC} Invalid domain format"
        return 1
    fi
    
    # Create domain structure
    mkdir -p /etc/xray/domains/$domain
    echo "$domain" > /etc/xray/domains/$domain/domain.conf
    echo "$(date)" > /etc/xray/domains/$domain/added.date
    echo "$domain" >> /etc/xray/domain.list
    
    # Set as active domain if first
    if [ ! -f "/usr/local/etc/xray/domain" ]; then
        echo "$domain" > /usr/local/etc/xray/domain
    fi
    
    echo -e "${GB}[ SUCCESS ]${NC} Domain $domain added"
    
    read -p "Issue SSL certificate? (y/n): " issue_cert
    if [[ $issue_cert == "y" || $issue_cert == "Y" ]]; then
        install_certificate
    fi
}

# Function 8: Remove Domain
function remove_domain() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Removing Domain...${NC}"
    
    if [ -f "/etc/xray/domain.list" ]; then
        echo -e "${YB}Available domains:${NC}"
        cat /etc/xray/domain.list | nl
    else
        echo -e "${RB}[ ERROR ]${NC} No domains found"
        return 1
    fi
    
    read -p "Enter domain to remove: " domain
    if [[ -z "$domain" ]]; then
        echo -e "${RB}[ ERROR ]${NC} Domain name cannot be empty"
        return 1
    fi
    
    if ! grep -q "^$domain$" /etc/xray/domain.list 2>/dev/null; then
        echo -e "${RB}[ ERROR ]${NC} Domain not found"
        return 1
    fi
    
    read -p "Remove $domain and its certificate? (y/n): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        echo -e "${RB}[ CANCELLED ]${NC} Removal cancelled"
        return
    fi
    
    # Remove domain
    sed -i "/^$domain$/d" /etc/xray/domain.list
    rm -rf /etc/xray/domains/$domain
    
    # Remove certificate
    if [ -d "/root/.acme.sh" ]; then
        cd /root/.acme.sh
        ./acme.sh --remove -d $domain >/dev/null 2>&1
    fi
    
    # Update active domain if needed
    if [ -f "/usr/local/etc/xray/domain" ] && [ "$(cat /usr/local/etc/xray/domain)" == "$domain" ]; then
        new_domain=$(head -n 1 /etc/xray/domain.list 2>/dev/null)
        if [[ -n "$new_domain" ]]; then
            echo "$new_domain" > /usr/local/etc/xray/domain
        else
            rm -f /usr/local/etc/xray/domain
        fi
    fi
    
    echo -e "${GB}[ SUCCESS ]${NC} Domain $domain removed"
}

# Function 9: Validate Domain
function validate_domain() {
    echo -e "${GB}[ INFO ]${NC} ${YB}Validating Domain...${NC}"
    
    read -p "Enter domain to validate: " domain
    if [[ -z "$domain" ]]; then
        echo -e "${RB}[ ERROR ]${NC} Domain name cannot be empty"
        return 1
    fi
    
    echo -e "${GB}[ INFO ]${NC} Validating: $domain"
    
    # DNS Check
    echo -e "${YB}1. DNS Resolution:${NC}"
    domain_ip=$(dig +short $domain | tail -n1)
    if [[ -n "$domain_ip" ]]; then
        echo -e "${GB}[ SUCCESS ]${NC} Resolves to: $domain_ip"
        
        server_ip=$(curl -s https://checkip.amazonaws.com/)
        if [[ "$domain_ip" == "$server_ip" ]]; then
            echo -e "${GB}[ SUCCESS ]${NC} Points to this server"
        else
            echo -e "${YB}[ WARNING ]${NC} Points to different server"
        fi
    else
        echo -e "${RB}[ ERROR ]${NC} DNS resolution failed"
    fi
    
    # HTTP Check
    echo -e "${YB}2. HTTP Connectivity:${NC}"
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "http://$domain" --connect-timeout 10)
    if [[ "$http_status" =~ ^[23] ]]; then
        echo -e "${GB}[ SUCCESS ]${NC} HTTP accessible (Status: $http_status)"
    else
        echo -e "${RB}[ ERROR ]${NC} HTTP failed (Status: $http_status)"
    fi
    
    # HTTPS Check
    echo -e "${YB}3. HTTPS Connectivity:${NC}"
    https_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain" --connect-timeout 10 --insecure)
    if [[ "$https_status" =~ ^[23] ]]; then
        echo -e "${GB}[ SUCCESS ]${NC} HTTPS accessible (Status: $https_status)"
    else
        echo -e "${RB}[ ERROR ]${NC} HTTPS failed (Status: $https_status)"
    fi
    
    # SSL Certificate Check
    echo -e "${YB}4. SSL Certificate:${NC}"
    if command -v openssl >/dev/null 2>&1; then
        cert_info=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
        if [[ -n "$cert_info" ]]; then
            echo -e "${GB}[ SUCCESS ]${NC} SSL certificate found"
            expiry_date=$(echo "$cert_info" | grep "notAfter" | cut -d'=' -f2)
            if [[ -n "$expiry_date" ]]; then
                echo -e "${GB}[ INFO ]${NC} Expires: $expiry_date"
            fi
        else
            echo -e "${RB}[ ERROR ]${NC} No SSL certificate"
        fi
    fi
    
    echo -e "${GB}[ INFO ]${NC} Validation completed"
}

# Main menu function
function show_menu() {
    clear
    echo -e "${BB}╭─────────────────────────────────────────────╮${NC}"
    echo -e "${BB}│${NC}           ${YB}ACME.sh Management Menu${NC}           ${BB}│${NC}"
    echo -e "${BB}╰─────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${CB}═══ ACME.sh Installation ═══${NC}"
    echo -e "${GB}1.${NC} Install ACME.sh"
    echo -e "${GB}2.${NC} Update ACME.sh"
    echo -e "${GB}3.${NC} Configure ACME.sh"
    echo ""
    echo -e "${CB}═══ SSL Certificate Management ═══${NC}"
    echo -e "${GB}4.${NC} Install Certificate"
    echo -e "${GB}5.${NC} Renew Certificate"
    echo -e "${GB}6.${NC} Issue New Certificate"
    echo ""
    echo -e "${CB}═══ Domain Management ═══${NC}"
    echo -e "${GB}7.${NC} Add Domain"
    echo -e "${GB}8.${NC} Remove Domain"
    echo -e "${GB}9.${NC} Validate Domain"
    echo ""
    echo -e "${RB}0.${NC} Exit"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    while true; do
        show_menu
        read -p "Choose an option (0-9): " choice
        
        case $choice in
            1)
                install_acme
                read -p "Press Enter to continue..."
                ;;
            2)
                update_acme
                read -p "Press Enter to continue..."
                ;;
            3)
                configure_acme
                read -p "Press Enter to continue..."
                ;;
            4)
                install_certificate
                read -p "Press Enter to continue..."
                ;;
            5)
                renew_certificate
                read -p "Press Enter to continue..."
                ;;
            6)
                issue_new_certificate
                read -p "Press Enter to continue..."
                ;;
            7)
                add_domain
                read -p "Press Enter to continue..."
                ;;
            8)
                remove_domain
                read -p "Press Enter to continue..."
                ;;
            9)
                validate_domain
                read -p "Press Enter to continue..."
                ;;
            0)
                echo -e "${GB}[ INFO ]${NC} Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${RB}[ ERROR ]${NC} Invalid option. Please choose 0-9."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
fi