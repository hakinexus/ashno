#!/bin/bash
# ==============================================================================
# SECTION: GLOBALS AND CONFIGURATION
# ==============================================================================

# Ensure SCRIPT_DIR is already exported or available.
# It is defined in the main entrypoint: readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

readonly PROFILES_DIR="$SCRIPT_DIR/profiles"
readonly LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="" 

# --- ANSI Color Codes ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m';
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m';
NC='\033[0m'; BOLD='\033[1m';

# --- State-Tracking Variables ---
SUCCESS_LIST=()
FAILURE_LIST=()
SKIPPED_LIST=()
SELECTED_PROFILE=""
