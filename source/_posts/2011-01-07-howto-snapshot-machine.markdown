---
layout: post
title: snapshot machine config
categories: howtos
comments: true
---

A script to capture config info:

    #!/bin/bash

    #as root

    TIME_STAMP=`date +"%G-%m-%d-%H%M%S"`
    RESCUE_DIR="/root/rescue/${TIME_STAMP}"

    mkdir -p ${RESCUE_DIR}

    dpkg --get-selections > "${RESCUE_DIR}/dpkg-selections.out"
    dpkg --get-selections | grep -v deinstall > "${RESCUE_DIR}/dpkg-selections-without-deinstall.out"
    fdisk -l > "${RESCUE_DIR}/fdisk.out"
    df > "${RESCUE_DIR}/df.out"
    mount > "${RESCUE_DIR}/mount.out"
    if [ -f /sbin/iptables-save ]; then
      iptables-save > "${RESCUE_DIR}/iptables.out"
    fi
    if [ -f /usr/bin/gem ]; then
      gem list > "${RESCUE_DIR}/gems.out"
    fi

    cd /var/spool/cron
    tar czvf "${RESCUE_DIR}/crontabs.tar.gz" crontabs

