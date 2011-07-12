---
layout:post
title: recover grub
tags: ["howto"]
---


    grub rescue> set

see what current settings are...

    set prefix=(hd2,1)/boot/grub
    set root=(hd2,1)

    insmod /boot/grub/linux.mod
    linux /vmlinuz root=/dev/sde1 ro
    initrd /initrd.img
    boot
