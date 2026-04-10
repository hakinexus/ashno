#!/bin/bash
# ==============================================================================
# SECTION: POST-INSTALL CONFIGURATION ENGINE
# ==============================================================================

# ─────────────────────────────────────────────────────────────────────
# Helper: Back up an existing file or directory before overwriting
# ─────────────────────────────────────────────────────────────────────
_backup_existing() {
    local path="$1"
    [ ! -e "$path" ] && return 1
    mkdir -p "$ASHNO_BACKUP_DIR"
    local name timestamp dest
    name=$(basename "$path")
    timestamp=$(date +%Y%m%d_%H%M%S)
    dest="${ASHNO_BACKUP_DIR}/${name}.${timestamp}"
    cp -r "$path" "$dest"
    print_formatting info "Backed up → ${dest/#$HOME/~}"
}

# ─────────────────────────────────────────────────────────────────────
# Helper: Styled section header — unique per configurator
# ─────────────────────────────────────────────────────────────────────
_config_header() {
    local label="$1" title="$2" fg="$3" border="${4:-rounded}"
    if command -v gum &>/dev/null; then
        echo ""
        gum style --border "$border" --border-foreground "$fg" \
            --foreground "$fg" --bold \
            --padding "0 3" --margin "0 1" --align center \
            "$label  ·  $title"
        echo ""
    else
        local cc
        case "$fg" in
            39)  cc="$BLUE"   ;; 212) cc="$PURPLE" ;;
            208) cc="$YELLOW" ;; 82)  cc="$GREEN"  ;;
            44)  cc="$CYAN"   ;; 196) cc="$RED"    ;;
            *)   cc="$CYAN"   ;;
        esac
        echo ""
        echo -e " ${cc}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${BOLD}${cc}${label}${NC}  ·  ${title}"
        echo -e " ${cc}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
}

# ─────────────────────────────────────────────────────────────────────
# Helper: Prompt the user to update or keep existing config
# ─────────────────────────────────────────────────────────────────────
_ask_update() {
    local prompt_text="$1"
    if command -v gum &>/dev/null; then
        gum confirm "  $prompt_text" && return 0 || return 1
    else
        read -r -p "  $prompt_text [y/N]: " choice
        case "$choice" in
            [yY]|[yY][eE][sS]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# ==============================================================================
# CONFIGURATOR 1 — ZSH + Oh-My-Zsh                              [Color: Blue 39]
# Border: double | The foundation of the shell experience
# ==============================================================================
configure_zsh() {
    _config_header "SHELL" "ZSH + Oh-My-Zsh Setup" 39 double

    if ! command -v zsh &>/dev/null; then
        print_formatting warn "ZSH is not installed. Skipping."
        CONFIG_SKIPPED_LIST+=("ZSH + Oh-My-Zsh")
        return
    fi

    local omz_dir="$HOME/.oh-my-zsh"
    local omz_installed=false
    [ -d "$omz_dir" ] && omz_installed=true

    # ── Oh-My-Zsh core ──────────────────────────────────────────────
    if [ "$omz_installed" = true ]; then
        print_formatting info "Oh-My-Zsh is already installed."
        if _ask_update "Update Oh-My-Zsh core and refresh plugins?"; then
            echo -en "  Updating Oh-My-Zsh... "
            (cd "$omz_dir" && git pull --quiet) &>/dev/null &
            spinner $!; wait $!
            printf "\r\033[K"
            print_formatting success "Oh-My-Zsh updated."
        fi
    else
        if ! command -v curl &>/dev/null; then
            print_formatting error "curl is required to install Oh-My-Zsh. Skipping."
            CONFIG_SKIPPED_LIST+=("ZSH + Oh-My-Zsh")
            return
        fi
        print_formatting info "Installing Oh-My-Zsh..."
        echo -en "  Downloading... "
        (sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended) &>/dev/null &
        spinner $!; wait $!
        printf "\r\033[K"
        if [ -d "$omz_dir" ]; then
            print_formatting success "Oh-My-Zsh installed."
        else
            print_formatting error "Oh-My-Zsh installation failed."
            CONFIG_SKIPPED_LIST+=("ZSH + Oh-My-Zsh")
            return
        fi
    fi

    # ── Plugins ──────────────────────────────────────────────────────
    local zsh_custom="${ZSH_CUSTOM:-$omz_dir/custom}"
    local plugin_entries=(
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
    )

    for entry in "${plugin_entries[@]}"; do
        local pname="${entry%%|*}"
        local purl="${entry##*|}"
        local pdir="$zsh_custom/plugins/$pname"

        if [ -d "$pdir" ]; then
            echo -en "  Updating ${pname}... "
            (cd "$pdir" && git pull --quiet) &>/dev/null &
            spinner $!; wait $!
            printf "\r\033[K"
            print_formatting success "${pname} up to date."
        else
            echo -en "  Installing ${pname}... "
            git clone --quiet "$purl" "$pdir" &>/dev/null &
            spinner $!; wait $!
            printf "\r\033[K"
            if [ -d "$pdir" ]; then
                print_formatting success "${pname} installed."
            else
                print_formatting error "${pname} failed."
            fi
        fi
    done

    # ── .zshrc ───────────────────────────────────────────────────────
    local write_zshrc=true
    if [ -f "$HOME/.zshrc" ]; then
        if ! _ask_update "Apply Ashno's .zshrc? (Existing config will be backed up)"; then
            write_zshrc=false
            print_formatting info "Keeping existing .zshrc"
        fi
    fi

    if [ "$write_zshrc" = true ]; then
        [ -f "$HOME/.zshrc" ] && _backup_existing "$HOME/.zshrc"
        cat > "$HOME/.zshrc" << 'ASHNO_ZSHRC'
# ─── Ashno ZSH Configuration ────────────────────────────────────────
# github.com/hakinexus/ashno

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    command-not-found
    colored-man-pages
    extract
    z
)

source "$ZSH/oh-my-zsh.sh"

# ── Prompt ───────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── Navigation ───────────────────────────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── Modern CLI ───────────────────────────────────────────────────────
command -v eza  &>/dev/null && alias ls='eza --icons --group-directories-first'
command -v eza  &>/dev/null && alias ll='eza -la --icons --group-directories-first'
command -v eza  &>/dev/null && alias lt='eza --tree --level=2 --icons'
command -v bat  &>/dev/null && alias cat='bat --paging=never'
command -v rg   &>/dev/null && alias grep='rg'
command -v fd   &>/dev/null && alias find='fd'
command -v htop &>/dev/null && alias top='htop'

# ── Git Shortcuts ────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
command -v lazygit &>/dev/null && alias lg='lazygit'

# ── Quick Navigation ─────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ── Safety ───────────────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ── Termux ───────────────────────────────────────────────────────────
alias storage='cd ~/storage'
alias sdcard='cd ~/storage/shared'
alias reload='source ~/.zshrc'
alias cls='clear'

# ── Environment ──────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"

# ── History ──────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# ── fzf Integration ──────────────────────────────────────────────────
[ -f "$PREFIX/share/fzf/key-bindings.zsh" ] && source "$PREFIX/share/fzf/key-bindings.zsh"
[ -f "$PREFIX/share/fzf/completion.zsh" ] && source "$PREFIX/share/fzf/completion.zsh"

# ── Key Bindings ─────────────────────────────────────────────────────
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
ASHNO_ZSHRC
        print_formatting success ".zshrc configured."
    fi

    # ── Default Shell ────────────────────────────────────────────────
    local current_shell
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" != "zsh" ]; then
        if _ask_update "Set ZSH as your default shell?"; then
            chsh -s zsh &>/dev/null
            print_formatting success "Default shell → ZSH (takes effect next session)."
        fi
    else
        print_formatting info "ZSH is already your default shell."
    fi

    CONFIGURED_LIST+=("ZSH + Oh-My-Zsh")
}

# ==============================================================================
# CONFIGURATOR 2 — Starship Prompt                           [Color: Magenta 212]
# Border: rounded | Sleek, modern, cross-shell prompt
# ==============================================================================
configure_starship() {
    _config_header "PROMPT" "Starship Cross-Shell Prompt" 212 rounded

    if ! command -v starship &>/dev/null; then
        print_formatting warn "Starship is not installed. Skipping."
        CONFIG_SKIPPED_LIST+=("Starship Prompt")
        return
    fi

    local config_dir="$HOME/.config"
    local config_file="$config_dir/starship.toml"

    if [ -f "$config_file" ]; then
        if ! _ask_update "Starship is already configured. Apply Ashno's theme?"; then
            print_formatting info "Keeping existing Starship config."
            CONFIG_SKIPPED_LIST+=("Starship Prompt")
            return
        fi
        _backup_existing "$config_file"
    fi

    mkdir -p "$config_dir"
    cat > "$config_file" << 'ASHNO_STAR'
# ─── Ashno Starship Configuration ───────────────────────────────────
# Minimal, informative prompt built for Termux

format = """
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$rust\
$golang\
$java\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"

[directory]
style               = "bold cyan"
truncation_length   = 3
truncate_to_repo    = true

[git_branch]
format = "on [$symbol$branch]($style) "
style  = "bold purple"
symbol = " "

[git_status]
format = '([$all_status$ahead_behind]($style) )'
style  = "bold red"

[python]
format = '[${symbol}(${version})]($style) '
symbol = " "
style  = "yellow"

[nodejs]
format = "[$symbol($version)]($style) "
symbol = " "
style  = "green"

[rust]
format = "[$symbol($version)]($style) "
symbol = " "
style  = "bold red"

[golang]
format = "[$symbol($version)]($style) "
symbol = " "
style  = "bold cyan"

[java]
format = "[$symbol($version)]($style) "
symbol = " "
style  = "bold red"

[cmd_duration]
min_time = 2_000
format   = "[⏱ $duration]($style) "
style    = "bold yellow"

[line_break]
disabled = false
ASHNO_STAR

    print_formatting success "Starship prompt configured."
    print_formatting info "Restart your shell or run 'eval \"\$(starship init zsh)\"' to activate."
    CONFIGURED_LIST+=("Starship Prompt")
}

# ==============================================================================
# CONFIGURATOR 3 — Git                                       [Color: Orange 208]
# Border: thick | Identity, aliases, and sensible defaults
# ==============================================================================
configure_git() {
    _config_header "GIT" "Git Version Control Setup" 208 thick

    if ! command -v git &>/dev/null; then
        print_formatting warn "Git is not installed. Skipping."
        CONFIG_SKIPPED_LIST+=("Git")
        return
    fi

    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null)
    current_email=$(git config --global user.email 2>/dev/null)

    # ── Identity ─────────────────────────────────────────────────────
    local do_identity=true
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        print_formatting info "Current identity: ${current_name} <${current_email}>"
        if ! _ask_update "Reconfigure Git identity?"; then
            do_identity=false
        fi
    fi

    if [ "$do_identity" = true ]; then
        local name email editor

        if command -v gum &>/dev/null; then
            name=$(gum input --placeholder="Your Name" \
                --header="  Full name:" --width=40 \
                --header.foreground="208" --cursor.foreground="208")
            email=$(gum input --placeholder="you@example.com" \
                --header="  Email address:" --width=40 \
                --header.foreground="208" --cursor.foreground="208")
            editor=$(gum choose --header="  Default editor:" \
                --cursor="➜ " --cursor.foreground="208" \
                --selected.foreground="208" \
                "nvim" "vim" "nano" "micro" "emacs")
        else
            read -r -p "  Full name: " name
            read -r -p "  Email: " email
            echo "  Default editor (nvim/vim/nano/micro/emacs):"
            read -r -p "  > " editor
        fi

        [ -n "$name" ]   && git config --global user.name "$name"
        [ -n "$email" ]  && git config --global user.email "$email"
        [ -n "$editor" ] && git config --global core.editor "$editor"

        print_formatting success "Git identity configured."
    fi

    # ── Aliases & Defaults ───────────────────────────────────────────
    local do_aliases=true
    if git config --global alias.lg &>/dev/null; then
        print_formatting info "Ashno's Git aliases are already present."
        if ! _ask_update "Refresh Git aliases and defaults?"; then
            do_aliases=false
        fi
    fi

    if [ "$do_aliases" = true ]; then
        # Shortcuts
        git config --global alias.st "status -sb"
        git config --global alias.lg "log --graph --oneline --all --decorate"
        git config --global alias.co "checkout"
        git config --global alias.br "branch -vv"
        git config --global alias.ci "commit"
        git config --global alias.unstage "reset HEAD --"
        git config --global alias.last "log -1 HEAD --stat"
        git config --global alias.staged "diff --cached"
        git config --global alias.amend "commit --amend --no-edit"

        # Sensible defaults
        git config --global init.defaultBranch "main"
        git config --global pull.rebase true
        git config --global push.autoSetupRemote true
        git config --global core.autocrlf input
        git config --global color.ui auto

        print_formatting success "Git aliases and defaults configured."
    fi

    CONFIGURED_LIST+=("Git")
}

# ==============================================================================
# CONFIGURATOR 4 — Neovim                                     [Color: Green 82]
# Border: normal | Clean editor config with lazy.nvim bootstrap
# ==============================================================================
configure_neovim() {
    _config_header "NVIM" "Neovim Editor Setup" 82 normal

    if ! command -v nvim &>/dev/null; then
        print_formatting warn "Neovim is not installed. Skipping."
        CONFIG_SKIPPED_LIST+=("Neovim")
        return
    fi

    local nvim_dir="$HOME/.config/nvim"
    local init_file="$nvim_dir/init.lua"

    if [ -f "$init_file" ]; then
        if ! _ask_update "Neovim config exists. Apply Ashno's setup? (Existing will be backed up)"; then
            print_formatting info "Keeping existing Neovim config."
            CONFIG_SKIPPED_LIST+=("Neovim")
            return
        fi
        _backup_existing "$nvim_dir"
        rm -rf "$nvim_dir"
    fi

    mkdir -p "$nvim_dir"
    cat > "$init_file" << 'ASHNO_NVIM'
-- ─── Ashno Neovim Configuration ─────────────────────────────────────
-- github.com/hakinexus/ashno
-- Leader: Space | :Lazy to manage plugins | <Space>ff to find files

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Options ─────────────────────────────────────────────────────────
local o = vim.opt
o.number         = true
o.relativenumber = true
o.mouse          = "a"
o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = false
o.incsearch      = true
o.breakindent    = true
o.undofile       = true
o.signcolumn     = "yes"
o.updatetime     = 250
o.timeoutlen     = 300
o.splitright     = true
o.splitbelow     = true
o.cursorline     = true
o.scrolloff      = 10
o.tabstop        = 4
o.shiftwidth     = 4
o.expandtab      = true
o.termguicolors  = true
o.clipboard      = "unnamedplus"
o.list           = true
o.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }
o.inccommand     = "split"

-- ── Bootstrap lazy.nvim ─────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ─────────────────────────────────────────────────────────
require("lazy").setup({

    -- Colorscheme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000,
      config = function()
          require("catppuccin").setup({ flavour = "mocha" })
          vim.cmd.colorscheme("catppuccin")
      end },

    -- Status line
    { "nvim-lualine/lualine.nvim",
      opts = { options = { theme = "catppuccin" } } },

    -- Fuzzy finder
    { "nvim-telescope/telescope.nvim", branch = "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" },
      keys = {
          { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
          { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
          { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      } },

    -- Syntax highlighting
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
      config = function()
          require("nvim-treesitter.configs").setup({
              ensure_installed = {
                  "lua", "python", "javascript", "typescript",
                  "bash", "json", "yaml", "markdown", "html", "css",
              },
              highlight = { enable = true },
              indent    = { enable = true },
          })
      end },

    -- Git indicators
    { "lewis6991/gitsigns.nvim", opts = {} },

    -- Auto pairs
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

    -- Comment toggling  (gcc / gc in visual)
    { "numToStr/Comment.nvim", opts = {} },

    -- Indent guides
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
})

-- ── Keymaps ─────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>",          { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>",          { desc = "Quit" })
map("n", "<Esc>",     "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("n", "<C-h>",     "<C-w>h",              { desc = "Window left" })
map("n", "<C-j>",     "<C-w>j",              { desc = "Window down" })
map("n", "<C-k>",     "<C-w>k",              { desc = "Window up" })
map("n", "<C-l>",     "<C-w>l",              { desc = "Window right" })
ASHNO_NVIM

    print_formatting success "Neovim configured with lazy.nvim + Catppuccin + Telescope."
    print_formatting info "Run 'nvim' once to trigger automatic plugin installation."
    CONFIGURED_LIST+=("Neovim")
}

# ==============================================================================
# CONFIGURATOR 5 — Termux Terminal                              [Color: Cyan 44]
# Border: double | Extra keys, font, terminal behavior
# ==============================================================================
configure_termux() {
    _config_header "TERMUX" "Terminal Configuration" 44 double

    local termux_dir="$HOME/.termux"
    local props_file="$termux_dir/termux.properties"

    # ── termux.properties ────────────────────────────────────────────
    local write_props=true
    if [ -f "$props_file" ]; then
        if ! _ask_update "termux.properties exists. Apply Ashno's terminal config?"; then
            write_props=false
            print_formatting info "Keeping existing termux.properties."
        fi
    fi

    if [ "$write_props" = true ]; then
        [ -f "$props_file" ] && _backup_existing "$props_file"
        mkdir -p "$termux_dir"
        cat > "$props_file" << 'ASHNO_TERMUX'
# ─── Ashno Termux Configuration ─────────────────────────────────────
# Two-row extra keys layout optimized for development

extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

# Vibrate on bell character
bell-character = vibrate

# Dark UI for drawer and dialogs
use-black-ui = true

# Allow external apps to open Termux files
allow-external-apps = true

# Cursor style (block, underline, bar)
terminal-cursor-style = bar

# Cursor blink rate in ms (0 = disabled)
terminal-cursor-blink-rate = 600
ASHNO_TERMUX
        print_formatting success "termux.properties configured."
    fi

    # ── Nerd Font ────────────────────────────────────────────────────
    local install_font=false
    if [ -f "$termux_dir/font.ttf" ]; then
        if _ask_update "A custom font is already installed. Replace with JetBrains Mono Nerd Font?"; then
            install_font=true
        fi
    else
        if _ask_update "Install JetBrains Mono Nerd Font? (~8 MB download, enables icons)"; then
            install_font=true
        fi
    fi

    if [ "$install_font" = true ]; then
        if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
            print_formatting warn "curl and unzip are required for font install. Skipping."
        else
            local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            echo -en "  Downloading JetBrains Mono Nerd Font... "
            (curl -fsSL "$font_url" -o /tmp/ashno_nf.zip) &>/dev/null &
            spinner $!; wait $!
            local dl_exit=$?
            printf "\r\033[K"

            if [ "$dl_exit" -eq 0 ] && [ -f /tmp/ashno_nf.zip ]; then
                local tmp_font_dir
                tmp_font_dir=$(mktemp -d)
                unzip -oq /tmp/ashno_nf.zip -d "$tmp_font_dir" 2>/dev/null
                local font_file
                font_file=$(find "$tmp_font_dir" -name "*Regular*" -name "*.ttf" ! -name "*Propo*" 2>/dev/null | head -1)

                if [ -n "$font_file" ]; then
                    [ -f "$termux_dir/font.ttf" ] && _backup_existing "$termux_dir/font.ttf"
                    mkdir -p "$termux_dir"
                    cp "$font_file" "$termux_dir/font.ttf"
                    print_formatting success "JetBrains Mono Nerd Font installed."
                else
                    print_formatting warn "Could not find font in archive. Skipping."
                fi
                rm -rf "$tmp_font_dir" /tmp/ashno_nf.zip
            else
                print_formatting warn "Font download failed. Skipping."
                rm -f /tmp/ashno_nf.zip
            fi
        fi
    fi

    # ── Reload ───────────────────────────────────────────────────────
    if [ "$write_props" = true ] || [ "$install_font" = true ]; then
        termux-reload-settings 2>/dev/null
        print_formatting info "Terminal settings reloaded."
    fi

    CONFIGURED_LIST+=("Termux Terminal")
}

# ==============================================================================
# CONFIGURATOR 6 — SSH                                         [Color: Red 196]
# Border: thick | Key generation and public key display
# ==============================================================================
configure_ssh() {
    _config_header "SSH" "Secure Shell Key Generation" 196 thick

    if ! command -v ssh-keygen &>/dev/null; then
        print_formatting warn "ssh-keygen is not available. Skipping."
        CONFIG_SKIPPED_LIST+=("SSH Keys")
        return
    fi

    local key_file="$HOME/.ssh/id_ed25519"

    if [ -f "$key_file" ]; then
        print_formatting info "SSH key already exists."
        if ! _ask_update "Generate a new key pair? (Existing key will be backed up)"; then
            # Offer to display existing public key
            if [ -f "${key_file}.pub" ] && _ask_update "Display your existing public key?"; then
                echo ""
                if command -v gum &>/dev/null; then
                    gum style --border rounded --border-foreground 196 \
                        --padding "1 2" --margin "0 1" --foreground 82 \
                        "$(cat "${key_file}.pub")"
                else
                    echo -e "  ${GREEN}$(cat "${key_file}.pub")${NC}"
                fi
                echo ""
            fi
            CONFIG_SKIPPED_LIST+=("SSH Keys")
            return
        fi
        _backup_existing "$key_file"
        _backup_existing "${key_file}.pub"
    fi

    # Use git email if available, otherwise prompt
    local email
    email=$(git config --global user.email 2>/dev/null)

    if [ -z "$email" ]; then
        if command -v gum &>/dev/null; then
            email=$(gum input --placeholder "you@example.com" \
                --header "  Email for SSH key comment:" --width 40 \
                --header.foreground 196 --cursor.foreground 196)
        else
            read -r -p "  Email for SSH key comment: " email
        fi
    fi

    local comment="${email:-ashno@termux}"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    echo -en "  Generating ed25519 key pair... "
    if ssh-keygen -t ed25519 -C "$comment" -N "" -f "$key_file" &>/dev/null; then
        printf "\r\033[K"
        print_formatting success "SSH key pair generated."
        chmod 600 "$key_file"
        chmod 644 "${key_file}.pub"

        echo ""
        if command -v gum &>/dev/null; then
            gum style --foreground 250 --italic --margin "0 2" "Add this public key to GitHub / GitLab / your server:"
            echo ""
            gum style --border rounded --border-foreground 196 \
                --padding "1 2" --margin "0 1" --foreground 82 \
                "$(cat "${key_file}.pub")"
        else
            echo -e "  ${BOLD}Add this public key to GitHub / GitLab / your server:${NC}\n"
            echo -e "  ${GREEN}$(cat "${key_file}.pub")${NC}"
        fi
        echo ""
    else
        printf "\r\033[K"
        print_formatting error "SSH key generation failed."
    fi

    CONFIGURED_LIST+=("SSH Keys")
}

# ==============================================================================
# CONFIGURATION MENU — Tool picker and orchestration
# ==============================================================================
_config_summary() {
    if [ ${#CONFIGURED_LIST[@]} -eq 0 ] && [ ${#CONFIG_SKIPPED_LIST[@]} -eq 0 ]; then
        return
    fi

    echo ""
    if command -v gum &>/dev/null; then
        local header
        header=$(gum style --foreground 222 --bold --align center "━━━  Configuration Complete  ━━━")

        local lines=""
        for item in "${CONFIGURED_LIST[@]}"; do
            lines+="$(gum style --foreground 46 "  ✔  $item")\n"
        done
        for item in "${CONFIG_SKIPPED_LIST[@]}"; do
            lines+="$(gum style --foreground 245 "  ●  $item (skipped)")\n"
        done

        printf "%s\n\n%b" "$header" "$lines" \
            | gum style --border rounded --border-foreground 222 --padding "1 2" --margin "0 1"
    else
        echo -e " ${BOLD}${YELLOW}━━━  Configuration Complete  ━━━${NC}\n"
        for item in "${CONFIGURED_LIST[@]}"; do
            echo -e "  ${GREEN}✔${NC} $item"
        done
        for item in "${CONFIG_SKIPPED_LIST[@]}"; do
            echo -e "  ${YELLOW}●${NC} $item (skipped)"
        done
    fi
    echo ""
}

configure_menu() {
    local available=() labels=()

    command -v zsh       &>/dev/null && { available+=("zsh");      labels+=("ZSH + Oh-My-Zsh  — Shell, plugins, aliases"); }
    command -v starship  &>/dev/null && { available+=("starship"); labels+=("Starship Prompt  — Cross-shell prompt theme"); }
    command -v git       &>/dev/null && { available+=("git");      labels+=("Git Config       — Identity, aliases, defaults"); }
    command -v nvim      &>/dev/null && { available+=("neovim");   labels+=("Neovim Editor    — lazy.nvim + Catppuccin"); }
                                         available+=("termux");    labels+=("Termux Terminal  — Extra keys, font, settings")
    command -v ssh-keygen &>/dev/null && { available+=("ssh");     labels+=("SSH Keys         — Generate ed25519 key pair"); }

    if [ ${#available[@]} -eq 0 ]; then
        print_formatting warn "No configurable tools detected."
        return
    fi

    CONFIGURED_LIST=()
    CONFIG_SKIPPED_LIST=()

    if command -v gum &>/dev/null; then
        echo ""
        gum style --border double --margin "0 1" --padding "0 3" \
            --border-foreground 222 --foreground 222 --bold \
            --align center "⚙  Configure Your Tools"
        gum style --foreground 245 --italic --margin "0 2" \
            "Select and configure your installed development tools."
        echo ""

        local remaining_keys=("${available[@]}")
        local remaining_labels=("${labels[@]}")

        while true; do
            local opts=()
            [ ${#remaining_labels[@]} -gt 0 ] && opts+=("✦ Configure ALL")
            opts+=("${remaining_labels[@]}")
            opts+=("── Done ──")

            local pick
            pick=$(gum choose --cursor="➜ " --cursor.foreground="222" \
                --header="Select a tool to configure:" \
                --header.foreground="250" \
                --selected.foreground="222" --selected.bold \
                "${opts[@]}")

            [ -z "$pick" ] || [ "$pick" = "── Done ──" ] && break

            if [ "$pick" = "✦ Configure ALL" ]; then
                for key in "${remaining_keys[@]}"; do
                    _run_configurator "$key"
                done
                break
            fi

            for i in "${!remaining_labels[@]}"; do
                if [ "${remaining_labels[$i]}" = "$pick" ]; then
                    _run_configurator "${remaining_keys[$i]}"
                    unset 'remaining_keys[$i]' 'remaining_labels[$i]'
                    remaining_keys=("${remaining_keys[@]}")
                    remaining_labels=("${remaining_labels[@]}")
                    break
                fi
            done

            [ ${#remaining_keys[@]} -eq 0 ] && break
        done
    else
        print_banner "⚙  Configure Your Tools"
        echo -e "  Select and configure your installed development tools.\n"
        local i=1
        for label in "${labels[@]}"; do
            echo -e "  ${CYAN}${i})${NC} ${label}"
            i=$((i + 1))
        done
        echo ""
        echo -e "  ${CYAN}a)${NC} ${BOLD}All of the above${NC}"
        echo -e "  ${CYAN}s)${NC} Skip"
        echo ""
        read -r -p "  Enter choices (e.g. 1,3,5 or a): " choices

        if [ "$choices" = "s" ] || [ -z "$choices" ]; then return; fi

        if [ "$choices" = "a" ]; then
            for key in "${available[@]}"; do
                _run_configurator "$key"
            done
        else
            IFS=',' read -ra nums <<< "$choices"
            for num in "${nums[@]}"; do
                num=$(echo "$num" | xargs)
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#available[@]} ]; then
                    _run_configurator "${available[$((num-1))]}"
                fi
            done
        fi
    fi

    _config_summary

    # Hold summary on screen until user acknowledges
    if [ ${#CONFIGURED_LIST[@]} -gt 0 ] || [ ${#CONFIG_SKIPPED_LIST[@]} -gt 0 ]; then
        if command -v gum &>/dev/null; then
            gum style --foreground 245 --italic --margin "0 2" "Press any key to continue..."
        else
            echo -e "  Press any key to continue..."
        fi
        read -n 1 -s -r
    fi
}

_run_configurator() {
    case "$1" in
        zsh)      configure_zsh ;;
        starship) configure_starship ;;
        git)      configure_git ;;
        neovim)   configure_neovim ;;
        termux)   configure_termux ;;
        ssh)      configure_ssh ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────
# Post-install offer — called after installation completes
# ─────────────────────────────────────────────────────────────────────
offer_configuration() {
    echo ""
    if command -v gum &>/dev/null; then
        gum style --foreground 222 --bold --margin "0 1" \
            "⚙  Post-Install Configuration Available"
        echo ""
        if gum confirm "  Set up your tools? (ZSH, Starship, Git, Neovim, etc.)"; then
            configure_menu
        fi
    else
        echo -e "  ${BOLD}${YELLOW}⚙  Post-Install Configuration Available${NC}\n"
        read -r -p "  Set up your tools? (ZSH, Git, Neovim, etc.) [y/N]: " choice
        case "$choice" in
            [yY]|[yY][eE][sS]) configure_menu ;;
        esac
    fi
}
