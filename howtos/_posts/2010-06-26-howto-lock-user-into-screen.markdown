---
layout:post
title: lock a user to a screen session
tags: ["howto"]
---


set shell to screen

    kurt:x:505:505::/home/kurt:/usr/bin/screen

with a /home/kurt/.screenrc (perms 644 root.root)

    multiuser off
    escape ^Ee
    bell ''
    startup_message off
    vbell off
    ### enabling scroll buffer
    termcapinfo xterm|xterms|xs|rxvt ti@:te@
    defscrollback         3000
    silencewait           15              # default: 30
    hardstatus string "%h%?"
    ### logging
    logtstamp on
    logfile flush 10
    logtstamp after 300
    ### create windows
    screen -t h             1       /bin/bash
    logfile /var/lib/audit/$USER
    log on

