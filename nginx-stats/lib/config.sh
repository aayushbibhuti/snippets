#!/usr/bin/env bash

load_config() {

CONFIG="$SCRIPT_DIR/config/config.conf"

[[ -f "$CONFIG" ]] && source "$CONFIG"

REPORT_DIR="${REPORT_DIR:-$SCRIPT_DIR/reports}"
CACHE_DIR="${CACHE_DIR:-$SCRIPT_DIR/cache}"

mkdir -p "$REPORT_DIR"
mkdir -p "$CACHE_DIR"

}