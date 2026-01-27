#!/bin/bash
# Example script to deploy different popular game servers

set -e

NAMESPACE=${NAMESPACE:-game-servers}
RELEASE_NAME=${RELEASE_NAME:-game-server}
CHART_PATH=${CHART_PATH:-./helm/steam-game-server}

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

deploy_server() {
    local game_name=$1
    local steam_id=$2
    local max_players=$3
    local release_name="${RELEASE_NAME}-$(echo $game_name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"

    echo "Deploying $game_name..."
    echo "  Steam ID: $steam_id"
    echo "  Max Players: $max_players"
    echo "  Release: $release_name"
    echo "  Namespace: $NAMESPACE"

    helm upgrade --install $release_name $CHART_PATH \
        --namespace $NAMESPACE \
        --set gameServer.steamId=$steam_id \
        --set gameServer.serverName="$game_name Server" \
        --set gameServer.maxPlayers=$max_players

    echo "✓ $game_name deployed successfully"
    echo ""
}

# Supported games
case "${1:-help}" in
    ark)
        deploy_server "ARK Survival Evolved" "232250" "64"
        ;;
    valheim)
        deploy_server "Valheim" "258550" "10"
        ;;
    rust)
        deploy_server "RUST" "1391110" "256"
        ;;
    csgo)
        deploy_server "Counter-Strike Global Offensive" "740" "64"
        ;;
    gmod)
        deploy_server "Garrys Mod" "373310" "32"
        ;;
    tf2)
        deploy_server "Team Fortress 2" "4940" "32"
        ;;
    help|--help)
        echo "Usage: $0 <game>"
        echo ""
        echo "Supported games:"
        echo "  ark       - ARK: Survival Evolved (232250)"
        echo "  valheim   - Valheim (258550)"
        echo "  rust      - RUST (1391110)"
        echo "  csgo      - Counter-Strike Global Offensive (740)"
        echo "  gmod      - Garry's Mod (373310)"
        echo "  tf2       - Team Fortress 2 (4940)"
        echo ""
        echo "Environment variables:"
        echo "  NAMESPACE    - Kubernetes namespace (default: game-servers)"
        echo "  RELEASE_NAME - Helm release prefix (default: game-server)"
        echo "  CHART_PATH   - Path to Helm chart (default: ./helm/steam-game-server)"
        ;;
    *)
        echo "Unknown game: $1"
        echo "Use '$0 help' for available games"
        exit 1
        ;;
esac
