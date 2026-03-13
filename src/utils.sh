#!/bin/bash
# ==============================================================================
# SECTION: UTILITY & UI HELPER FUNCTIONS
# ==============================================================================

# --- BOOTSTRAP: Ensure Core Dependencies Exist Before UI Starts ---
bootstrap_core() {
    # We need ncurses-utils for 'tput' (UI) and coreutils for basic logic
    local missing_deps=0
    if ! command -v tput &>/dev/null; then missing_deps=1; fi
    
    if [ $missing_deps -eq 1 ]; then
        echo "Initializing core dependencies for first run..."
        # Silently update and install ncurses-utils
        pkg update -y -o Dpkg::Options::="--force-confnew" &>/dev/null
        pkg install -y ncurses-utils coreutils &>/dev/null
    fi
}
bootstrap_core

# --- UI Helper Wrappers (Fail-safe) ---
# These prevent the script from crashing if tput is somehow still missing
cursor_hide() { command -v tput &>/dev/null && tput civis; }
cursor_show() { command -v tput &>/dev/null && tput cnorm; }

# --- Graceful Exit Handler ---
cleanup() { 
    echo -e "\n\n${YELLOW}SIGINT received. Shutting down gracefully.${NC}"
    cursor_show
    exit 130
}
trap cleanup INT TERM

print_banner() {
    local title=" $1 "
    local inner_len=$((${#title} + 2))
    local border_line
    border_line=$(printf '─%.0s' $(seq 1 $inner_len))

    echo -e "\n${BLUE}╭─${border_line}─╮${NC}"
    echo -e "${BLUE}│  ${BOLD}${YELLOW}${title}${BLUE}  │${NC}"
    echo -e "${BLUE}╰─${border_line}─╯${NC}"
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
    local str='⣾⣽⣻⢿⡿⣟⣯⣷'
    while kill -0 "$pid" 2>/dev/null; do
        printf "${PURPLE}%s${NC}" "${str:0:1}"
        str=${str:1}${str:0:1}
        sleep 0.08
        printf "\b"
    done
    printf " "
    cursor_show
}
