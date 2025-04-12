#!/bin/bash

# Display the number of currently logged-in users
echo "Currently logged-in users: $(who | wc -l)"

# List details of each logged-in user
echo -e "\nUser Log Details:\n"

while read -r line; do
    # Extract username, terminal, login time, and IP address from 'who' command output
    username=$(echo "$line" | awk '{print $1}')
    terminal=$(echo "$line" | awk '{print $2}')
    login_time=$(echo "$line" | awk '{print $3, $4}')
    ip_address=$(echo "$line" | awk '{print $5}')
    groups=$(id -nG "$username")
    home_dir=$(eval echo "~$username")
    uid=$(id -u "$username")
    # Display the log details
    echo "Username: $username"
    echo "Terminal: $terminal"
    echo "Login Time: $login_time"
    echo "IP Address: $ip_address"
    echo "Home Directory: $home_dir"
    echo "Groups: $groups"
    echo "UID: $uid"
    echo ""
done < <(who)

