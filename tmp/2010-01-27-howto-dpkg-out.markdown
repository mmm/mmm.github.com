---
layout:post
title: $i
tags: ["howto"]
---


to dump:
    dpkg --get-selections > installed-software

antoehr source says to:
    dpkg --get-selections | grep -v deinstall > installed-software


to restore:
    dpkg --set-selections < installed-software
    dselect
