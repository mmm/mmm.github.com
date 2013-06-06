---
layout: post
title: debuggin eucalyptus aoe
categories: howtos
comments: true
---


mostly from
    http://open.eucalyptus.com/forum/attaching-ebs-image
and
    http://www.debian-administration.org/articles/553

---

## problem1

vtund wasn't in sync with the pid in /var/run/eucalyptus and so it "wasn't able to bind to socket" in /var/log/syslog

---

## problem2

Volume is created and available from the SC
    ps awux | grep vblade
should return something... something running on the br0 interface... but they seem to be stuck on eth0


---

## general method for exporting things using aoe

On the storage controller ("target" in AoE lingo)...

Load the module
    modprobe aoe

Then
    vbladed 0 1 eth0 /dev/sdd5
or for euca
    vblade 0 5 br0 /dev/vg-TldY4A../lv-hrh7uQ.. 

Then on the NC ("initiator")...

discover
    aoe-discover (this wasn't necessary on a NC... just worked once the target had the right device)

status
    aoe-stat
    ls /dev/etherd/

this showed a `e0.5` entry that can be treated like a regular partition


Note: iSCSI is over TCP (layer 4?), AoE is over Ethernet (layer 2)
so iscsi can be routed, aoe can't (at least not without ebtables and l2 switches)
aoe is designed to be used in a tighter lan environment

---

Had to manually change the files in /var/lib/eucalyptus/db/
to use `br0` instead of `eth0`

This is probably the biggest problem with setting up eucalyptus!!

---

## vtun?

dunno wtf... I assume it's something going on with tunneling traffic between SC and NC instances?



