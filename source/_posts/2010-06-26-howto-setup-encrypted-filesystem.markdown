---
layout: post
title: setup encrypted fs
categories: howtos
comments: true
---


    dd if=/dev/urandom of=testfile bs=1M count=10
    sudo losetup /dev/loop0 testfile 

    sudo cryptsetup create crypto /dev/loop0

(asks for passphrase)

    sudo mkfs.ext2 /dev/mapper/crypto 
    sudo mount /dev/mapper/crypto /crypt/

    sudo umount /crypt/
    sudo cryptsetup remove /dev/mapper/crypto 






works a little differently with an actual partition... guess it would be

    sudo cryptsetup create crypto /dev/sdb1

(asks for passphrase)

    sudo mkfs.ext2 /dev/mapper/crypto 
    sudo mount /dev/mapper/crypto /crypt/

    sudo umount /crypt/
    sudo cryptsetup remove /dev/mapper/crypto 


-----

this seems to keep the video intact for the most part...  i.e.,

cp Entourage.S06E11.HDTV.XviD-NoTV.avi ~/Documents

    560  ls -al
    561  sudo losetup /dev/loop0 Entourage.S06E11.HDTV.XviD-NoTV.avi -o 10000000
    562  sudo cryptsetup create entourage /dev/loop0
    563  sudo mkfs.xfs /dev/mapper/entourage 
    564  ls /crypt/
    565  sudo mount /dev/mapper/entourage /crypt/
    566  ls /crypt/
    567  ls -al
    568  ls /crypt/
    569  ls /crypt/ -al
    570  cd /crypt/
    571  ls
    572  cp /home/mmm/Desktop/junk.odb .
    573  sudo cp /home/mmm/Desktop/junk.odb .
    574  sudo chown mmm.mmm junk.odb 
    575  ls -al
    576  cd /
    577  cd
    578  cd Documents/
    579  ls
    580  ls -al
    581  vlc Entourage.S06E11.HDTV.XviD-NoTV.avi 
    582  ls
    583  mount
    584  sudo umount /crypt/
    585  sudo cryptsetup remove /dev/mapper/entourage 
    586  sudo losetup -d /dev/loop0 
    587  sudo losetup 
    588  sudo losetup -a
    589  ls
    590  history 

