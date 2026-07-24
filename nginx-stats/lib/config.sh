#!/usr/bin/env bash

load_config() {

CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/config.conf"

[[ -f "$CONFIG" ]] && source "$CONFIG"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="${REPORT_DIR:-$BASE_DIR/reports}"
CACHE_DIR="${CACHE_DIR:-$BASE_DIR/cache}"

mkdir -p "$REPORT_DIR"
mkdir -p "$CACHE_DIR"

}