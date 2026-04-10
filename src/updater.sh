#!/bin/bash
# ==============================================================================
# SECTION: SELF-UPDATE MECHANISM
# ==============================================================================

handle_updates() {
    local mode="$1"
    if [ ! -d "$SCRIPT_DIR/.git" ]; then return 0; fi

    local orig_dir="$PWD"
    cd "$SCRIPT_DIR" || return 1

    if [ "$mode" = "manual" ]; then print_banner "Ashno Updater"; fi
    echo -en "  Checking for updates..."

    if ! git fetch origin &>/dev/null; then
        printf "\r\033[K"
        print_formatting error "Could not fetch updates (Network issue?)."
        cd "$orig_dir" || true
        return 1
    fi

    local local_rev remote_rev
    local_rev=$(git rev-parse HEAD)
    remote_rev=$(git rev-parse '@{u}' 2>/dev/null)

    if [ -z "$remote_rev" ] || [ "$local_rev" = "$remote_rev" ]; then
        printf "\r\033[K"
        if [ "$mode" = "manual" ]; then print_formatting success "Ashno is already up to date."; fi
        cd "$orig_dir" || true
        return 0
    fi

    printf "\r\033[K"
    print_formatting warn "An update is available for Ashno!"

    if ! git diff-index --quiet HEAD --; then
        print_formatting error "Update aborted. Local changes detected."
        cd "$orig_dir" || true
        [ "$mode" = "auto" ] && exit 1 || return 1
    fi

    local should_update=false
    if command -v gum &>/dev/null; then
        gum confirm "Apply the update now?" && should_update=true
    else
        local prompt_msg="Do you want to apply the update now? [Y/n]: "
        [ "$mode" = "auto" ] && prompt_msg="Update required. Apply now? [Y/n]: "
        read -r -p "  ${prompt_msg}" choice
        case "$choice" in
            [nN]|[nN][oO]) should_update=false ;;
            *) should_update=true ;;
        esac
    fi

    if [ "$should_update" = true ]; then
        local current_branch
        current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
        echo -en "  Applying update..."
        if git pull origin "$current_branch" &>/dev/null; then
            printf "\r\033[K"
            print_formatting success "Ashno updated. Restarting..."
            exec "$SCRIPT_PATH" "${ORIGINAL_ARGS[@]}"
        else
            printf "\r\033[K"
            print_formatting error "Update failed (git pull error). Continuing with current version."
            cd "$orig_dir" || true
            return 1
        fi
    else
        print_formatting warn "Update cancelled."
        cd "$orig_dir" || true
        [ "$mode" = "auto" ] && exit 1 || return 1
    fi
}
