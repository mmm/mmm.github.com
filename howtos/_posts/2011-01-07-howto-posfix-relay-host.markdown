---
layout: post
title: setup postfix to relay through google apps
tags: ['howto']
---

## Install / Configure a Relay-only mail host on ec2


Install postfix

    apt-get install postfix mailutils

stop the service

    /etc/init.d/postfix stop

Edit /etc/postfix/master.cf and change

    smtp      inet  n       -       -       -       -       smtpd

to

    #smtp      inet  n       -       -       -       -       smtpd

    
Edit /etc/postfix/main.cf and change

    myhostname = ip-10-127-126-193.ec2.internal
    alias_maps = hash:/etc/aliases
    alias_database = hash:/etc/aliases
    myorigin = /etc/mailname
    mydestination = mysub.mydom.com, ip-10-127-126-193.ec2.internal, localhost.ec2.internal, localhost
    relayhost =
    mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
    mailbox_size_limit = 0
    recipient_delimiter = +
    inet_interfaces = all

to

    myhostname = mysub.mydom.com
    alias_maps = hash:/etc/aliases
    alias_database = hash:/etc/aliases
    myorigin = /etc/mailname
    mydestination = mysub.mydom.com, localhost.mydom.com, ip-10-127-126-193.ec2.internal, localhost.ec2.internal, localhost
    relayhost = mydom.com
    mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
    mailbox_size_limit = 0
    recipient_delimiter = +
    inet_interfaces = all
    local_transport = error:local delivery disabled

Restart postfix

    /etc/init.d/postfix restart

test with mail

    root@ip-10-127-126-193:/etc/postfix# mail dixon@mydom.com
    Cc: 
    Subject: Mims testing from root@mysub.mydom.com to dixon@mydom.com 201012120753
    .
    .
    <Ctrl-D>

