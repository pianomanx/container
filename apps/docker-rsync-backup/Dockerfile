#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION

FROM alpine:${VERSION}

LABEL maintainer=dockserver
LABEL org.opencontainers.image.source https://github.com/dockserver/docker-rsync-backup

ENV BACKUPDIR="/home" \
  ARCHIVEROOT="/backup" \
  EXCLUDES="/backup_excludes" \
  SSH_PORT="22" \
  SSH_IDENTITY_FILE="/root/.ssh/id_rsa" \
  CRON_TIME="0 1 * * *" \
  LOGS="/log" \
  SET_CONTAINER_TIMEZONE="true" \
  CONTAINER_TIMEZONE="Europe/Berlin" \
  BACKUP_HOLD="15" \
  SERVER_ID="docker" \
  RSYNC_COMPRESS_LEVEL="2" \
  DISCORD_WEBHOOK_URL="" \
  DISCORD_ICON_OVERRIDE="https://i.imgur.com/KorF8zC.png" \
  DISCORD_NAME_OVERRIDE="BACKUP"

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash curl bc findutils coreutils && \
  rm -rf /var/cache/apk/*

COPY ./apps/docker-rsync-backup/docker-entrypoint.sh /usr/local/bin/
COPY ./apps/docker-rsync-backup/backup.sh /backup.sh
RUN chmod +x /backup.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD /backup.sh && crond -f
