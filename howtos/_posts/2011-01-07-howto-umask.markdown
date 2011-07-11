---
layout: post
title: umask
tags: ['howto']
---

Ugh

- make sure umask is not set anywhere
 
    (/etc/login.defs, /etc/profile, /etc/skel/*, ~/.bash* ~/.profile)

- set umask via libpam-umask.  In /etc/pam.d/common-session, 

    session optional pam_umask.so umask=002

