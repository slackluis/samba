#!/bin/bash

#getent_passwd=$(getent passwd | grep ${1})

#homedir=$($(echo "${getent_passwd}" | cut -d ':' -f 6))
homedir=$(dirname "$(eval echo ~${1})")

#pgid=$(echo "${getent_passwd}" | cut -d ':' -f 4)
#pgid=$(id -g ${1})

if [ -e ${homedir}/${1} ]; then
  exit 0
fi

mkdir -p ${homedir}
mkdir -p ${homedir}/${1}
#cp -pr /etc/skel ${homedir}/${1}
chown -R ${1} ${homedir}/${1}
#chgrp -R ${pgid} ${homedir}/${1}
chmod -R 0700 ${homedir}/${1}
