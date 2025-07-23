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
: "${BIND_allowquery:=any;}"

: "${RSYNCD_server:=192.168.1.1}"
: "${RSYNCD_pass:=samba4_ads}"


INIT_DIR=/root/docker.d/dc_join
INIT_WORKDIR=${INIT_DIR}/template

#/etc/supervisor/supervisord.conf
cp ${INIT_WORKDIR}/supervisord.conf.template /etc/supervisor/supervisord.conf

# /etc/samba/smb.conf
export INIT_USER INIT_PASS INIT_DOMAIN INIT_DOMAIN_FQDN SAMBA_interface SAMBA_realm SAMBA_realm_tolower SAMBA_workgroup SAMBA_zone_transfer
SAMBA_realm=${INIT_DOMAIN_FQDN}
SAMBA_realm_tolower=$(echo "${SAMBA_realm}" | tr '[:upper:]' '[:lower:]')
SAMBA_workgroup=${INIT_DOMAIN}
envsubst < ${INIT_WORKDIR}/samba/smb.conf.template > /etc/samba/smb.conf

#/etc/bind/named.conf
cp ${INIT_WORKDIR}/bind/named.conf.template /etc/bind/named.conf

#/etc/bind/named.conf.options
export BIND_forwarders BIND_allowquery
envsubst < ${INIT_WORKDIR}/bind/named.conf.options.template > /etc/bind/named.conf.options

#/etc/nsswitch.conf
export NSSWITCH_group NSSWITCH_passwd
envsubst < ${INIT_WORKDIR}/nsswitch.conf.template > /etc/nsswitch.conf

#/etc/ntp.conf
cp ${INIT_WORKDIR}/ntp.conf.template /etc/ntp.conf

#/etc/krb5.conf
export KRB5_realm KRB5_realm_tolower KRB5_admin KRB5_kdc
KRB5_realm_tolower=$(echo "${KRB5_realm}" | tr '[:upper:]' '[:lower:]')
envsubst < ${INIT_WORKDIR}/krb5.conf.template > /etc/krb5.conf

# /srv/samba/share
mkdir -p /srv/samba/share

samba-tool domain join ${INIT_DOMAIN_FQDN} DC --dns-backend=BIND9_DLZ --username "${INIT_USER}" --password "${INIT_PASS}"
