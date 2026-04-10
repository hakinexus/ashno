#!/bin/bash
# ==============================================================================
# SECTION: INSTALLATION ENGINE
# ==============================================================================

build_package_list() {
    local pkg_type="$1"; local sel_prof_name="$2"; local f_read=();
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
    if ! ping -c 1 -W 5 8.8.8.8 &>/dev/null; then print_formatting error "Internet: Disconnected"; exit 1; fi
    print_formatting success "Internet Connection: OK"
    
    # Check Termux Storage Access
    if [ ! -d ~/storage ]; then
        print_formatting warn "Requesting Storage Access..."
        termux-setup-storage
    fi
}

update_termux() {
    print_banner "Updating Termux Base System"
    (pkg update -y -o Dpkg::Options::="--force-confnew" && pkg upgrade -y -o Dpkg::Options::="--force-confnew") &>/dev/null &
    local pid=$!
    echo -en "  Updating sources and packages... "
    spinner $pid
    wait $pid
    local exit_code=$?
    printf "\r\033[K"
    if [ "$exit_code" -eq 0 ]; then
        print_formatting success "Base system update complete."
    else
        print_formatting warn "Base system update completed with errors."
    fi
}

check_pkg_installed() {
    local pkg_name="$1"
    # Fast check: true package name
    dpkg -s "$pkg_name" &>/dev/null && return 0
    # Accurate check: virtual packages and aliases (0 newly installed means satisfied)
    apt-get -s install "$pkg_name" 2>/dev/null | grep -q "0 newly installed" && return 0
    return 1
}

_process_package_list() {
    local CMD_CHECK="$1"; local INSTALL_CMD="$2"; shift 2; local package_list=("$@")
    local pending_list=()

    for pkg_name in "${package_list[@]}"; do
        pkg_name=$(echo "$pkg_name" | xargs)
        [ -z "$pkg_name" ] && continue

        if $CMD_CHECK "$pkg_name" &>/dev/null; then
            SKIPPED_LIST+=("$pkg_name")
            print_formatting info "${pkg_name} (already installed)"
        else
            pending_list+=("$pkg_name")
        fi
    done

    if [ ${#pending_list[@]} -eq 0 ]; then
        return 0
    fi

    # Build timeout prefixes — gracefully degrade if timeout is unavailable
    local batch_timeout="" single_timeout="" has_timeout=false
    if command -v timeout &>/dev/null; then
        has_timeout=true
        batch_timeout="timeout $INSTALL_TIMEOUT_BATCH"
        single_timeout="timeout $INSTALL_TIMEOUT_SINGLE"
    fi

    # --- Batch Install Attempt ---
    local batch_error_log; batch_error_log=$(mktemp)
    echo -en "  Installing ${#pending_list[@]} packages (Batch Mode)... "

    ($batch_timeout $INSTALL_CMD "${pending_list[@]}") >/dev/null 2>"$batch_error_log" &
    local pid=$!
    spinner $pid
    wait $pid
    local batch_exit_code=$?
    printf "\r\033[K"

    if [ "$batch_exit_code" -eq 0 ]; then
        print_formatting success "Installed ${#pending_list[@]} packages successfully"
        for pkg_name in "${pending_list[@]}"; do
            SUCCESS_LIST+=("$pkg_name")
        done
        rm -f "$batch_error_log"
        return 0
    fi

    if [ "$has_timeout" = true ] && [ "$batch_exit_code" -eq 124 ]; then
        print_formatting warn "Batch installation timed out ($((INSTALL_TIMEOUT_BATCH / 60))m limit). Falling back to sequential mode..."
    else
        print_formatting warn "Batch installation failed. Falling back to sequential mode..."
    fi
    rm -f "$batch_error_log"

    # --- Sequential Fallback ---
    for pkg_name in "${pending_list[@]}"; do
        local error_log; error_log=$(mktemp)
        echo -en "  Installing ${BOLD}${pkg_name}${NC}... "

        ($single_timeout $INSTALL_CMD "$pkg_name") >/dev/null 2>"$error_log" &
        local pid=$!
        spinner $pid
        wait $pid
        local exit_code=$?
        printf "\r\033[K"

        if [ "$exit_code" -eq 0 ]; then
            print_formatting success " ${pkg_name}"
            SUCCESS_LIST+=("$pkg_name")
        elif [ "$has_timeout" = true ] && [ "$exit_code" -eq 124 ]; then
            print_formatting error " ${pkg_name} (timed out — $((INSTALL_TIMEOUT_SINGLE / 60))m limit)"
            FAILURE_LIST+=("$pkg_name")
        else
            print_formatting error " ${pkg_name}"
            FAILURE_LIST+=("$pkg_name")
        fi
        rm -f "$error_log"
    done
}

install_pkg() {
    print_banner "Installing PKG Packages"
    local package_list; package_list=$(build_package_list "pkg" "$SELECTED_PROFILE")
    if [ -z "$package_list" ]; then echo "No PKG packages found in this profile."; return; fi
    local list_array; readarray -t list_array <<< "$package_list"
    _process_package_list "check_pkg_installed" "pkg install -y" "${list_array[@]}"
}

install_npm() {
    print_banner "Installing NPM Packages"
    if ! command -v npm &>/dev/null; then 
        print_formatting warn "NPM not found. Installing Node.js first..."
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
        print_formatting warn "PIP not found. Installing Python first..."
        pkg install -y python &>/dev/null
    fi
    echo -en "  Upgrading PIP core... "
    (pip install --upgrade pip setuptools wheel) &>/dev/null &
    local pip_pid=$!
    spinner $pip_pid; wait $pip_pid
    local pip_exit=$?
    printf "\r\033[K"
    if [ "$pip_exit" -ne 0 ]; then
        print_formatting warn "PIP core upgrade failed. Continuing with existing version."
    fi
    
    local package_list; package_list=$(build_package_list "pip" "$SELECTED_PROFILE")
    if [ -z "$package_list" ]; then echo "No PIP packages found in this profile."; return; fi
    local list_array; readarray -t list_array <<< "$package_list"
    _process_package_list "pip show" "pip install --no-cache-dir" "${list_array[@]}"
}
