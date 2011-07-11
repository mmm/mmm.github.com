---
layout: post
title: dnsmasq ddwrt
tags: ['howto']
---

todo
- lease times (infinite?)
- maybe remove specified ip addresses?
- find better way to configure dnsmasq from startup?


---

unresolved:

had to add static addresses to /etc/hosts on router and then 

    killall -HUP dnsmasq

need to figure out how to get this working from router reboot!


ok, resolved this...

    nvram set rc_startup="
      echo '10.10.10.2 hawk.mmmhtm.org' >> /etc/hosts
      echo '10.10.10.10 laserjet.mmmhtm.org' >> /etc/hosts
      killall -HUP dnsmasq
    "
    nvram commit
    reboot

