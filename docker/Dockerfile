FROM ubuntu:22.04

# Set environment variables
ENV STEAM_USER=steam \
    STEAM_HOME=/home/steam \
    STEAMCMD_HOME=/home/steam/steamcmd \
    APP_ID=232250 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    libstdc++6:i386 \
    libc6:i386 \
    net-tools \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m -s /bin/bash ${STEAM_USER}

# Create directories
RUN mkdir -p ${STEAMCMD_HOME} && \
    mkdir -p ${STEAM_HOME}/serverfiles && \
    chown -R ${STEAM_USER}:${STEAM_USER} ${STEAM_HOME}

# Download and extract SteamCMD
RUN cd ${STEAMCMD_HOME} && \
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz && \
    chown -R ${STEAM_USER}:${STEAM_USER} ${STEAMCMD_HOME}

# Copy entrypoint script
COPY --chown=${STEAM_USER}:${STEAM_USER} entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

# Switch to steam user
USER ${STEAM_USER}

WORKDIR ${STEAM_HOME}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use tini as PID 1 to handle signals properly
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/home/steam/entrypoint.sh"]
