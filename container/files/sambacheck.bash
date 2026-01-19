#!/bin/bash
# As we found out sometimes clients are not able to reconnect
# to the samba server if exactly the same machine was previously
# connected but did no clean disconnect.
# This script will disconnect samba clients we can not ping to
# fix this issue. It is meant to be run with cron every 1 minute
data=$(smbstatus -S -j | jq -r '.tcons[] | "\(.machine) \(.server_id.pid)"' | grep '192.168.124')
#data=$(smbstatus -S -j | jq -r '.tcons[] | "\(.machine) \(.server_id.pid)"')
# first item is ip second item is pid
# e.g.
# 192.168.124.155 48392

# Check if data is empty
if [[ -z "$data" ]]; then
    echo "No clients connected."
    exit 0
fi

while read -r ip pid; do
    # Skip if pid is empty
    if [[ -z "$pid" ]]; then
        continue
    fi

    echo "Checking $ip (PID: $pid)..."
    for attempt in {1..5}; do
            if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
                echo "✅ $ip is reachable"
                break
            else
                if [ "$attempt" -lt 5 ]; then
                        echo "attempt: $attempt"
                        sleep 3
                        continue
                fi
                echo "❌ $ip is NOT reachable. Killing client with IP $ip using smbcontrol..."
                smbcontrol smbd kill-client-ip $ip
            fi
    done
done <<< "$data"