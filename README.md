<div align="center">

# Ashno

**The Definitive Toolkit Installer & Configurator for Termux**

<br>

<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.9.5-222.svg?style=for-the-badge&logo=github&logoColor=white">
  <img alt="Platform" src="https://img.shields.io/badge/Termux-Android-34a853?style=for-the-badge&logo=android&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-a371f7?style=for-the-badge">
</p>
<p>
  <img alt="Bash" src="https://img.shields.io/badge/Pure_Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white">
  <img alt="Maintained" src="https://img.shields.io/badge/maintained-yes-58a6ff?style=flat-square">
  <img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-e3b341?style=flat-square">
</p>

<br>

Install 200+ packages, configure your shell, editor, prompt, and terminal &mdash; all from one command.

<br>
</div>

---

## Why Ashno

Setting up Termux properly means installing dozens of packages across three managers, configuring ZSH, Starship, Git, Neovim, SSH keys, terminal properties, and a Nerd Font. Most people follow 10 different guides and spend hours getting it right.

Ashno does all of it in minutes. Pick a profile, let it install, then configure everything interactively. One tool, complete setup, zero guesswork.

---

## Features

| | |
|:--|:--|
| **Profile-Driven Install** | Curated package tiers across `pkg`, `npm`, and `pip`. Pick a tier &mdash; Ashno installs everything below it automatically. |
| **Configuration Engine** | Interactive post-install setup for ZSH + Oh-My-Zsh, Starship prompt, Git, Neovim (lazy.nvim), Termux properties, Nerd Font, and SSH keys. |
| **Smart & Idempotent** | Detects already-installed packages and skips them. Safe to re-run at any time. |
| **Timeout Protection** | Per-package install timeouts prevent source-compilation hangs from stalling the entire run. |
| **Self-Updating** | Pulls the latest version from GitHub, detects local changes, and restarts cleanly. |
| **Gum-Enhanced UI** | Styled menus, spinners, and prompts powered by [gum](https://github.com/charmbracelet/gum) with full ASCII fallback. |

---

## Quick Start

**One-line install** &mdash; clones the repo, sets permissions, and makes `ashno` available globally:

```bash
bash -c "$(curl -fsSL https://gist.githubusercontent.com/hakinexus/7df8c6853d98b2f7de95e92d5446765d/raw/d877e0568d53c30e27b4a59ef088b02175f7c748/Install.sh)"
```

**Manual clone** &mdash; for contributors or those who want to inspect the code first:

```bash
git clone https://github.com/hakinexus/ashno.git
cd ashno && ./ashno
```

---

## Usage

### Interactive Mode

```bash
ashno
```

Launches the full interactive menu &mdash; select a profile, choose what to install, then optionally configure your tools.

### Non-Interactive Mode

```bash
ashno --profile 2_extended --all    # Install everything from the Extended tier
ashno --profile 1_essentials --pkg  # Install only pkg packages from Essentials
ashno --configure                   # Open the configuration menu directly
ashno --update                      # Check for and apply updates
```

### All Flags

| Flag | Short | Description |
|:-----|:------|:------------|
| `--profile <NAME>` | | Select a profile tier by directory name |
| `--all` | | Install all package types (pkg + npm + pip) |
| `--pkg` | | Install only pkg packages |
| `--npm` | | Install only npm packages |
| `--pip` | | Install only pip packages |
| `--configure` | `-c` | Open the tool configuration menu |
| `--update` | `-u` | Check for and apply Ashno updates |
| `--help` | `-h` | Display the help manual |

---

## Profiles

Profiles live in the `profiles/` directory. Each tier is **cumulative** &mdash; selecting a higher tier automatically includes every package from the tiers below it.

### `1_essentials`

The foundation. Core shell tools, compilers, languages, networking, and editors.

<details>
<summary>Highlights</summary>

- **Shell & CLI**: zsh, fish, starship, eza, bat, fd, zoxide, htop, tmux
- **Languages**: Python, Node.js, Go, Rust, Zig, Ruby, Perl, PHP, Java, Dart, Nim
- **Dev Tools**: git, lazygit, gh, build-essential, clang, cmake
- **Editors**: nano, vim, neovim, emacs, micro
- **Networking**: openssh, curl, wget, nmap, tcpdump, whois, dnsutils
- **NPM**: yarn, pnpm, webpack, typescript, eslint, prettier, express, react
- **PIP**: pandas, scikit-learn, django, flask, fastapi, scrapy, ansible, jupyter

</details>

### `2_extended`

Everything in Essentials, plus specialized tools for developers, security researchers, and power users.

<details>
<summary>Highlights</summary>

- **Databases**: MariaDB, PostgreSQL, SQLite, Redis
- **Security**: hydra, sqlmap, radare2, hashcat, tshark, proxychains-ng
- **Data**: jq, yq, pandoc, imagemagick, ffmpeg
- **System**: fzf, ripgrep, ctags, procs, bottom, glances
- **NPM**: jest, mocha, vite, nx, turbo, serverless, vercel
- **PIP**: httpx, aiohttp, poetry, pydantic, celery, ruff, scapy, jupyterlab

</details>

### `3_complete`

The full arsenal. Everything from both tiers below, plus expert-level tools.

<details>
<summary>Highlights</summary>

- **Reverse Engineering**: gdb, strace, binwalk, sleuthkit, yara
- **Cryptography**: gnupg, john, steghide
- **Languages**: Lua, OCaml, Clojure, Haskell, Fennel
- **Cloud & DevOps**: k9s, kubectl, helm, terraform
- **NPM**: truffle, hardhat, firebase-tools, cordova, @ionic/cli
- **PIP**: boto3, google-cloud-storage, pyspark, dask, polars, capstone, biopython

</details>

### Custom Profiles

Create your own:

```
profiles/
  my_setup/
    pkg.list    # one package per line, # for comments
    npm.list
    pip.list
```

Ashno discovers custom profiles automatically and shows them in the selection menu.

---

## Configuration Engine

After installation, Ashno offers to configure your tools interactively. Each configurator detects existing setups and asks before making changes. Existing files are backed up to `~/.ashno-backup/` with timestamps.

Access it anytime:

```bash
ashno --configure
```

### What It Configures

| Tool | What Ashno Does |
|:-----|:----------------|
| **ZSH + Oh-My-Zsh** | Installs oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting. Writes a `.zshrc` with modern aliases (eza, bat, fd, rg, lazygit), fzf integration, history config, and key bindings. Sets ZSH as default shell. |
| **Starship** | Drops a `starship.toml` with language-aware segments (Python, Node, Rust, Go, Java), git status, and command duration timer. |
| **Git** | Interactive prompts for name, email, and editor. Adds 9 aliases (`st`, `lg`, `co`, `br`, `ci`, `unstage`, `last`, `staged`, `amend`) and sensible defaults (rebase pull, auto-setup remote). |
| **Neovim** | Bootstraps lazy.nvim with Catppuccin Mocha, lualine, Telescope, Treesitter (10 languages), gitsigns, autopairs, Comment.nvim, and indent guides. |
| **Termux** | Writes `termux.properties` with a two-row extra keys layout, bar cursor, dark UI. Optionally downloads and installs JetBrains Mono Nerd Font for icon support. |
| **SSH** | Generates an ed25519 key pair, uses your Git email as the comment, and displays the public key for easy copy to GitHub/GitLab. |

---

## Architecture

```
ashno                  Entry point — routes to interactive or CLI flow
src/
  config.sh            Global constants, colors, state arrays
  utils.sh             UI helpers, spinners, gum bootstrap, signal traps
  engine.sh            Package installer — batch-then-fallback with timeouts
  menus.sh             Profile selection, main menu, help, summary report
  updater.sh           Git-based self-update with branch detection
  configure.sh         Post-install configuration engine (6 configurators)
profiles/
  1_essentials/        pkg.list, npm.list, pip.list
  2_extended/          pkg.list, npm.list, pip.list
  3_complete/          pkg.list, npm.list, pip.list
```

**Key design patterns:**

- **Cumulative profile merging** &mdash; selecting tier N merges all `.list` files from tiers 1 through N, deduplicated and sorted
- **Batch-then-sequential fallback** &mdash; packages install as a batch first; on failure, falls back to one-by-one with per-package status tracking
- **Per-package timeouts** &mdash; prevents source-compilation hangs (5 min per package, 10 min for batch) using GNU `timeout`
- **Gum with ASCII fallback** &mdash; every UI component checks for `gum` and degrades gracefully to plain terminal output
- **Config backup before overwrite** &mdash; all existing dotfiles backed up to `~/.ashno-backup/` with timestamps before any changes

---

## Contributing

Contributions are welcome. Fork the repo, create a feature branch (`feature/your-feature`), and open a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

MIT &mdash; see [LICENSE](LICENSE) for details.

---

<div align="center">
<br>
<sub>Built for Termux by <a href="https://github.com/hakinexus">hakinexus</a></sub>
<br><br>
</div>
