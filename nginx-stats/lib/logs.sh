#!/usr/bin/env bash

find_logs() {

FOUND_LOGS=()

if [[ -n "$LOG_FILE" ]]
then

[[ -f "$LOG_FILE" ]] || error "Log does not exist."

return

fi

info "Searching for nginx logs..."

while IFS= read -r file
do
    FOUND_LOGS+=("$file")
done < <(

find /var/log \
-type f \
\( \
-name "access.log" -o \
-name "*access*.log" -o \
-name "*.access.log" \
\) 2>/dev/null

)

[[ ${#FOUND_LOGS[@]} -gt 0 ]] || error "No logs found."

}

select_log() {

if [[ -n "$LOG_FILE" ]]
then
    return
fi

if [[ ${#FOUND_LOGS[@]} -eq 1 ]]
then

LOG_FILE="${FOUND_LOGS[0]}"

success "Found log"

return

fi

echo

echo "Multiple logs detected"

echo

for i in "${!FOUND_LOGS[@]}"
do

printf "[%d] %s\n" "$((i+1))" "${FOUND_LOGS[$i]}"

done

echo

read -rp "Select log: " choice

LOG_FILE="${FOUND_LOGS[$((choice-1))]}"

[[ -n "$LOG_FILE" ]] || error "Invalid selection."

}

analyze_log() {

[[ -f "$LOG_FILE" ]] || error "Log file not found: $LOG_FILE"
[[ -s "$LOG_FILE" ]] || error "Log file is empty: $LOG_FILE"

echo
echo -e "${GREEN}✓${RESET} Reading log..."
echo

info "Counting lines..."
local total
total=$(wc -l < "$LOG_FILE")

local report_file
report_file="nginx-stats-$(basename "$LOG_FILE" .log)-$(date +%Y%m%d-%H%M%S).txt"

echo

echo "Progress"

awk \
-v total="$total" \
-v top_ips="$TOP_IPS" \
-v top_urls="$TOP_URLS" \
'
function print_divider() {
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
    total_requests = 0
    total_bytes = 0
    if (top_ips == "") top_ips = 20
    if (top_urls == "") top_urls = 20
    bar_width = 50
    last_pct = 0
}

{
    total_requests++

    ip = $1

    req = $5
    gsub(/^"|"$/, "", req)
    n = split(req, rparts, " ")
    method = rparts[1]
    url = (n >= 2 ? rparts[2] : "-")

    status = $6
    bytes = $7
    if (bytes == "-" || bytes == "") bytes = 0
    else bytes = bytes + 0

    ref = $8
    gsub(/^"|"$/, "", ref)
    if (ref == "-") ref = "(direct)"

    ua = $9
    gsub(/^"|"$/, "", ua)
    if (ua == "") ua = "-"

    ips[ip]++
    methods[method]++
    statuses[status]++
    total_bytes += bytes
    urls[url]++
    uas[ua]++
    referrers[ref]++

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

    print ""
    print_divider()
    print "                nginx-stats v0.2"
    print_divider()
    print ""

    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print "Traffic Summary"
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print ""
    printf "%-20s %s\n", "Requests", fmt_num(total_requests)
    printf "%-20s %s\n", "Unique IPs", fmt_num(length(ips))

    bw = total_bytes
    if (bw >= 1073741824)      printf "%-20s %.2f GB\n", "Bandwidth", bw / 1073741824
    else if (bw >= 1048576)    printf "%-20s %.2f MB\n", "Bandwidth", bw / 1048576
    else if (bw >= 1024)       printf "%-20s %.2f KB\n", "Bandwidth", bw / 1024
    else                       printf "%-20s %s B\n",  "Bandwidth", fmt_num(bw)
    print ""

    print "Methods"
    print ""
    nm = asorti(methods, mkeys, "@val_num_desc")
    for (i = 1; i <= nm; i++) {
        k = mkeys[i]
        printf "%-10s %s\n", k, fmt_num(methods[k])
    }
    print ""

    print "Status Codes"
    print ""
    ns = asorti(statuses, skeys, "@val_num_desc")
    for (i = 1; i <= ns; i++) {
        k = skeys[i]
        printf "%-10s %s\n", k, fmt_num(statuses[k])
    }
    print ""

    print "Top IPs"
    print ""
    ni = asorti(ips, ikeys, "@val_num_desc")
    for (i = 1; i <= ni && i <= top_ips; i++) {
        k = ikeys[i]
        printf "%d. %-15s %s\n", i, k, fmt_num(ips[k])
    }
    print ""

    print "Top URLs"
    print ""
    nu = asorti(urls, ukeys, "@val_num_desc")
    for (i = 1; i <= nu && i <= top_urls; i++) {
        k = ukeys[i]
        printf "%d. %s\n     (%s)\n", i, k, fmt_num(urls[k])
    }
    print ""

    print "Top User Agents"
    print ""
    nua = asorti(uas, akeys, "@val_num_desc")
    for (i = 1; i <= nua && i <= top_urls; i++) {
        k = akeys[i]
        printf "%d. %s\n     (%s)\n", i, k, fmt_num(uas[k])
    }
    print ""

    print "Top Referrers"
    print ""
    nr = asorti(referrers, rkeys, "@val_num_desc")
    for (i = 1; i <= nr && i <= top_urls; i++) {
        k = rkeys[i]
        printf "%d. %s\n     (%s)\n", i, k, fmt_num(referrers[k])
    }
    print ""
}
' "$LOG_FILE" > "$REPORT_DIR/$report_file"

cat "$REPORT_DIR/$report_file"

success "Report saved: $REPORT_DIR/$report_file"

}
