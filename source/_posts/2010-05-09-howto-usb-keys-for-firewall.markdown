---
layout: post
title: use usb keys for openmicroserver firewalls
categories: howtos
comments: true
---


backup image in `~/etc/arch/machine-backups/korek-xxxxxxxx.tar.gz`


    ganymede:~/etc/arch/machine-backups # fdisk -l /dev/sdc

    Disk /dev/sdc: 2029 MB, 2029518848 bytes
    255 heads, 63 sectors/track, 246 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes
    Disk identifier: 0xc3072e18

       Device Boot      Start         End      Blocks   Id  System
    /dev/sdc1               1         208     1670728+  83  Linux
    /dev/sdc2             209         246      305235   82  Linux swap / Solaris
    ganymede:~/etc/arch/machine-backups # 


