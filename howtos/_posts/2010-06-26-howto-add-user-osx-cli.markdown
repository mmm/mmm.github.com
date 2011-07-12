---
layout: post
title: add user in osx from the cli
tags: ['howto']
---

totally fucking ridiculous!

    bipp-dcd:/Users root# niutil -create / /users/markv
    bipp-dcd:/Users root# niutil -create / /groups/markv
    bipp-dcd:/Users root# niutil -createprop / /users/markv uid 504
    bipp-dcd:/Users root# niutil -createprop / /groups/markv gid 504
    bipp-dcd:/Users root# niutil -createprop / /users/markv gid 504
    bipp-dcd:/Users root# niutil -createprop / /users/markv realname "Mark Vaughan"
    bipp-dcd:/Users root# niutil -createprop / /users/markv shell "/bin/bash"      
    bipp-dcd:/Users root# niutil -createprop / /users/markv home "/Users/markv"
    bipp-dcd:/Users root# cp -R /System/Library/User\ Template/English.lproj /Users/markv
    bipp-dcd:/Users root# chown -Rf markv:markv /Users/markv
    bipp-dcd:/Users root# passwd markv


also

    niutil -appendprop / /groups/admin users markv

    niutil -list . /

    niutil -read / /users/markv

    niutil -read / /groups/admin

