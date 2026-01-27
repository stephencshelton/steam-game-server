FROM ubuntu:22.04

# Set environment variables
ENV STEAM_USER=steam \
    STEAM_HOME=/home/steam \
    STEAMCMD_HOME=/home/steam/steamcmd \
    APP_ID=232250 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates=20240203 \
    curl=7.81.0-1ubuntu1.17 \
    wget=1.21.2-2ubuntu1 \
    lib32gcc-s1=12-20220319-1ubuntu1 \
    lib32stdc++6=12-20220319-1ubuntu1 \
    lib32z1=1:1.2.11.dfsg-2ubuntu9.2 \
    libstdc++6:i386=12-20220319-1ubuntu1 \
    libc6:i386=2.35-0ubuntu3.6 \
    net-tools=1.10.0-1ubuntu3 \
    tini=0.19.0-1 \
    && rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m -s /bin/bash ${STEAM_USER}

# Create directories
RUN mkdir -p ${STEAMCMD_HOME} && \
    mkdir -p ${STEAM_HOME}/serverfiles && \
    chown -R ${STEAM_USER}:${STEAM_USER} ${STEAM_HOME}

# Download and extract SteamCMD
WORKDIR ${STEAMCMD_HOME}
RUN wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
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
