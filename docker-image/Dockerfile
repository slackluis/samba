FROM debian:bookworm-slim

# Adiciona metadados opcionais
LABEL maintainer="slackluis"

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root/docker.d

# Atualiza o sistema e instala pacotes necessários
RUN apt-get update && apt-get install -y --no-install-recommends \
    samba \
    samba-ad-provision \
    samba-ad-dc \
    samba-dsdb-modules \
    ldb-tools \
    tdb-tools \
    winbind \
    krb5-user \
    supervisor \
    nano \
    iputils-ping \
    iproute2 \
    procps \
    smbclient \
    supervisor \
    psmisc \
    netcat-traditional \
    gettext-base \
    coreutils \
    ntp \
    bind9 \
    rsync \
    cron \
    libnss-extrausers \
    libnss-winbind \
    libpam-winbind \
    dnsutils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Expõe as portas SMB
EXPOSE 53 53/udp 88 88/udp 123/udp 135 137/udp 138/udp 139 389 389/udp 445 464 464/udp 636 3268 3269 49152-65535

#VOLUME /etc/bind
#VOLUME /etc/samba
#VOLUME /etc/supervisor
#VOLUME /var/lib/samba
#VOLUME /srv

RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

RUN mkdir -p /srv/samba

RUN mkdir -p /root/docker.d
COPY docker.d/ /root/docker.d

RUN chmod +x /root/docker.d/share/reset.sh
RUN chmod +x /root/docker.d/share/setup.sh
RUN chmod +x /root/docker.d/share/start.sh

RUN chmod +x /root/docker.d/user/reset.sh
RUN chmod +x /root/docker.d/user/setup.sh
RUN chmod +x /root/docker.d/user/start.sh
RUN chmod +x /root/docker.d/user/adduser.sh

RUN chmod +x /root/docker.d/dc_provision/reset.sh
RUN chmod +x /root/docker.d/dc_provision/setup.sh
RUN chmod +x /root/docker.d/dc_provision/start.sh

RUN chmod +x /root/docker.d/dc_join/reset.sh
RUN chmod +x /root/docker.d/dc_join/setup.sh
RUN chmod +x /root/docker.d/dc_join/start.sh

RUN chmod +x /root/docker.d/ads_member/reset.sh
RUN chmod +x /root/docker.d/ads_member/setup.sh
RUN chmod +x /root/docker.d/ads_member/start.sh


HEALTHCHECK --interval=5s --timeout=3s --retries=60 \
  CMD nc -z localhost 445 || exit 1
