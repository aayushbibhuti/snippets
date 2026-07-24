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