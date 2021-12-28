#!/bin/sh

if [[ "${CRON_TIME}" == "" ]];then
    CRON_TIME="0 1 * * *"
fi

echo "${CRON_TIME} /backup.sh" >/crontab.conf
crontab /crontab.conf

# Generate ssh keys if needed
if [ ! -f "${SSH_IDENTITY_FILE}" ]; then
  install -d "$(dirname "${SSH_IDENTITY_FILE}")"
  ssh-keygen -q -trsa -b2048 -N "" -f "${SSH_IDENTITY_FILE}"
  printf "\nSSH keys generated at %s. Public key:\n\n" "${SSH_IDENTITY_FILE}"
  cat "${SSH_IDENTITY_FILE}.pub"
  printf "\n"
fi

# Create backup excludes file by splitting the EXCLUDES variable
if [[ ! -f "/backup_excludes" ]]; then
  touch /backup_excludes
fi
IFS=';'
for exclude in ${EXCLUDES}; do
  echo "${exclude}" >>/backup_excludes

done
exec "$@"
