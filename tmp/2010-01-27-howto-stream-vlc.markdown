---
layout:post
title: $i
tags: ["howto"]
---


---------------------
on the server side:
---------------------

File -> Open File
browse to iso
check Advanced options -> "Stream/Save"
Settings...
check udp
add target to stream to (client ip)
port 1234
radio button MPEGTS
TTL up to like 11
hit ok to exit settings
hit ok to play stream
Navigation -> Title -> Title 1

don't know how to control dvd
other than Navigation menu or under File Open -> Stream/Save Settings... -> check "Play Locally"



---------------------
on the client side:
---------------------

open up vlc
Media -> Open Network
udp://@:1234
should run

open up firefox
http://hawk:8080
control the playback

