#!/bin/bash
if [ -f "/etc/scripts/init-flag" ]||[[ ${SKIP_INIT} -eq 1 ]]; then
    echo "Executing first-time initial task..."
    bash /etc/scripts/init-code
    rm -rf /etc/scripts/init-flag
fi
echo "Starting code-server..."
bash /etc/scripts/long-run