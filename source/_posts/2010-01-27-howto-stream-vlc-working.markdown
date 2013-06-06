---
layout: post
title: Stream VLC (working)
categories: howtos
comments: true
---

##server

    vlc -Ihttp --http-host :7000 -vvv ~/Videos/Entourage.S06E10.HDTV.XviD-NoTV.avi --udp-caching 1500 --sout '#standard{access=http{mime=video/x-ms-asf},mux=asf,dst:7070}'


##client

from a browser:
 - localhost:7000 is remote control
 - localhost:8080 is movie


using vlc works fine too:
  - open VLC
  - open Network
  - protocol http
  - host localhost:8080
