#!/bin/bash

set -euo pipefail

: "${INIT_USER:=administrator}"
: "${INIT_PASS:=Admin123!}"
: "${INIT_DC_IP:=192.168.1.1}"

: "${KRB5_realm:=EXAMPLE.LOC}"
: "${KRB5_realm_tolower:=example.loc}"
: "${KRB5_admin:=192.168.1.1}"
: "${KRB5_kdc:=192.168.1.1}"

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


INIT_DIR=/root/docker.d/ads_member
INIT_WORKDIR=${INIT_DIR}/template

#/etc/supervisor
cp ${INIT_WORKDIR}/supervisor/supervisord.conf.template /etc/supervisor/supervisord.conf
cp -pr ${INIT_WORKDIR}/supervisor/conf.d /etc/supervisor/

# /etc/samba/smb.conf
export INIT_USER INIT_PASS SAMBA_interface SAMBA_realm SAMBA_realm_tolower SAMBA_workgroup SAMBA_zone_transfer
SAMBA_realm_tolower=$(echo "${SAMBA_realm}" | tr '[:upper:]' '[:lower:]')
envsubst < ${INIT_WORKDIR}/samba/smb.conf.template > /etc/samba/smb.conf

# /etc/samba/mkHomedir.sh
cp ${INIT_WORKDIR}/samba/mkHomedir.sh /etc/samba/
chmod +x /etc/samba/mkHomedir.sh

#/etc/krb5.conf
export KRB5_realm KRB5_realm_tolower KRB5_admin KRB5_kdc
KRB5_realm_tolower=$(echo "${KRB5_realm}" | tr '[:upper:]' '[:lower:]')
envsubst < ${INIT_WORKDIR}/krb5.conf.template > /etc/krb5.conf

# /srv/samba/share
mkdir -p /srv/samba/share

# /srv/samba/home
mkdir -p /srv/samba/home

net ads join -U "${INIT_USER}"%"${INIT_PASS}"
