---
layout:post
title: $i
tags: ["howto"]
---


Creating a new encrypted filesystem
$ mkdir /tmp/crypt-raw
$ mkdir /tmp/crypt
$ encfs /tmp/crypt-raw /tmp/crypt
Volume key not found, creating new encrypted volume.
...
Password: [password entered here]
Verify: [password entered here]




Acessing the filesystem



$ cd /tmp/crypt
$ echo "hello foo" > foo
$ echo "hello bar" > bar 
$ ln -s foo foo2
$ ls -l
total 8
-rw-r--r-- 1 vgough users 10 2003-11-03 21:44 bar
-rw-r--r-- 1 vgough users 6 2003-11-03 21:44 foo
lrwxrwxrwx 1 vgough users 7 2003-11-03 21:44 foo2 -> foo
$ cd /tmp/crypt-raw
$ ls -l
total 8
-rw-r--r-- 1 vgough users 6 2003-11-03 21:44 eEM4YfA
-rw-r--r-- 1 vgough users 10 2003-11-03 21:44 gKP4xn8
lrwxrwxrwx 1 vgough users 7 2003-11-03 21:44 i7t9-m,I -> eEM4YfA
$ umount /tmp/crypt
You can also just eject the mount from Finder instead of using umount command.


