# Samba AD DC Service 

## Purpose


## Pulling the Container

[Docker Hub](https://hub.docker.com/repository/docker/slackluis/samba)

```bash
docker pull slackluis/samba:latest
```

## Usage


## Config


## Building from Source

```bash
DOCKER_TAG=0.1

docker rmi slackluis/samba:${DOCKER_TAG}
docker build -t slackluis/samba:${DOCKER_TAG} .
```

## Docker Compose

```YAML
services:


  smbshare:
    container_name: smbshare
    image: slackluis/samba:0.1
    hostname: smbshare
    #network_mode: host
    privileged: true
    
    working_dir: /root/docker.d/share
    stdin_open: true
    tty: true

    mem_limit: 256m

    environment:
       - TZ=Europe/Lisbon
       
       - SAMBA_workgroup=WORKGROUP
       - SAMBA_interface=eth0
       - SAMBA_zone_transfer=all
       
    volumes:
      - /srv/smb/docker/smbshare/samba/etc:/etc/samba
      - /srv/smb/docker/smbshare/samba/var:/var/lib/samba
      - /srv/smb/docker/smbshare/share:/srv/samba/share

    #command: ["/bin/bash", "-c", "tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./reset.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./setup.sh && tail -f /dev/null"]
    command: ["/bin/bash", "-c", "./start.sh"]
    
    cap_add:
      - CAP_FOWNER      
    restart: unless-stopped
    #restart: on-failure:3

    networks:
      LAN:
        ipv4_address: 192.168.40.51

  smbuser:
    container_name: smbuser
    image: slackluis/samba:0.1
    hostname: smbuser
    #network_mode: host
    privileged: true
    
    working_dir: /root/docker.d/user
    stdin_open: true
    tty: true

    mem_limit: 256m
    
    environment:
       - TZ=Europe/Lisbon
       
       - SAMBA_workgroup=WORKGROUP
       - SAMBA_interface=eth0
       - SAMBA_zone_transfer=all

       - NSSWITCH_passwd=extrausers
       - NSSWITCH_group=extrausers
       - NSSWITCH_shadow=extrausers
       
       - USER_NAME=smbuser
       - USER_PASS=smbpass
       - USER_UID=10000
       - USER_GID=10000
       
    volumes:
      - /srv/smb/docker/smbuser/samba/etc:/etc/samba
      - /srv/smb/docker/smbuser/samba/var:/var/lib/samba
      - /srv/smb/docker/smbuser/extrausers:/var/lib/extrausers
      - /srv/smb/docker/smbuser/share:/srv/samba/share

    #command: ["/bin/bash", "-c", "tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./reset.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./setup.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./adduser.sh smbuser2 smbpass2 10001 10001"]
    command: ["/bin/bash", "-c", "./start.sh"]

    cap_add:
      - CAP_FOWNER
    restart: unless-stopped
    #restart: on-failure:3

    networks:
      LAN:
        ipv4_address: 192.168.40.52

  
  smbdcprovision:
    container_name: smbdcprovision
    image: slackluis/samba:0.1
    hostname: smbdcprovision
    #network_mode: host
    privileged: true
    
    working_dir: /root/docker.d/dc_provision
    stdin_open: true
    tty: true

    mem_limit: 765m

    environment:
       - TZ=Europe/Lisbon
       - INIT_USER=administrator
       - INIT_PASS=Container_AD
       - INIT_DC_IP=192.168.40.53
       
       - SAMBA_workgroup=EXAMPLE
       - SAMBA_realm=EXAMPLE.LOC
       - SAMBA_interface=eth0
       - SAMBA_zone_transfer=all
       
       #- KRB5_CONFIG=/etc/samba/krb5.conf
       - KRB5_realm=EXAMPLE.LOC
       - KRB5_admin=192.168.40.53
       - KRB5_kdc=192.168.40.53

       - NSSWITCH_passwd=winbind
       - NSSWITCH_group=winbind
       
       - BIND_forwarders=8.8.8.8; 8.8.4.4;
       - BIND_allow-query:=any

       #- RSYNCD_server=192.168.40.55
       - RSYNCD_pass=samba4_ads
    volumes:
      - /srv/smb/docker/smbdcprovision/samba/etc:/etc/samba
      - /srv/smb/docker/smbdcprovision/samba/var:/var/lib/samba
      - /srv/smb/docker/smbdcprovision/share:/srv/samba/share
      - /srv/smb/docker/smbdcprovision/bind:/etc/bind
      
    #command: ["/bin/bash", "-c", "tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./reset.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./setup.sh && tail -f /dev/null"]
    command: ["/bin/bash", "-c", "./start.sh"]

    cap_add:
      - CAP_FOWNER
    restart: unless-stopped
    #restart: on-failure:3

    dns:
      - 192.168.40.53
      #- 192.168.40.54
    dns_search:
      - example.loc
    extra_hosts:
      - "SMBDCPROVISION.example.loc SMBDCPROVISION:192.168.40.53"
      - "SMBDCJOIN.example.loc SMBDCJOIN:192.168.40.54"

    networks:
      LAN:
        ipv4_address: 192.168.40.53

  smbdcjoin:
    container_name: smbdcjoin
    image: slackluis/samba:0.1
    hostname: smbdcjoin
    #network_mode: host
    privileged: true
    
    working_dir: /root/docker.d/dc_join
    stdin_open: true
    tty: true

    mem_limit: 765m

    environment:
       - TZ=Europe/Lisbon

       - INIT_USER=administrator
       - INIT_PASS=Container_AD
       - INIT_DC_IP=192.168.40.53
       
       - SAMBA_workgroup=EXAMPLE
       - SAMBA_realm=EXAMPLE.LOC
       - SAMBA_interface=eth0
       - SAMBA_zone_transfer=all

       - KRB5_realm=EXAMPLE.LOC
       - KRB5_admin=192.168.40.53
       - KRB5_kdc=192.168.40.53

       - NSSWITCH_passwd=winbind
       - NSSWITCH_group=winbind
       
       - BIND_forwarders=8.8.8.8; 8.8.4.4;
       - BIND_allow-query:=any

       - RSYNCD_server=192.168.40.53
       - RSYNCD_pass=samba4_ads

    volumes:
      - /srv/smb/docker/smbdcjoin/samba/etc:/etc/samba
      - /srv/smb/docker/smbdcjoin/samba/var:/var/lib/samba
      - /srv/smb/docker/smbdcjoin/share:/srv/samba/share
      - /srv/smb/docker/smbdcjoin/bind:/etc/bind


    #command: ["/bin/bash", "-c", "tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./reset.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./setup.sh && tail -f /dev/null"]
    command: ["/bin/bash", "-c", "./start.sh"]

    cap_add:
      - CAP_FOWNER
    restart: unless-stopped
    #restart: on-failure:3

    dns:
      #- 192.168.40.53 # ./setup.sh
      - 192.168.40.54 # ./start.sh
    dns_search:
      - example.loc
    
    extra_hosts:
      - "SMBDCPROVISION.example.loc SMBDCPROVISION:192.168.40.53"
      - "SMBDCJOIN.example.loc SMBDCJOIN:192.168.40.54"
    networks:
      LAN:
        ipv4_address: 192.168.40.54

    depends_on:
       - smbdcprovision


  smbadsmember:
    container_name: smbadsmember
    image: slackluis/samba:0.1
    hostname: smbadsmember
    privileged: true
    
    working_dir: /root/docker.d/ads_member
    stdin_open: true
    tty: true

    mem_limit: 512m

    environment:
       - TZ=Europe/Lisbon
       
       - INIT_USER=administrator
       - INIT_PASS=Container_AD
       - INIT_DC_IP=192.168.40.53
       
       - SAMBA_workgroup=EXAMPLE
       - SAMBA_realm=EXAMPLE.LOC
       - SAMBA_interface=eth0
       #- SAMBA_zone_transfer=all

       - KRB5_realm=EXAMPLE.LOC
       - KRB5_admin=192.168.40.53
       - KRB5_kdc=192.168.40.53

       - NSSWITCH_passwd=winbind
       - NSSWITCH_group=winbind

    volumes:
      - /srv/smb/docker/smbadsmember/samba/etc:/etc/samba
      - /srv/smb/docker/smbadsmember/samba/var:/var/lib/samba
      - /srv/smb/docker/smbadsmember/share:/srv/samba/share
      - /srv/smb/docker/smbadsmember/home:/srv/samba/home
    
    #command: ["/bin/bash", "-c", "tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./reset.sh && tail -f /dev/null"]
    #command: ["/bin/bash", "-c", "./setup.sh && tail -f /dev/null"]
    command: ["/bin/bash", "-c", "./start.sh"]

    
    cap_add:
      - CAP_FOWNER
    restart: unless-stopped
    #restart: on-failure:3

    dns:
      - 192.168.40.53
      - 192.168.40.54
    dns_search:
      - example.loc

    extra_hosts:
      - "SMBDCPROVISION.example.loc SMBDCPROVISION:192.168.40.53"
      - "SMBDCJOIN.example.loc SMBDCJOIN:192.168.40.54"
      - "SMBADSMEMBER.example.loc SMBADSMEMBER:192.168.40.55"
    networks:
      LAN:
        ipv4_address: 192.168.40.55

    depends_on:
       - smbdcjoin

networks:
  LAN:
    external: true
```


## Additional Info

