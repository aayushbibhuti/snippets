#!/bin/bash

LOGFILE="/var/log/auth.log"

printf "%-16s %-20s %-16s %-6s\n" "DATE" "USER" "IP" "PORT"
printf "%-16s %-20s %-16s %-6s\n" "----------------" "--------------------" "----------------" "------"

awk '
/Invalid user/ {
    date=$1" "$2" "$3

    user=""
    ip=""
    port=""

    for(i=1;i<=NF;i++){
        if($i=="user") user=$(i+1)
        if($i=="from") ip=$(i+1)
        if($i=="port") port=$(i+1)
    }

    if(!(ip in seen)){
        seen[ip]=1
        printf "%-16s %-20s %-16s %-6s\n", date,user,ip,port
    }
}
' "$LOGFILE"