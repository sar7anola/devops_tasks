# Docker Compose Configuration - Spring Petclinic with Nginx

## Overview
This Docker Compose setup deploys a Spring Petclinic application with Nginx as a reverse proxy.

## Quick Start
```bash
docker-compose up -d
```
Access the application at: http://localhost:88

## Configuration Details

### Services
| Service | Description | Port |
|---------|-------------|------|
| **petclinic** | Spring Petclinic app | Internal only |
| **nginx** | Reverse proxy & load balancer | 88:80 |

### Networks
- **petclinic-net**: Custom network for service communication

### Volumes
- **petclinic-logs**: Persistent log storage at `/app/logs`

### Environment Variables
- `SPRING_PROFILES_ACTIVE=default`
- `LOGGING_FILE_PATH=/app/logs`

## Files Structure
```
.
├── docker-compose2.yml    # Main configuration
├── Dockerfile            # Petclinic image build
├── nginx.conf            # Nginx configuration
└── README.md            # This file
```

## Commands
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
