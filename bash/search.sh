# Snippets v0.1
#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <filename/pattern>"
  exit 1
fi

# Argument is the filename or pattern to search for
search_term=$1

# Use find to search the entire filesystem
echo "Searching for '$search_term' in the entire filesystem..."

# Start searching from the root directory
find / -type f -name "$search_term" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "Search completed. Results listed above."
else
  echo "No results found or an error occurred during search."
fi
