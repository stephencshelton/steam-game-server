#!/bin/bash
set -e

# Configuration
STEAMCMD="${STEAMCMD_HOME}/steamcmd.sh"
SERVER_FILES="${STEAM_HOME}/serverfiles"
APP_ID="${STEAM_APP_ID}"
START_COMMAND="${START_COMMAND:-}"

echo "Starting SteamCMD update for Steam App ID: $APP_ID"

# Update/install the game (will update if already exists)
$STEAMCMD \
    +@sSteamCmdForcePlatformType linux \
    +login anonymous \
    +app_update "$APP_ID" \
    +quit

echo "Game installation/update complete"
echo "Server files available at: $SERVER_FILES"

if [ -z "$START_COMMAND" ]; then
    echo "ERROR: START_COMMAND not set. Please provide a game server start command."
    exit 1
fi

echo "Starting game server with: $START_COMMAND"
exec bash -c "$START_COMMAND"
