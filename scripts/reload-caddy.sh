#!/bin/bash
# Reload Caddy configuration without downtime

set -e

echo "Validating Caddy configuration..."
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile

if [ $? -eq 0 ]; then
    echo "Configuration is valid. Reloading Caddy..."
    docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
    echo "Caddy reloaded successfully!"
else
    echo "Configuration validation failed. Please check your Caddyfile."
    exit 1
fi