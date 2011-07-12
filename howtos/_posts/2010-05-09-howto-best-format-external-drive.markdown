---
layout:post
title: best format for external drive
tags: ["howto"]
---


    /dev/sdi1 on /media/Elements type fuseblk (rw,nosuid,nodev,allow_other,default_permissions,blksize=4096)

wtf is fuseblk?
looks like it's fuse's version of an ntfs mount


------------



    hawk():/media/Elements # fdisk -l /dev/sdi

    Disk /dev/sdi: 1000.2 GB, 1000202043392 bytes
    255 heads, 63 sectors/track, 121600 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes
    Disk identifier: 0x00021631

       Device Boot      Start         End      Blocks   Id  System
    /dev/sdi1               1      121601   976758784    7  HPFS/NTFS


------------

some shit on the net about when it's in an fstab, it needs to be ntfs-3g

    /dev/sda1               /mnt/winxp              ntfs-3g user,umask=0000 0 0
    /dev/sda2               /mnt/fat32              vfat    user,umask=0000 0 0


