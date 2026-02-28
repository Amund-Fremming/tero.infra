# Tero Infrastructure

## Expose Local Services (ngrok)

**Setup (once):**

1. Get your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken
2. Add it to `ngrok.yml`

**Start both tunnels:**

```bash
just tunnel
```

Exposes both services with random URLs (shown in terminal):

- Platform: `https://xxxx.ngrok.app` → `localhost:3000`
- Session: `https://yyyy.ngrok.app` → `localhost:9000`

## Production Deployment

```bash
./run.sh
```

**Ports:**

- tero.platform: 3000
- tero.session: 8080

**Commands:**

```bash
docker-compose logs -f
docker-compose restart
docker-compose down
```
