# snippets v0.1
# clear hdd logs 
#!/bin/bash

truncate_logs() {
    # Truncate all files in /var/hdd.log and /var/log
    find /var/hdd.log /var/log -type f -exec truncate -s 0 {} +
}

truncate_logs

