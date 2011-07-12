---
layout: post
title: use socat to forward unix sockets over ssh
tags: ["howto"]
---



    socat TCP-LISTEN:5500 EXEC:'ssh root@proteus "socat STDIO UNIX-CONNECT:/var/run/libvirt/qemu/i-437207F5.monitor"'

