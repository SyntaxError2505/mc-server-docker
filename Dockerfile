# Minecraft (Fabric) server image.
# All mutable state lives in /data (a volume); the image only carries the
# launcher jar and the entrypoint.
FROM eclipse-temurin:25-jre

# RAM limits (JVM flags), overridable at runtime with -e
ENV MEM_MIN=1G \
    MEM_MAX=2G \
    EULA=false

COPY fabric-server-*.jar /srv/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod 755 /usr/local/bin/docker-entrypoint

# Fabric launcher downloads server.jar + libraries/ into its working dir,
# Minecraft writes world data, configs and logs next to them.
WORKDIR /data

# Everything needed across restarts/crashes lives here:
# world/, server.properties, eula.txt, ops.json, whitelist.json,
# banned-players.json, banned-ips.json, usercache.json, logs/,
# libraries/, server.jar, fabric-server-launch.jar, mods/, config/
#
# You can also mount a real host folder (or a second volume) over /data/mods
# to manage mods as plain files:   -v /path/on/host/mods:/data/mods
VOLUME /data

EXPOSE 25565

# exec'd java is PID 1: `docker stop` sends SIGTERM straight to the JVM,
# which saves the world and exits cleanly.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
