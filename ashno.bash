#!/bin/bash

# ===============================================================
#
# Termux Professional Package Installer
#
# Version: 1.0
#
# Description: This script provides a professional-grade,
#              automated installation of essential packages
#              for Termux, neatly categorized by PKG, NPM,
#              and PIP. It incorporates robust error handling
#              and a user-friendly interactive menu.
#
# ===============================================================

# --- ANSI Color Codes for Professional Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Log File for Auditing ---
LOG_FILE="termux_installation_log.txt"

# --- Centralized Logging Function ---
log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# --- Standardized Banner Function ---
print_banner() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}== ${YELLOW}$1 ${BLUE}==${NC}"
    echo -e "${BLUE}================================================${NC}"
}

# --- Command Success Verification ---
check_success() {
    if [ $? -ne 0 ]; then
        log_message "${RED}Error: Failed to install $1.${NC}"
    else
        log_message "${GREEN}Success: $1 has been installed successfully.${NC}"
    fi
}

# --- Core Termux Environment Update ---
update_termux() {
    print_banner "Updating and Upgrading Base Termux Packages"
    log_message "Initiating package update and upgrade..."
    pkg update -y && pkg upgrade -y
    check_success "Termux base packages"
}

# --- PKG Package Installation Module ---
install_pkg_packages() {
    print_banner "Installing Essential PKG Packages"
    
    CORE_UTILS="termux-tools util-linux coreutils binutils findutils grep sed gawk tar zip unzip less man"
    DEV_TOOLS="git build-essential clang cmake python python2 nodejs-lts openjdk-17 golang ruby perl php"
    NET_TOOLS="openssh curl wget nmap net-tools inetutils tcpdump whois dnsutils"
    SYS_SHELL="htop proot tsu tmux zsh fish neofetch termux-api"
    EDITORS="nano vim neovim emacs micro"

    ALL_PKG_PACKAGES="$CORE_UTILS $DEV_TOOLS $NET_TOOLS $SYS_SHELL $EDITORS"

    for pkg_name in $ALL_PKG_PACKAGES; do
        log_message "Attempting to install $pkg_name..."
        pkg install -y $pkg_name
        check_success "$pkg_name"
    done
    
    # Optimized installation for numpy and matplotlib
    log_message "Installing numpy and matplotlib via pkg for best compatibility..."
    pkg install -y python-numpy matplotlib
    check_success "numpy and matplotlib"
}

# --- NPM Package Installation Module ---
install_npm_packages() {
    print_banner "Installing Global NPM Packages"
    
    if ! command -v npm &> /dev/null; then
        log_message "${RED}NPM is not available. Please install Node.js first.${NC}"
        return
    fi
    
    NPM_PACKAGES="npm yarn express nodemon pm2 http-server live-server webpack axios lodash react vue-cli @angular/cli eslint prettier typescript"
    
    for npm_name in $NPM_PACKAGES; do
        log_message "Installing $npm_name via NPM..."
        npm install -g $npm_name
        check_success "$npm_name"
    done
}

# --- PIP Package Installation Module ---
install_pip_packages() {
    print_banner "Installing Python (PIP) Packages"
    
    if ! command -v pip &> /dev/null; then
        log_message "${RED}PIP is not available. Please install Python first.${NC}"
        return
    fi

    pip install --upgrade pip setuptools wheel
    
    PIP_PACKAGES="virtualenv requests beautifulsoup4 lxml scipy pandas scikit-learn tensorflow torch jupyter flask django fastapi sqlalchemy pylint autopep8 yt-dlp ansible scrapy"

    for pip_name in $PIP_PACKAGES; do
        log_message "Installing $pip_name via PIP..."
        pip install --no-cache-dir $pip_name
        check_success "$pip_name"
    done
}

# --- Interactive Main Menu ---
main_menu() {
    clear
    print_banner "Termux Professional Installer"
    echo -e "${YELLOW}Please select an installation option:${NC}"
    echo "1. Full Installation (All Packages - Recommended)"
    echo "2. Install PKG Packages Only"
    echo "3. Install NPM Packages Only"
    echo "4. Install PIP Packages Only"
    echo "5. Exit Installer"
    echo ""
    read -p "Enter your choice [1-5]: " choice
    
    case $choice in
        1)
            update_termux
            install_pkg_packages
            install_npm_packages
            install_pip_packages
            log_message "${GREEN}All installations have been completed.${NC}"
            ;;
        2)
            update_termux
            install_pkg_packages
            log_message "${GREEN}PKG package installation is complete.${NC}"
            ;;
        3)
            install_npm_packages
            log_message "${GREEN}NPM package installation is complete.${NC}"
            ;;
        4)
            install_pip_packages
            log_message "${GREEN}PIP package installation is complete.${NC}"
            ;;
        5)
            echo "Exiting the installer."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid selection. Please try again.${NC}"
            sleep 2
            main_menu
            ;;
    esac
    echo ""
    read -p "Press Enter to return to the main menu..."
    main_menu
}

# --- Script Execution Start ---
main_menu
