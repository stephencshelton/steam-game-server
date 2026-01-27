# Docker build context

Build directory for the SteamCMD Docker image used by the Helm chart.

## Building locally

```bash
docker build -t ghcr.io/steamservers/steamcmd:latest -f Dockerfile .
```

## Configuration

The Dockerfile installs:

- Ubuntu 22.04 base
- SteamCMD for game server downloads
- Required dependencies (lib32gcc-s1, lib32stdc++6, etc.)
- Python3 for health check endpoints

## Environment Variables

- `STEAM_APP_ID`: The SteamCMD App ID for the game (default: 232250)
- `SERVER_NAME`: Name displayed for the server
- `MAX_PLAYERS`: Maximum player count
- `SERVER_PASSWORD`: Optional server password

## Health Checks

The container includes:

- `/health`: Always returns 200 OK when container is running
- `/ready`: Returns 200 when server is ready, 503 otherwise
