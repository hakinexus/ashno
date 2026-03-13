#!/bin/bash
# ==============================================================================
# SECTION: UTILITY & UI HELPER FUNCTIONS
# ==============================================================================

# --- BOOTSTRAP: Ensure Core Dependencies Exist Before UI Starts ---
bootstrap_core() {
    # We need ncurses-utils for 'tput' (UI), coreutils for basic logic, and gum for God-Level UI
    local missing_deps=0
    if ! command -v tput &>/dev/null; then missing_deps=1; fi
    if ! command -v gum &>/dev/null; then missing_deps=1; fi
    
    if [ $missing_deps -eq 1 ]; then
        echo "Initializing core dependencies (including Gum) for optimal UI..."
        # Silently update and install required packages
        pkg update -y -o Dpkg::Options::="--force-confnew" &>/dev/null
        pkg install -y ncurses-utils coreutils gum &>/dev/null
    fi
}
bootstrap_core

# --- UI Helper Wrappers (Fail-safe) ---
# These prevent the script from crashing if tput is somehow missing
cursor_hide() { command -v tput &>/dev/null && tput civis; }
cursor_show() { command -v tput &>/dev/null && tput cnorm; }

# --- Graceful Exit Handler ---
cleanup() { 
    echo -e "\n\n${YELLOW}SIGINT received. Shutting down gracefully.${NC}"
    cursor_show
    exit 130
}
trap cleanup INT TERM

# --- Glamorous UI Helpers ---
print_banner() {
    local title="$1"
    if command -v gum &>/dev/null; then
        echo ""
        gum style --border double --margin "0 1" --padding "0 3" --border-foreground 212 --foreground 212 --bold --align center "$title"
        echo ""
    else
        local padded=" $title "
        local inner_len=$((${#padded} + 2))
        local border_line
        border_line=$(printf '─%.0s' $(seq 1 $inner_len))

        echo -e "\n${BLUE}╭─${border_line}─╮${NC}"
        echo -e "${BLUE}│  ${BOLD}${YELLOW}${padded}${BLUE}  │${NC}"
        echo -e "${BLUE}╰─${border_line}─╯${NC}"
    fi
}

print_formatting() {
    local mode="$1"; local msg="$2"
    if command -v gum &>/dev/null; then
        local badge badge_text
        case "$mode" in
            info)
                badge=$(gum style --foreground 255 --background 39 --bold ' INFO ')
                badge_text=$(gum style --foreground 39 "$msg")
                ;;
            success)
                badge=$(gum style --foreground 255 --background 46 --bold '  OK  ')
                badge_text=$(gum style --foreground 46 "$msg")
                ;;
            warn)
                badge=$(gum style --foreground 0 --background 214 --bold ' WARN ')
                badge_text=$(gum style --foreground 214 "$msg")
                ;;
            error)
                badge=$(gum style --foreground 255 --background 196 --bold ' FAIL ')
                badge_text=$(gum style --foreground 196 "$msg")
                ;;
        esac
        echo "$badge $badge_text"
    else
        case "$mode" in
            info)    echo -e " ${BLUE}ℹ${NC} $msg" ;;
            success) echo -e " ${GREEN}✔${NC} $msg" ;;
            warn)    echo -e " ${YELLOW}⚠${NC} $msg" ;;
            error)   echo -e " ${RED}✖${NC} $msg" ;;
        esac
    fi
}

print_prompt() { echo -en "\n${CYAN}>${NC}${BOLD} Select an option:${NC} "; }

setup_logging() {
    mkdir -p "$LOG_DIR" || { echo -e "${RED}Fatal: Could not create log directory at ${LOG_DIR}${NC}"; exit 1; }
    LOG_FILE="${LOG_DIR}/ashno_$(date +'%Y%m%d-%H%M%S').log"
    {
        echo "Ashno Installation Log"
        echo "=========================================="
        echo "Date: $(date)"
        echo "Profile: ${SELECTED_PROFILE:-"N/A"}"
        echo "System: $(uname -a)"
        echo -e "\n"
    } > "$LOG_FILE"
}

spinner() {
    cursor_hide
    local pid=$1
    if command -v gum &>/dev/null; then
        # We can't cleanly wrap a pre-existing background pid with `gum spin` directly easily,
        # but we can use gum to render the spinner characters styling.
        local str='⣾⣽⣻⢿⡿⣟⣯⣷'
        while kill -0 "$pid" 2>/dev/null; do
            printf "\e[38;5;212m%s\e[0m" "${str:0:1}" # Magenta/Pink color for Gum theme
            str=${str:1}${str:0:1}
            sleep 0.08
            printf "\b"
        done
        printf " "
    else
        local str='⣾⣽⣻⢿⡿⣟⣯⣷'
        while kill -0 "$pid" 2>/dev/null; do
            printf "${PURPLE}%s${NC}" "${str:0:1}"
            str=${str:1}${str:0:1}
            sleep 0.08
            printf "\b"
        done
        printf " "
    fi
    cursor_show
}
