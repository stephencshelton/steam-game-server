# Steam Game Server Deployment

A production-ready Helm chart for deploying Steam-based dedicated game servers on
Kubernetes, with support for any SteamCMD game, persistent storage, and
configuration management.

## Features

- **Generic**: Deploy any Steam game server via SteamCMD
- **Configurable**: Game-specific configuration via ConfigMaps
- **Persistent**: Optional persistent storage for game files
- **Auto-scaling**: Horizontal Pod Autoscaling (HPA) support
- **Secure**: RBAC, SecurityContext, and optional Ingress with TLS
- **Observable**: Health checks and readiness probes

## Quick Start

```bash
helm install my-server ./helm/steam-game-server \
  --set gameServer.steamId=232250 \
  --set gameServer.startCommand="/home/steam/serverfiles/binary"
```

## Configuration

### Required Values

- `gameServer.steamId`: Steam App ID (e.g., 232250 for ARK)
- `gameServer.startCommand`: Command to launch the server

### Optional Values

- `gameServer.env`: Additional environment variables
- `serverConfigs`: Game configuration files to mount
- `persistence.enabled`: Enable persistent storage
- `persistence.size`: Storage size (default: 50Gi)
- `ingress.enabled`: Enable Ingress for external access

## Server Configuration Files

Mount game configuration files via ConfigMaps:

```yaml
serverConfigs:
  gameSettings:
    filename: "config.ini"
    mountPath: "/home/steam/serverfiles"
    content: |
      [Settings]
      difficulty=1
      maxPlayers=10
```

## Examples

Example configurations are provided for:

- ARK: Survival Evolved
- Valheim
- Rust
- 7 Days to Die

See `examples/values-*.yaml` for details.

## Deployment

### Basic Deployment

```bash
helm install game-server ./helm/steam-game-server \
  -f examples/values-ark.yaml
```

### With Persistent Storage

```bash
helm install game-server ./helm/steam-game-server \
  -f examples/values-ark.yaml \
  --set persistence.enabled=true \
  --set persistence.size=100Gi
```

### Check Status

```bash
kubectl get pods -l app.kubernetes.io/name=steam-game-server
kubectl logs -l app.kubernetes.io/name=steam-game-server -f
```

## ArgoCD Deployment

An ArgoCD Application manifest is provided in `examples/argocd-app-7dtd.yaml`:

```bash
kubectl apply -f examples/argocd-app-7dtd.yaml
```

Enable automatic DNS hostname via external-dns annotations.

## CI/CD

### Workflows

- **helm-lint**: Validates Helm chart syntax and template rendering
- **lint**: YAML and Markdown linting

## Troubleshooting

### Server Won't Start

Check the startCommand value and ensure the binary exists at the specified path.

### Persistence Issues

Verify the PVC is created and mounted correctly:

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

### Build Failures

Run `helm lint` locally to validate the chart:

```bash
helm lint helm/steam-game-server/
helm template my-release helm/steam-game-server/
```

## License

MIT
