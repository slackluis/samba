#!/bin/bash

set -euo pipefail

: "${INIT_USER:=administrator}"
: "${INIT_PASS:=Admin123!}"
: "${INIT_DOMAIN:=EXAMPLE}"
: "${INIT_DOMAIN_FQDN:=EXAMPLE.LOC}"
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


INIT_DIR=/root/docker.d/dc_join
INIT_WORKDIR=${INIT_DIR}/template

#/etc/supervisor
cp ${INIT_WORKDIR}/supervisor/supervisord.conf.template /etc/supervisor/supervisord.conf
cp -pr ${INIT_WORKDIR}/supervisor/conf.d /etc/supervisor/

#/etc/krb5.conf
export KRB5_realm
KRB5_realm_tolower=$(echo "${KRB5_realm}" | tr '[:upper:]' '[:lower:]')
envsubst < ${INIT_WORKDIR}/krb5.conf.template > /etc/krb5.conf

#/etc/nsswitch.conf
export NSSWITCH_group NSSWITCH_passwd
envsubst < ${INIT_WORKDIR}/nsswitch.conf.template > /etc/nsswitch.conf

#/etc/ntp.conf
cp ${INIT_WORKDIR}/ntp.conf.template /etc/ntp.conf

#/etc/cron/cron.d/sysvol-replication
export RSYNCD_server
envsubst <  ${INIT_WORKDIR}/cron/cron.d/sysvol-replication.template > /etc/cron.d/sysvol-replication

#/etc/samba/rsync.secret
export RSYNCD_pass
envsubst < ${INIT_WORKDIR}/samba/rsync.secret.template > /etc/samba/rsync.secret
chmod 600 /etc/samba/rsync.secret

#/var/log/ntpsec
mkdir -p /var/log/ntpsec
chown ntpsec:ntpsec /var/log/ntpsec

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
