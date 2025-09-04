#!/bin/bash
# Parse auth.log for successful SSH logins

LOGFILE="/var/log/auth.log"   # Change to /var/log/secure on CentOS/RHEL

# Print header
printf "%-15s %-15s %-20s\n" "DATE" "USER" "IP"
printf "%-15s %-15s %-20s\n" "---------------" "---------------" "--------------------"

# Extract "Accepted password" lines and format output
grep "Accepted password" "$LOGFILE" | while read -r line; do
    # Example line format:
    # Sep  5 01:22:15 server sshd[1234]: Accepted password for root from 192.168.1.10 port 54321 ssh2

    DATE="$(echo "$line" | awk '{print $1" "$2" "$3}')"
    USER="$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="for"){print $(i+1);exit}}}')"
    IP="$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1);exit}}}')"

    printf "%-15s %-15s %-20s\n" "$DATE" "$USER" "$IP"
done

