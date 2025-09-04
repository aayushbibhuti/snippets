#!/bin/bash
# Parse auth.log for invalid SSH login attempts (unique by IP, with port)

LOGFILE="/var/log/auth.log"   # Change to /var/log/secure on CentOS/RHEL

# Print header
printf "%-15s %-15s %-20s %-10s\n" "DATE" "USER" "IP" "PORT"
printf "%-15s %-15s %-20s %-10s\n" "---------------" "---------------" "--------------------" "----------"

# Extract "Invalid user" lines, parse fields, then deduplicate by IP
grep "Invalid user" "$LOGFILE" | while read -r line; do
    DATE="$(echo "$line" | awk '{print $1" "$2" "$3}')"
    USER="$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="user"){print $(i+1);exit}}}')"
    IP="$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1);exit}}}')"
    PORT="$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="port"){print $(i+1);exit}}}')"
    echo -e "$DATE\t$USER\t$IP\t$PORT"
done | awk -F'\t' '!seen[$3]++ {printf "%-15s %-15s %-20s %-10s\n", $1, $2, $3, $4}'

