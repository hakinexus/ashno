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
    if [ $? -ne 0 ]; then printf "\r\033[K"; print_formatting error "Could not fetch updates (Network issue?)."; return 1; fi
    
    local local_rev; local_rev=$(git rev-parse HEAD)
    local remote_rev; remote_rev=$(git rev-parse '@{u}')
    
    if [ "$local_rev" == "$remote_rev" ]; then 
        printf "\r\033[K"
        if [ "$mode" == "manual" ]; then print_formatting success "Ashno is already up to date."; fi
        return 0
    fi
    
    printf "\r\033[K"; print_formatting warn "An update is available for Ashno!"
    if ! git diff-index --quiet HEAD --; then 
        print_formatting error "Update aborted. Local changes detected."; 
        [ "$mode" == "auto" ] && exit 1 || return 1
    fi
    
    local should_update=false
    if command -v gum &>/dev/null; then
        gum confirm "Apply the update now?" && should_update=true
    else
        local prompt_msg="Do you want to apply the update now? [Y/n]: "
        [ "$mode" == "auto" ] && prompt_msg="Update required. Apply now? [Y/n]: "
        read -p "  ${prompt_msg}" choice
        case "$choice" in
            [nN][oO]) should_update=false ;;
            *) should_update=true ;;
        esac
    fi

    if [ "$should_update" = true ]; then
        echo -en "  Applying update..."
        git pull origin main &>/dev/null
        printf "\r\033[K"
        print_formatting success "Ashno updated. Restarting..."
        exec "$SCRIPT_PATH" "${ORIGINAL_ARGS[@]}"
    else
        print_formatting warn "Update cancelled."
        [ "$mode" == "auto" ] && exit 1 || return 1
    fi
}
