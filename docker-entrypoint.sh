#!/bin/sh
set -eu

# --- EULA -------------------------------------------------------------------
# Minecraft refuses to start until eula.txt contains eula=true.
# Accept it by starting the container with -e EULA=true.
if [ "${EULA:-false}" = "true" ]; then
    echo "eula=true" > /data/eula.txt
elif [ ! -s /data/eula.txt ]; then
    echo "ERROR: Minecraft EULA not accepted." >&2
    echo "Start the container with -e EULA=true to accept it." >&2
    echo "https://aka.ms/MinecraftEULA" >&2
    exit 1
fi

# --- mods dir -----------------------------------------------------------------
# Server state lives in /data (volume or bind mount). Ensure a mods folder
# exists so jars can be dropped in directly or via a separate mount.
mkdir -p /data/mods

# --- RAM limits ---------------------------------------------------------------
# MEM_MIN / MEM_MAX are plain JVM sizes (512M, 1G, 4G, ...).
exec java \
    -Xms"${MEM_MIN:-1G}" \
    -Xmx"${MEM_MAX:-2G}" \
    -jar /srv/fabric-server-*.jar \
    nogui
