#!/bin/bash
#v0.1

# Define the path to the Nginx access log file
log_file="/var/log/nginx/access.log"

# Check if the log file exists
if [ ! -f "$log_file" ]; then
  echo "Error: The access log file '$log_file' does not exist."
  exit 1
fi

# Extract IP addresses and count distinct ones
distinct_ips=$(awk '{print $1}' "$log_file" | sort | uniq)

# Count the number of distinct IP addresses
count=$(echo "$distinct_ips" | wc -l)

# Print the result
echo "Number of distinct IP addresses in '$log_file': $count"
