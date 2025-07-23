#!/bin/bash
set -e

# Variáveis configuráveis por ambiente
USER_NAME=${1:-smbuser}
USER_PASS=${2:-smbpass}
USER_UID=${3:-10000}
USER_GID=${4:-10000}

# Diretórios para libnss-extrausers
EXTRA_DIR="/var/lib/extrausers"
mkdir -p "$EXTRA_DIR"

touch "$EXTRA_DIR/passwd" "$EXTRA_DIR/group" "$EXTRA_DIR/shadow"

chmod 600 "$EXTRA_DIR/shadow"

# Garantir UID e GID únicos e consistentes
if ! grep -q "^${USER_NAME}:" "$EXTRA_DIR/passwd"; then
    echo "${USER_NAME}:x:${USER_UID}:${USER_GID}::/nonexistent:/usr/sbin/nologin" >> "$EXTRA_DIR/passwd"
    echo "${USER_NAME}:!:19000:0:99999:7:::" >> "$EXTRA_DIR/shadow"
    echo "${USER_NAME}:x:${USER_GID}:" >> "$EXTRA_DIR/group"
fi

# Criar utilizador Samba
(echo "$USER_PASS"; echo "$USER_PASS") | smbpasswd -a -s "$USER_NAME"
smbpasswd -e "$USER_NAME"
