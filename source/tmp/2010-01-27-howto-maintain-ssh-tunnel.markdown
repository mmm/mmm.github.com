---
layout:post
title: $i
tags: ["howto"]
---

#!/bin/bash

if [ $# -ne 1 ]; then
    echo "$0: Incorrect Arguments"
    echo "Try $0 <port>"
    echo "    where <port> is the port for the local end of the tunnel."
    exit 1
fi

PORT=$1
if ! `/bin/netstat -ln | /bin/grep -q ${PORT}`
then
  /usr/bin/ssh -N -l swhp-mysql-tunnel -i $HOME/.ssh/id_dsa -L${PORT}:localhost:3306 -R${PORT}:localhost:3306 -o ServerAliveInterval=240 swhp@swhp.org &
fi

# ssh -N -l remoteprocess -L13307:127.0.0.1:3306 -R13307:127.0.0.1:3306 -o ServerAliveInterval=240 re.mo.te.ip
#ssh -i $HOME/.ssh/id_dsa -L3307:localhost:3306 swhp@swhp.org

