# Caddy Infrastructure

A centralized Caddy reverse proxy infrastructure for managing multiple services with automatic HTTPS, designed to run as a separate service that can proxy to multiple applications.

## Overview

This project provides a standalone Caddy server configuration that:
- Manages SSL/TLS certificates automatically via Let's Encrypt
- Routes traffic to multiple backend services
- Provides a modular configuration system for easy service management
- Includes security headers and best practices
- Supports HTTP/3 (QUIC)

## Prerequisites

- Docker and Docker Compose
- A domain name pointing to your server
- Backend services running on the same Docker network

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone git@github.com:michaelnowotny/caddy-infrastructure.git
   cd caddy-infrastructure
   ```

2. **Create the shared Docker network**:
   ```bash
   docker network create caddy
   ```

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your domain and service details
   ```

4. **Start Caddy**:
   ```bash
   docker compose up -d
   ```

## Project Structure

```
caddy-infrastructure/
├── Caddyfile              # Main Caddy configuration
├── sites/                 # Site-specific configurations
│   ├── fibonacci.caddy    # Example: Fibonacci app config
│   └── example.caddy.template  # Template for new services
├── docker-compose.yml     # Docker Compose configuration
├── .env.example          # Example environment variables
├── .gitignore           # Git ignore rules
├── README.md            # This file
└── scripts/
    └── reload-caddy.sh  # Helper script to reload configuration
```

## Adding a New Service

### Method 1: Using Environment Variables

1. **Copy the template**:
   ```bash
   cp sites/example.caddy.template sites/myservice.caddy
   ```

2. **Edit the configuration**:
   - Replace `SERVICE_` with your service prefix (e.g., `MYAPP_`)
   - Customize the routing rules as needed

3. **Add environment variables to `.env`**:
   ```env
   MYAPP_DOMAIN=myapp.example.com
   MYAPP_HOST=myapp-container
   MYAPP_PORT=8080
   ```

4. **Reload Caddy**:
   ```bash
   docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```

### Method 2: Direct Configuration

Create a new file in `sites/` directory:

```caddyfile
myapp.example.com {
    reverse_proxy myapp-container:8080
    
    header {
        Strict-Transport-Security "max-age=31536000"
        X-Frame-Options "DENY"
    }
}
```

## Connecting Services

Services must be on the same Docker network (`caddy`) to be accessible by Caddy.

### For Docker Compose services:

Add to your service's `docker-compose.yml`:

```yaml
networks:
  default:
    name: caddy
    external: true
```

### For standalone containers:

```bash
docker run --network caddy --name myapp myapp:latest
```

## Configuration Examples

### Basic Service
```caddyfile
myapp.example.com {
    reverse_proxy myapp:8080
}
```

### Service with Path Routing
```caddyfile
myapp.example.com {
    handle_path /api/* {
        reverse_proxy api-service:8000
    }
    
    handle {
        reverse_proxy frontend-service:80
    }
}
```

### Service with Authentication
```caddyfile
admin.example.com {
    basicauth {
        admin $2a$10$... # Generate with: caddy hash-password
    }
    reverse_proxy admin-panel:8080
}
```

## SSL/TLS Certificates

Caddy automatically obtains and renews SSL certificates from Let's Encrypt. Ensure:

1. Your domain points to your server's IP
2. Ports 80 and 443 are accessible
3. `ACME_EMAIL` is set in `.env`

For testing, uncomment the staging CA in `Caddyfile`:
```caddyfile
acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
```

## Monitoring

### Health Check
```bash
curl http://your-server/health
```

### Logs
```bash
# View Caddy logs
docker compose logs -f caddy

# View access logs
docker compose exec caddy tail -f /data/logs/fibonacci.porcupine.works-access.log
```

### Caddy Admin API
If enabled in Caddyfile, access at `http://localhost:2019/`

## Troubleshooting

### Certificate Issues
- Check domain DNS: `dig your-domain.com`
- View Caddy logs: `docker compose logs caddy`
- Ensure ports 80/443 are open in firewall

### Service Not Accessible
- Verify service is on `caddy` network: `docker network inspect caddy`
- Check service is running: `docker ps`
- Test from Caddy container: `docker compose exec caddy wget -O- http://service-name:port`

### Configuration Errors
- Validate Caddyfile: `docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile`
- Check syntax in site configs

## Scripts

### reload-caddy.sh
Reloads Caddy configuration without downtime:
```bash
./scripts/reload-caddy.sh
```

## Security Considerations

- Always use HTTPS in production
- Keep Caddy updated
- Regularly review security headers
- Use strong passwords for any authentication
- Limit exposed ports in firewall

## Integration with Fibonacci API Example

This infrastructure project was extracted from the [fibonacci-api-example](https://github.com/michaelnowotny/fibonacci-api-example) project. To integrate:

1. Set up this Caddy infrastructure
2. Configure Fibonacci services to use external network
3. Add Fibonacci configuration to `sites/fibonacci.caddy`
4. See the Fibonacci project's `CADDY_INTEGRATION.md` for detailed steps

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT