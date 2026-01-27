# Quick Start Guide

## Prerequisites
- Kubernetes cluster (1.19+)
- Helm 3.0+
- kubectl configured

## Installation Steps

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/steam-game-server.git
cd steam-game-server
```

### 2. Add the Helm chart repository (if published)
```bash
helm repo add steam-servers https://yourdomain.com/helm
helm repo update
```

Or use local chart:
```bash
cd helm
```

### 3. Create a namespace
```bash
kubectl create namespace game-servers
```

### 4. Install the chart
```bash
helm install ark-server ./steam-game-server \
  --namespace game-servers \
  --set gameServer.steamId=232250 \
  --set gameServer.serverName="My ARK Server" \
  --set gameServer.maxPlayers=64
```

### 5. Check deployment status
```bash
kubectl get pods -n game-servers
kubectl logs -n game-servers -l app.kubernetes.io/name=steam-game-server
```

### 6. Access the server
```bash
# Get the LoadBalancer IP/DNS
kubectl get svc -n game-servers

# Connect in-game using the external IP and port
```

## Common Tasks

### Update server configuration
```bash
helm upgrade ark-server ./steam-game-server \
  --namespace game-servers \
  --set gameServer.maxPlayers=128
```

### Use persistent storage
```bash
helm install ark-server ./steam-game-server \
  --namespace game-servers \
  --set persistence.enabled=true \
  --set persistence.size=100Gi \
  --set persistence.storageClass=your-storage-class
```

### Enable Ingress with TLS
```bash
helm install ark-server ./steam-game-server \
  --namespace game-servers \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=ark.example.com
```

### Uninstall
```bash
helm uninstall ark-server --namespace game-servers
```

## Testing Locally with Docker

### Build the image
```bash
cd docker
docker build -t steamcmd:local .
```

### Run locally
```bash
docker run -it \
  -e STEAM_APP_ID=232250 \
  -e SERVER_NAME="Test Server" \
  steamcmd:local
```

## Troubleshooting

### Pod won't start
```bash
kubectl describe pod <pod-name> -n game-servers
kubectl logs <pod-name> -n game-servers
```

### Storage issues
```bash
kubectl get pvc -n game-servers
kubectl describe pvc <pvc-name> -n game-servers
```

### Network connectivity
```bash
# Check service is running
kubectl get svc -n game-servers

# Verify ports are correct
kubectl get pods -o wide -n game-servers
```

## Next Steps

- Customize `values.yaml` for your specific game server
- Set up persistent storage class
- Configure Ingress for external access
- Enable monitoring and logging
- Set up backup strategy for game files

For more details, see [README.md](../README.md)
