#!/bin/bash

set -euo pipefail

: "${INIT_USER:=administrator}"
: "${INIT_PASS:=Admin123!}"
: "${INIT_DOMAIN:=EXAMPLE}"
: "${INIT_DOMAIN_FQDN:=EXAMPLE.LOC}"
: "${INIT_DC_IP:=192.168.1.1}"

: "${KRB5_realm:=EXAMPLE.LOC}"
: "${KRB5_realm_tolower:=example.loc}"

: "${SAMBA_interface:=eth0}"
: "${SAMBA_realm:=EXAMPLE.loc}"
: "${SAMBA_realm_tolower:=example.loc}"
: "${SAMBA_workgroup:=EXAMPLE}"
: "${SAMBA_zone_transfer:=all}"

: "${NSSWITCH_passwd:=winbind}"
: "${NSSWITCH_group:=winbind}"

: "${BIND_forwarders:=8.8.8.8; 8.8.4.4;}"
: "${BIND_allow-query:=any;}"

: "${RSYNCD_server:=192.168.1.1}"
: "${RSYNCD_pass:=samba4_ads}"


INIT_DIR=/root/docker.d/user
INIT_WORKDIR=${INIT_DIR}/template

# /etc/samba/smb.conf
export INIT_USER INIT_PASS INIT_DOMAIN INIT_DOMAIN_FQDN SAMBA_interface SAMBA_realm SAMBA_realm_tolower SAMBA_workgroup SAMBA_zone_transfer
SAMBA_realm=${INIT_DOMAIN_FQDN}
SAMBA_realm_tolower=$(echo "${SAMBA_realm}" | tr '[:upper:]' '[:lower:]')
SAMBA_workgroup=${INIT_DOMAIN}
envsubst < ${INIT_WORKDIR}/samba/smb.conf.template > /etc/samba/smb.conf

# /srv/samba/share
mkdir -p /srv/samba/share

#/etc/nsswitch.conf
export NSSWITCH_group NSSWITCH_passwd NSSWITCH_shadow
envsubst < ${INIT_WORKDIR}/nsswitch.conf.template > /etc/nsswitch.conf

# create user and assign permission
${INIT_DIR}/adduser.sh smbuser smbpass 10000 10000
chown smbuser:smbuser /srv/samba/share
chmod 770 /srv/samba/share

