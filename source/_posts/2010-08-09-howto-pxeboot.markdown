---
layout: post
title: pxeboot
categories: howtos
comments: true
---

# dhcpd config

    apt-get install dhcp3-server

edit dhcpd.conf... to add

    ddns-update-style none;
    option domain-name "blah.blah";
    option domain-name-servers 10.128.92.32, 10.129.92.32;
    default-lease-time 600;
    max-lease-time 7200;
    log-facility local7;

    subnet 10.67.93.0 netmask 255.255.255.0 {
      host moe {
        hardware ethernet 00:14:4F:49:E5:DA;
        fixed-address 10.67.93.5;
        filename "pxelinux.0";
        next-server 10.67.93.13;
        option subnet-mask 255.255.255.0;
        option routers 10.67.93.1;
      }
    }



# tftpd config

    apt-get install tftp-hpa tftpd-hda

copy from ubuntu dist to /srv/tftp

    lrwxrwxrwx 1 root root   33 2010-06-04 09:44 pxelinux.0 -> ubuntu-installer/amd64/pxelinux.0
    lrwxrwxrwx 1 root root   35 2010-06-04 09:44 pxelinux.cfg -> ubuntu-installer/amd64/pxelinux.cfg
    dr-xr-xr-x 3 root root 4096 2010-06-04 09:44 ubuntu-installer
    -r--r--r-- 1 root root   58 2010-06-04 09:44 version.info


# apache config

    apt-get install apache2 

unpack install image into /var/www/ubuntu/

    root@rory:/var/www/ubuntu-10.04# ls -al
    total 176
    dr-xr-xr-x 10 root root   4096 2010-04-27 05:56 .
    drwxr-xr-x  3 root root   4096 2010-06-04 09:11 ..
    -r-xr-xr-x  1 root root   1115 2010-04-23 21:29 cdromupgrade
    dr-xr-xr-x  2 root root   4096 2010-04-27 05:55 .disk
    dr-xr-xr-x  3 root root   4096 2010-04-27 05:55 dists
    dr-xr-xr-x  3 root root   4096 2010-04-27 05:55 doc
    dr-xr-xr-x  3 root root   4096 2010-04-27 05:56 install
    dr-xr-xr-x  2 root root   4096 2010-04-27 05:56 isolinux
    -r--r--r--  1 root root 129953 2010-04-27 05:56 md5sum.txt
    dr-xr-xr-x  2 root root   4096 2010-04-27 05:55 pics
    dr-xr-xr-x  3 root root   4096 2010-04-27 05:55 pool
    dr-xr-xr-x  2 root root   4096 2010-04-27 05:55 preseed
    -r--r--r--  1 root root    235 2010-04-27 05:55 README.diskdefines
    lrwxrwxrwx  1 root root      1 2010-04-27 05:55 ubuntu -> .


