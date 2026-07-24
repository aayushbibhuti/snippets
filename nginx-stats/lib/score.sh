#!/usr/bin/env bash

analyze_abuse() {

[[ -f "$LOG_FILE" ]] || error "Log file not found: $LOG_FILE"
[[ -s "$LOG_FILE" ]] || error "Log file is empty: $LOG_FILE"

local base
base="$(basename "$LOG_FILE" .log)"
local ts
ts=$(date +%Y%m%d-%H%M%S)

local stats_file="$REPORT_DIR/abuse-stats-$base-$ts.txt"
local report_file="$REPORT_DIR/abuse-report-$base-$ts.txt"
local banlist_file="$REPORT_DIR/abuse-banlist-$base-$ts.txt"
local review_file="$REPORT_DIR/abuse-review-$base-$ts.txt"

echo
echo -e "${GREEN}✓${RESET} Scanning for abuse..."
echo

info "Counting lines..."
local total
total=$(wc -l < "$LOG_FILE")

echo
echo "Progress"

local out
out=$(awk \
-v total="$total" \
'
function add(ip, v) {
    score[ip] += v
}

function fmt_num(n, s) {
    s = ""
    while (n >= 1000) {
        if (s == "") s = sprintf("%03d", n % 1000)
        else s = sprintf("%03d,%s", n % 1000, s)
        n = int(n / 1000)
    }
    if (s == "") return n
    return n "," s
}

BEGIN {
    FPAT = "\\[[^]]*\\]|\"[^\"]*\"|[^ ]+"
    bar_width = 50
    last_pct = 0
}

{
    ip = $1
    reqs[ip]++

    status = $6
    if (status == "404") err404[ip]++

    url = $5
    gsub(/^"|"$/, "", url)

    if (url ~ /wp-login|xmlrpc|\.env|phpmyadmin|\.git|HNAP1|cgi-bin|boaform|composer\.json/)
        add(ip, 3)

    if (url ~ /\.\.\//)
        add(ip, 3)

    ua = $9
    gsub(/^"|"$/, "", ua)
    if (ua ~ /[Cc]url|[Pp]ython|Go-http-client|[Ss]qlmap|masscan|zgrab|[Ww]get/)
        add(ip, 2)

    ts_raw = $4
    gsub(/\[/, "", ts_raw)
    split(ts_raw, a, ":")
    sec = a[1] ":" a[2] ":" a[3] ":" a[4]
    key = ip " " sec
    burst[key]++

    if (total > 0) {
        pct = int(NR * 100 / total)
        if (pct > last_pct) {
            last_pct = pct
            bars = int(pct * bar_width / 100)
            printf "\r[" > "/dev/stderr"
            for (b = 0; b < bar_width; b++) {
                if (b < bars) printf "█" > "/dev/stderr"
                else printf " " > "/dev/stderr"
            }
            printf "] %d%%", pct > "/dev/stderr"
        }
    }
}

END {
    printf "\r\033[K" > "/dev/stderr"

    total_reqs = 0
    for (ip in reqs) total_reqs += reqs[ip]
    unique_ips = length(reqs)
    avg = (unique_ips > 0) ? sprintf("%.2f", total_reqs / unique_ips) : 0

    n = asorti(reqs, rkeys, "@val_num_desc")
    p99_idx = int(n * 0.99)
    if (p99_idx < 1) p99_idx = 1
    if (n == 0) p99 = 100
    else p99 = reqs[rkeys[p99_idx]]

    threshold = p99 * 3
    if (threshold < 100) threshold = 100

    for (k in burst) {
        split(k, x, " ")
        if (burst[k] > 20) add(x[1], 2)
    }

    for (ip in reqs) {
        if (reqs[ip] > threshold) add(ip, 4)
        if (err404[ip] > 100) add(ip, 2)
    }

    # Stats section
    print "===STATS==="
    print "=============================="
    print "NGINX TRAFFIC STATISTICS"
    print "=============================="
    print ""
    printf "%-18s %s\n", "Total Requests:", fmt_num(total_reqs)
    printf "%-18s %s\n", "Unique IPs:", fmt_num(unique_ips)
    printf "%-18s %s\n", "Average/IP:", avg
    printf "%-18s %s\n", "99th Percentile:", p99
    print ""
    printf "%-18s %s\n", "Threshold:", threshold " requests"
    print "===STATS==="

    # Report section
    print "===REPORT==="
    print "NGINX Abuse Report"
    print "Threshold: " threshold " requests"
    print ""
    printf "%-18s %-10s %-10s %-10s %-10s\n", \
        "IP", "REQUESTS", "404", "SCORE", "ACTION"

    ni = asorti(score, skeys, "@val_num_desc")
    for (i = 1; i <= ni; i++) {
        ip = skeys[i]
        s = score[ip]
        r = reqs[ip]
        e = err404[ip] + 0

        action = "OK"
        if (s >= 5) {
            action = "BAN"
            print "===BAN===" ip
        } else if (s >= 3) {
            action = "REVIEW"
            print "===REVIEW===" ip
        }

        printf "%-18s %-10s %-10s %-10s %-10s\n", \
            ip, fmt_num(r), fmt_num(e), s, action
    }
    print "===REPORT==="
}
' "$LOG_FILE")

echo

# Parse sections from awk output
local stats
local report
local bans
local reviews

stats=$(echo "$out" | sed -n '/^===STATS===/,/^===STATS===/p' | sed '1d;$d')
report=$(echo "$out" | sed -n '/^===REPORT===/,/^===REPORT===/p' | sed '1d;$d' | grep -v -e '^===BAN===' -e '^===REVIEW===')
bans=$(echo "$out" | grep '^===BAN===' | sed 's/^===BAN===//' || true)
reviews=$(echo "$out" | grep '^===REVIEW===' | sed 's/^===REVIEW===//' || true)

echo "$stats"  > "$stats_file"
echo "$report" > "$report_file"
echo "$bans"   > "$banlist_file"
echo "$reviews" > "$review_file"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}              Abuse Detection Results${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo

cat "$stats_file"
echo
echo "─── Report ───────────────────────────────────────────────────"
echo
cat "$report_file"
echo
echo "─── Files ────────────────────────────────────────────────────"
echo
success "Stats    : $stats_file"
success "Report   : $report_file"
success "Ban list : $banlist_file"
success "Review   : $review_file"

}
