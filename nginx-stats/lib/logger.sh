#!/usr/bin/env bash

print_banner() {

echo -e "${CYAN}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                nginx-stats"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RESET}"

}

info() {

echo -e "${BLUE}[INFO]${RESET} $*"

}

success() {

echo -e "${GREEN}[ OK ]${RESET} $*"

}

warn() {

echo -e "${YELLOW}[WARN]${RESET} $*"

}

error() {

echo -e "${RED}[FAIL]${RESET} $*"

exit 1

}