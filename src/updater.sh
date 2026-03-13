#!/bin/bash
# ==============================================================================
# SECTION: SELF-UPDATE MECHANISM
# ==============================================================================

handle_updates() {
    local mode="$1"
    if [ ! -d ".git" ]; then return 0; fi # Skip if not a git repo
    
    cd "$SCRIPT_DIR" || return 1
    if [ "$mode" == "manual" ]; then print_banner "Ashno Updater"; fi
    echo -en "  Checking for updates..."
    
    git fetch origin &>/dev/null
    if [ $? -ne 0 ]; then printf "\r\033[K"; echo -e "  ${RED}✖${NC} Could not fetch updates (Network issue?)."; return 1; fi
    
    local local_rev; local_rev=$(git rev-parse HEAD)
    local remote_rev; remote_rev=$(git rev-parse '@{u}')
    
    if [ "$local_rev" == "$remote_rev" ]; then 
        printf "\r\033[K"
        if [ "$mode" == "manual" ]; then echo -e "  ${GREEN}✔${NC} Ashno is already up to date."; fi
        return 0
    fi
    
    printf "\r\033[K"; echo -e "  ${YELLOW}●${NC} An update is available for Ashno!"
    if ! git diff-index --quiet HEAD --; then 
        echo -e "  ${RED}✖${NC} Update aborted. Local changes detected."; 
        [ "$mode" == "auto" ] && exit 1 || return 1
    fi
    
    local prompt_msg="Do you want to apply the update now? [Y/n]: "
    [ "$mode" == "auto" ] && prompt_msg="Update required. Apply now? [Y/n]: "
    
    read -p "  ${prompt_msg}" choice
    case "$choice" in
        [nN][oO]) echo -e "  Update cancelled."; [ "$mode" == "auto" ] && exit 1 || return 1 ;;
        *) echo -en "  Applying update..."; git pull origin main &>/dev/null
           printf "\r\033[K"; echo -e "  ${GREEN}✔${NC} Ashno updated. Restarting...";
           exec "$0" "$@" ;; # Restart script with same args
    esac
}
