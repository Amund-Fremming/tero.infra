# Tero Infrastructure

Production server infrastructure for Tero platform services.

## Quick Start

1. **Configure tero.platform**:

   ```bash
   cd ../tero.platform
   cp .env.example .env
   # Edit .env and fill in all environment variables:
   # - Database URL (external managed PostgreSQL)
   # - Auth0 settings
   # - Server configuration
   ```

2. **Configure tero.session**:

   ```bash
   cd ../tero.session
   # Edit appsettings.json or appsettings.production.json
   # Configure:
   # - PlatformApi base URL
   # - Any additional session service settings
   ```

3. **Start services**:
   ```bash
   cd ../tero.infra
   ./run.sh
   ```

That's it! The script will build images and start both services.

## What's Running

- **tero-platform** (port 3000) - Rust/Axum backend API
- **tero-session** (port 8080) - C#/ASP.NET session service

Services use their own configuration files. Database should be externally managed.

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop all
docker-compose down

# Rebuild
./build.sh
```

## Requirements

- Docker and Docker Compose
- Service repos at `../tero.session` and `../tero.platform`
- Configured `../tero.platform/.env` with production database URL
