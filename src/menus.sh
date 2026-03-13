#!/bin/bash
# ==============================================================================
# SECTION: MENUS & REPORTING
# ==============================================================================

print_help_menu() {
    clear; print_banner "Ashno Help Manual"
    echo -e "A professional, self-updating tool that installs packages from profiles."
    echo; echo -e "${BOLD}${YELLOW}USAGE:${NC}"; echo -e "  ashno ${PURPLE}[COMMANDS]${NC}"; echo -e "    Running without commands launches the interactive menu."
    echo; echo -e "${BOLD}${YELLOW}INSTALLATION COMMANDS:${NC}"
    printf "  ${PURPLE}%-20s${NC} %s\n" "--profile <NAME>" "Required. Selects a profile by its directory name."
    printf "  ${PURPLE}%-20s${NC} %s\n" "--all | --pkg | ..." "Required. The action to perform (install all, pkg, etc.)."
    echo; echo -e "${BOLD}${YELLOW}UTILITY COMMANDS:${NC}"
    printf "  ${PURPLE}%-20s${NC} %s\n" "-u, --update" "Checks for and applies updates to Ashno itself."
    printf "  ${PURPLE}%-20s${NC} %s\n" "-h, --help" "Display this help manual and exit."
    echo; echo -e "${BOLD}${YELLOW}EXAMPLE:${NC}"; echo -e "  ashno --profile 2_extended --all"; echo
}

print_summary_report() {
    print_banner "Installation Summary Report"
    
    if command -v gum &>/dev/null; then
        local error_note=""
        if [ ${#FAILURE_LIST[@]} -gt 0 ]; then
            error_note="\n\n**NOTE:** Errors occurred. Check the log file:\n\`${LOG_FILE}\`"
        fi
        
        # We use gum format to render markdown, and wrap it in a beautiful box
        gum format "# Installation Summary
- ✔ **Successful:** ${#SUCCESS_LIST[@]}
- ✖ **Failed:**     ${#FAILURE_LIST[@]}
- ● **Skipped:**    ${#SKIPPED_LIST[@]}
${error_note}

### **Operation Complete.**" | gum style --border rounded --border-foreground 212 --padding "1 4" --margin "1 2"
    else
        echo -e " Summary of all installation operations."; echo
        echo -e " ${GREEN}✔ Successful: ${#SUCCESS_LIST[@]}${NC}"
        echo -e " ${RED}✖ Failed:     ${#FAILURE_LIST[@]}${NC}"
        echo -e " ${YELLOW}● Skipped:    ${#SKIPPED_LIST[@]}${NC}"

        if [ ${#FAILURE_LIST[@]} -gt 0 ]; then
            echo; echo -e "${YELLOW}NOTE:${NC} Errors occurred. Check the log file:"
            echo -e "      ${BOLD}${LOG_FILE}${NC}"
        fi
        echo -e "\n${GREEN}${BOLD}Operation Complete.${NC}"
    fi
}

main_menu() {
    clear; print_banner "Main Menu"
    echo -e "  ${BOLD}Active Profile:${NC} ${YELLOW}${SELECTED_PROFILE}${NC}\n"
    
    if command -v gum &>/dev/null; then
        local choice
        choice=$(gum choose --cursor "➜ " --cursor.foreground="212" --item.foreground="250" --selected.foreground="212" --selected.bold "Full Installation (PKG, NPM, PIP)" "Install PKG Packages" "Install NPM Packages" "Install PIP Packages" "Change Profile" "Exit Ashno")
        case "$choice" in
            "Full Installation (PKG, NPM, PIP)") main_choice=1 ;;
            "Install PKG Packages")              main_choice=2 ;;
            "Install NPM Packages")              main_choice=3 ;;
            "Install PIP Packages")              main_choice=4 ;;
            "Change Profile")                  main_choice=5 ;;
            "Exit Ashno")                        main_choice=6 ;;
        esac
    else
        echo -e "  ${CYAN}1)${NC}  ${BOLD}Full Installation${NC} (PKG, NPM, PIP)"
        echo -e "  ${CYAN}2)${NC}  Install ${BOLD}PKG${NC} Packages"
        echo -e "  ${CYAN}3)${NC}  Install ${BOLD}NPM${NC} Packages"
        echo -e "  ${CYAN}4)${NC}  Install ${BOLD}PIP${NC} Packages"
        echo; echo -e "  ${CYAN}5)${NC}  Change Profile"
        echo -e "  ${CYAN}6)${NC}  Exit Ashno"
        print_prompt; read main_choice
    fi
}

profile_selection_menu() {
    clear; print_banner "Choose Installation Profile"
    local profiles=(); while IFS= read -r line; do profiles+=("$line"); done < <(find "$PROFILES_DIR" -maxdepth 1 -mindepth 1 -type d | sort)
    
    if [ ${#profiles[@]} -eq 0 ]; then echo -e "${RED}Error: No profiles found in '${PROFILES_DIR}/'.${NC}"; exit 1; fi
    
    echo -e "Welcome to Ashno. Please select a profile to begin.\n"
    local count=1
    
    if command -v gum &>/dev/null; then
        local gum_opts=()
        for profile_path in "${profiles[@]}"; do
            local profile_name; profile_name=$(basename "$profile_path")
            case "$profile_name" in
                "1_essentials") gum_opts+=("Essentials") ;;
                "2_extended")   gum_opts+=("Extended (Recommended)") ;;
                "3_complete")   gum_opts+=("Complete") ;;
                *)              gum_opts+=("$profile_name") ;;
            esac
        done
        gum_opts+=("Exit Ashno")
        
        local gum_choice
        gum_choice=$(gum choose --cursor "➜ " --cursor.foreground="212" --item.foreground="250" --selected.foreground="212" --selected.bold "${gum_opts[@]}")
        
        if [ "$gum_choice" == "Exit Ashno" ]; then
            echo -e "\nExiting Ashno."; exit 0
        fi

        # Find matching profile index
        for i in "${!gum_opts[@]}"; do
            if [ "${gum_opts[$i]}" == "$gum_choice" ]; then
                SELECTED_PROFILE=$(basename "${profiles[$i]}")
                break
            fi
        done
    else
        for profile_path in "${profiles[@]}"; do
            local profile_name; profile_name=$(basename "$profile_path")
            local option_line
            case "$profile_name" in
                "1_essentials") option_line=$(printf "  ${CYAN}%2d)${NC} ${BOLD}Essentials${NC}" "$count") ;;
                "2_extended")   option_line=$(printf "  ${CYAN}%2d)${NC} ${BOLD}Extended${NC} ${GREEN}(Recommended)${NC}" "$count") ;;
                "3_complete")   option_line=$(printf "  ${CYAN}%2d)${NC} ${BOLD}Complete${NC}" "$count") ;;
                *)              option_line=$(printf "  ${CYAN}%2d)${NC} ${BOLD}%s${NC}" "$count" "$profile_name") ;;
            esac
            echo -e "$option_line"
            count=$((count + 1))
        done
        printf "  ${CYAN}%2d)${NC} ${BOLD}%s${NC}\n" "$count" "Exit Ashno"
        
        local choice; print_prompt; read choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#profiles[@]} ]; then 
            SELECTED_PROFILE=$(basename "${profiles[$choice-1]}")
        elif [ "$choice" -eq $count ]; then 
            echo -e "\nExiting Ashno."; exit 0
        else 
            echo -e "\n${RED}Invalid selection.${NC}"; sleep 1; profile_selection_menu
        fi
    fi
}
