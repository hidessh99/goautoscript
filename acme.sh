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
    done
}

# Main menu function
function show_menu() {
    clear
    echo -e "${BB}╭─────────────────────────────────────────────╮${NC}"
    echo -e "${BB}│${NC}           ${YB}ACME.sh Management Menu${NC}           ${BB}│${NC}"
    echo -e "${BB}╰─────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${GB}1.${NC} Install ACME.sh"
    echo -e "${GB}2.${NC} Update ACME.sh"
    echo -e "${GB}3.${NC} Configure ACME.sh"
    echo -e "${RB}0.${NC} Exit"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    while true; do
        show_menu
        read -p "Choose an option (0-3): " choice
        
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
            0)
                echo -e "${GB}[ INFO ]${NC} Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${RB}[ ERROR ]${NC} Invalid option. Please choose 0-3."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
fi