#!/bin/bash

INIT_DIR=/root/docker.d/share
INIT_WORKDIR=${INIT_DIR}/reset

#####
# Clean samba
#####
rm -rf /var/lib/samba/*
#rm -rf /var/run/samba/*
#rm -rf /var/cache/samba/*
#rm -rf /var/log/samba/*
rm -rf /etc/samba/*
cp -pr ${INIT_WORKDIR}/samba/etc/* /etc/samba/
cp -pr ${INIT_WORKDIR}/samba/var/* /var/lib/samba/
chgrp winbindd_priv /var/lib/samba/winbindd_privileged
chgrp sambashare /var/lib/samba/usershares

#####
# Clean bind
#####
rm -rf /etc/bind/*
cp -pr ${INIT_WORKDIR}/bind /etc/

#####
# Clean supervisor
#####
rm -rf /etc/supervisor/*
cp -pr ${INIT_WORKDIR}/supervisor /etc/

#####
# Clean krb5
#####
cp -pr ${INIT_WORKDIR}/krb5.conf /etc/

#####
# Clean nsswitch
#####
cp -pr ${INIT_WORKDIR}/nsswitch.conf /etc/

#####
# Clean ntp
#####
cp -pr ${INIT_WORKDIR}/ntp.conf /etc/

#####
# Clean cron
#####
rm -rf /etc/cron.d/sysvol-replication

#####
# Clean users
#####
rm -rf /var/lib/extrausers/*
