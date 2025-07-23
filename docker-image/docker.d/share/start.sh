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


INIT_DIR=/root/docker.d/share
INIT_WORKDIR=${INIT_DIR}/template

#/etc/supervisor/supervisord.conf
cp ${INIT_WORKDIR}/supervisord.conf.template /etc/supervisor/supervisord.conf

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
