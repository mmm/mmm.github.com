---
layout:post
title: $i
tags: ["howto"]
---

most from: http://www.i607.org/wiki/doku.php?id=bt_pan_tether_to_windows_and_linux

Phone:

Turn Bluetooth on
Pair with the laptop (use laptop pin entered in /etc/bluetooth/hcid.conf)
Run "Internet Sharing" from the windows directory
Change "PC Connection" to "Bluetooth PAN"
"Connect" Internet Sharing



Computer:

#edit /etc/default/bluetooth to enable bluetooth... nothing else for now

#edit /etc/bluetooth/hcid.conf to change securty to "auto" and change the pin

#turn on bluetooth
spicctrl -l 1
/etc/init.d/bluetooth restart

#stop network connections
#kill any stray dhclient or pand connections (pand -K)

modprobe bnep
pand –role PANU –service NAP –connect XX:XX:XX:XX:XX:XX –nodetach

dhclient bnep0

