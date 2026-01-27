# Steam Game Server Deployment

A comprehensive solution for deploying Steam-based dedicated game servers on Kubernetes using Helm, with automated Docker image builds and CI/CD pipelines.

## Components

### 1. Helm Chart (`/helm/steam-game-server`)

A production-ready Helm chart for deploying Steam game servers with:

**Features:**
- Configurable persistent storage for game files
- Environment variable configuration
- Server configuration file mounting via ConfigMap
- Game installation via SteamID
- Optional Ingress support with TLS
- Horizontal Pod Autoscaling (HPA)
- Resource limits and requests
- Health check endpoints (`/health` and `/ready`)

**Quick Start:**
```bash
helm install my-game-server ./helm/steam-game-server \
  --set gameServer.steamId=232250
```

**Key Configuration:**
- `gameServer.steamId`: SteamCMD App ID for the game (required)
- `gameServer.env`: Optional environment variables for the server process
- `serverConfigs`: One or more config files to mount in the pod
- `persistence.enabled`: Enable persistent storage
- `persistence.size`: Volume size (default: 50Gi)
- `ingress.enabled`: Enable Ingress for external access

**Customization:**
Edit `values.yaml` to customize:
- Container image and version
- Resource limits
- Storage configuration
- Ingress configuration
- Multiple server configuration files

**Multiple Configuration Files:**
The chart supports mounting multiple configuration files into the pod. All game configuration should be done via config files. Configure them in `serverConfigs`:

```yaml
serverConfigs:
  gameSettings:
    filename: "GameUserSettings.ini"
    mountPath: "/home/steam/gamefiles"
    content: |
      [Settings]
      ServerName=My Server
      MaxPlayers=64
      Difficulty=1.0
  
  advanced:
    filename: "advanced.cfg"
    mountPath: "/home/steam/config"
    content: |
      [Advanced]
      # Advanced settings here
  
  startup:
    filename: "startup.sh"
    mountPath: "/home/steam/scripts"
    content: |
      #!/bin/bash
      # Startup script here
```

Each config file:
- Is stored in a ConfigMap
- Can be mounted at a different path
- Can use Helm templating for dynamic content
- Is mounted as read-only

### 2. Docker Image (`/docker`)

A containerized SteamCMD environment with automatic game server installation.

**Features:**
- Ubuntu 22.04 base
- SteamCMD pre-installed
- Required 32-bit libraries for game servers
- Python-based health check endpoint
- Configurable via environment variables

**Building:**
```bash
docker build -t ghcr.io/steamservers/steamcmd:latest -f docker/Dockerfile .
```

**Environment Variables:**
- `STEAM_APP_ID`: SteamCMD App ID (default: 232250)
- `SERVER_NAME`: Server display name
- `MAX_PLAYERS`: Maximum players
- `SERVER_PASSWORD`: Optional password

**Health Endpoints:**
- `/health`: Returns 200 when container is running
- `/ready`: Returns 200 when server is ready

### 3. GitHub Actions Workflows (`.github/workflows`)

#### `helm-lint.yaml`
- Runs on changes to `helm/` directory
- Performs `helm lint` with strict mode
- Validates YAML syntax with yamllint
- Tests template rendering
- Attempts dry-run deployment

Triggers: Push/PR to main/develop with helm changes

#### `docker-build.yaml`
- Builds and pushes Docker image to GHCR
- Performs vulnerability scanning with Trivy
- Tests image build locally
- Uses GitHub Actions cache for faster builds

Triggers: Push/PR to main/develop with docker changes

#### `steam-update-check.yaml`
- Runs daily (2 AM UTC) via schedule
- Checks for Steam updates
- Automatically rebuilds container image on updates
- Creates GitHub issues for manual tracking

Triggers: Daily schedule or manual workflow_dispatch

#### `lint.yaml`
- YAML linting (yamllint)
- Shell script linting (shellcheck)
- Markdown linting (markdownlint)
- Dockerfile linting (hadolint)

Triggers: Push/PR to main/develop

## Usage Examples

### Deploy a basic server
```bash
helm install ark-server ./helm/steam-game-server \
  --set gameServer.steamId=232250 \
  --set gameServer.serverName="ARK Server" \
  --values custom-values.yaml
```

### Deploy with custom configuration
Create `custom-values.yaml`:
```yaml
gameServer:
  steamId: "258550"  # Valheim
  serverName: "Valheim Server"
  maxPlayers: "10"
  env:
    - name: CUSTOM_VAR
      value: "custom_value"

persistence:
  size: 100Gi
  storageClass: fast-ssd

ingress:
  enabled: true
  hosts:
    - host: valheim.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Check deployment status
```bash
kubectl get pods -l app.kubernetes.io/name=steam-game-server
kubectl logs -f deployment/steam-game-server-release-name
```

## Supported Game Servers

Common Steam App IDs:
- **232250**: ARK: Survival Evolved
- **258550**: Valheim
- **1391110**: RUST
- **1672970**: ARK: Survival Evolved II
- **373310**: Garry's Mod
- **4940**: Team Fortress 2

See [SteamCMD App ID List](https://developer.valvesoftware.com/wiki/Steamworks_SDK) for more.

## CI/CD Pipeline

The repository includes automated:
1. **Helm Chart Validation** - Linting and template verification
2. **Docker Image Builds** - Automated builds to GHCR on changes
3. **Vulnerability Scanning** - Trivy scans for security issues
4. **Code Quality Checks** - YAML, Shell, Markdown, and Dockerfile linting
5. **Steam Update Monitoring** - Daily checks with automatic rebuilds

All workflows can be triggered manually via GitHub Actions interface.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Docker (for building images locally)
- GHCR access (for image registry)

## File Structure

```
steam-game-server/
├── helm/
│   └── steam-game-server/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── pvc.yaml
│           ├── configmap.yaml
│           ├── serviceaccount.yaml
│           ├── hpa.yaml
│           └── _helpers.tpl
├── docker/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── README.md
└── .github/
    └── workflows/
        ├── helm-lint.yaml
        ├── docker-build.yaml
        ├── steam-update-check.yaml
        └── lint.yaml
```

## Security Considerations

- Runs as root in container (required for SteamCMD compatibility)
- Configurable security context in Helm values
- TLS support via Ingress with cert-manager
- Resource limits and requests for stability
- Health checks for monitoring

## Troubleshooting

### Server won't start
Check logs: `kubectl logs -f pod/<pod-name>`

### Persistence issues
Verify PVC status: `kubectl get pvc`

### Build failures
Check workflow logs in GitHub Actions

## Contributing

When modifying:
- Helm charts: Run `helm lint` and test with `helm template`
- Docker image: Build locally and test container startup
- Workflows: Validate YAML syntax

## License

[Add your license here]
