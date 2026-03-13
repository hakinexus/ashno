#!/bin/bash
# ==============================================================================
# SECTION: INSTALLATION ENGINE
# ==============================================================================

build_package_list() {
    local pkg_type="$1"; local sel_prof_name="$2"; local f_list=""; local f_read=();
    # Logic to handle cumulative profiles (1...N)
    if [[ "$sel_prof_name" =~ ^([0-9]+)_.+ ]]; then 
        local p_lvl="${BASH_REMATCH[1]}"
        for i in $(seq 1 "$p_lvl"); do 
            local f_dir; f_dir=$(find "$PROFILES_DIR" -maxdepth 1 -type d -name "${i}_*" | head -n 1)
            if [ -n "$f_dir" ]; then 
                local l_file="${f_dir}/${pkg_type}.list"
                if [ -f "$l_file" ]; then f_read+=("$l_file"); fi
            fi
        done
    else 
        local l_file="${PROFILES_DIR}/${sel_prof_name}/${pkg_type}.list"
        if [ -f "$l_file" ]; then f_read+=("$l_file"); fi
    fi
    
    if [ ${#f_read[@]} -gt 0 ]; then 
        # Clean input: remove comments, empty lines, and Carriage Returns (for Windows-edited files)
        cat "${f_read[@]}" | tr -d '\r' | grep -vE '^\s*#|^\s*$' | sort -u
    fi
}

pre_flight_checks() { 
    print_banner "Performing System Checks"
    if ! ping -c 1 8.8.8.8 &>/dev/null; then echo -e " ${RED}✖${NC} Internet: Disconnected"; exit 1; fi
    echo -e " ${GREEN}✔${NC} Internet Connection: OK"
    
    # Check Termux Storage Access
    if [ ! -d ~/storage ]; then
        echo -e " ${YELLOW}!${NC} Requesting Storage Access..."
        termux-setup-storage
    fi
}

update_termux() { 
    print_banner "Updating Termux Base System"
    # Running pkg update in background
    (pkg update -y -o Dpkg::Options::="--force-confnew" && pkg upgrade -y -o Dpkg::Options::="--force-confnew") &>/dev/null & 
    local pid=$!
    echo -en "  Updating sources and packages... "
    spinner $pid
    wait $pid
    printf "\r\033[K"
    echo -e " ${GREEN}✔${NC} Base system update complete."
}

_process_package_list() {
    local CMD_CHECK="$1"; local INSTALL_CMD="$2"; shift 2; local package_list=("$@")
    for pkg_name in "${package_list[@]}"; do
        # Trim whitespace
        pkg_name=$(echo "$pkg_name" | xargs)
        [ -z "$pkg_name" ] && continue

        if $CMD_CHECK "$pkg_name" &>/dev/null; then
            SKIPPED_LIST+=("$pkg_name")
            echo -e " ${YELLOW}●${NC} ${pkg_name} (already installed)"
        else
            local error_log; error_log=$(mktemp)
            echo -en "  Installing ${BOLD}${pkg_name}${NC}... "
            
            ($INSTALL_CMD "$pkg_name") >/dev/null 2>"$error_log" & 
            local pid=$!
            spinner $pid
            wait $pid
            local exit_code=$?
            printf "\r\033[K"

            if [ "$exit_code" -eq 0 ]; then
                echo -e " ${GREEN}✔${NC}  ${pkg_name}"
                SUCCESS_LIST+=("$pkg_name")
            else
                echo -e " ${RED}✖${NC}  ${pkg_name}"
                FAILURE_LIST+=("$pkg_name")
                {
                    echo "-------------------------------------------------"
                    echo "[FAIL] Package Install: '$pkg_name' at $(date)"
                    echo "-------------------------------------------------"
                    cat "$error_log"
                    echo -e "\n"
                } >> "$LOG_FILE"
            fi
            rm -f "$error_log"
        fi
    done
}

install_pkg() {
    print_banner "Installing PKG Packages"
    local package_list; package_list=$(build_package_list "pkg" "$SELECTED_PROFILE")
    if [ -z "$package_list" ]; then echo "No PKG packages found in this profile."; return; fi
    local list_array; readarray -t list_array <<< "$package_list"
    _process_package_list "dpkg -s" "pkg install -y" "${list_array[@]}"
}

install_npm() {
    print_banner "Installing NPM Packages"
    if ! command -v npm &>/dev/null; then 
        echo -e "${YELLOW}Notification:${NC} NPM not found. Installing Node.js first..."
        pkg install -y nodejs &>/dev/null
    fi
    local package_list; package_list=$(build_package_list "npm" "$SELECTED_PROFILE")
    if [ -z "$package_list" ]; then echo "No NPM packages found in this profile."; return; fi
    local list_array; readarray -t list_array <<< "$package_list"
    _process_package_list "npm list -g --depth=0" "npm install -g" "${list_array[@]}"
}

install_pip() {
    print_banner "Installing PIP Packages"
    if ! command -v pip &>/dev/null; then 
        echo -e "${YELLOW}Notification:${NC} PIP not found. Installing Python first..."
        pkg install -y python &>/dev/null
    fi
    echo -en "  Upgrading PIP core... "
    (pip install --upgrade pip setuptools wheel) &>/dev/null & spinner $!; wait $!
    printf "\r\033[K"
    
    local package_list; package_list=$(build_package_list "pip" "$SELECTED_PROFILE")
    if [ -z "$package_list" ]; then echo "No PIP packages found in this profile."; return; fi
    local list_array; readarray -t list_array <<< "$package_list"
    _process_package_list "pip show" "pip install --no-cache-dir" "${list_array[@]}"
}
