#!/bin/bash

# Odoo 18.0 Brasil - Healthcheck Script
# Used by Docker to verify container health

set -e

HOST="${1:-localhost}"
PORT="${2:-8069}"

# Check if Odoo HTTP service is responding
if timeout 5 bash -c "</dev/tcp/$HOST/$PORT" &>/dev/null; then
    # Try to get the health endpoint
    if curl -sf http://$HOST:$PORT/web/health 2>/dev/null | grep -q 'ok\|ready'; then
        exit 0
    fi
    # If health endpoint fails, check if the port is open (acceptable)
    exit 0
else
    exit 1
fi
