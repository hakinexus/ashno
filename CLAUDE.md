# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ashno is a modular, profile-driven toolkit installer for Termux. It batch-installs packages via pkg, npm, and pip using cumulative profile tiers, with both interactive (menu-driven) and non-interactive (CLI flags) modes.

## Running

```bash
./ashno                              # Interactive mode
./ashno --profile 2_extended --all   # Non-interactive: all package managers
./ashno --profile 1_essentials --pkg # Non-interactive: pkg only
./ashno --update                     # Self-update via git
./ashno --help                       # Help menu
```

There are no tests, linters, or build steps. The project is pure Bash.

## Architecture

**Entry point**: `ashno` — sources all modules, routes to interactive or non-interactive flow.

**Source modules** (`src/`):
- `config.sh` — Global paths, color codes, state arrays (`SUCCESS_LIST`, `FAILURE_LIST`, `SKIPPED_LIST`)
- `utils.sh` — UI helpers (banners, badges, spinners), `gum` bootstrap, signal traps
- `engine.sh` — Core installer: builds cumulative package lists, pre-flight checks, batch install with sequential fallback
- `menus.sh` — Profile selection, main action menu, summary report
- `updater.sh` — Git-based self-update with local-change detection and script restart

**Profiles** (`profiles/`): Cumulative tiers — selecting tier N merges all `.list` files from tiers 1 through N. Each tier directory contains `pkg.list`, `npm.list`, `pip.list` (one package per line, comments with `#`).

## Key Design Patterns

- **Cumulative profile merging**: `build_package_list()` in engine.sh reads all profiles with numeric prefix ≤ selected tier, deduplicates and sorts
- **Batch-then-fallback**: Packages install as a batch first; on failure, falls back to one-by-one with per-package status tracking
- **Gum-enhanced UI with ASCII fallback**: All UI components check for `gum` availability and degrade gracefully
- **Idempotent installs**: Already-installed packages are detected and skipped (dpkg + apt-get virtual package check)
- **Self-update restarts**: After `git pull`, the script re-execs itself with original args

## Conventions

- Bash only — no external scripting languages
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) (e.g., `feat:`, `fix:`)
- Branch naming: `feature/Name` or `fix/Name`
