---
layout: post
title: Stream VLC from hawk
categories: howtos
comments: true
---

this sets up a remote control on 7001 over an ssh tunnel

    hawk:~ $ vlc -Ihttp --http-host :7001 -vvv /tmp/howimetyourmother-S1d1-t1.mp4 --udp-caching 1500 --sout '#transcode{vcodec=mp4v,acodec=mpga,vb=800,ab=128}:standard{access=http{mime=video/x-ms-asf},mux=asf,dst:8080}'

this client hits hawk:8080 which forwards the port to hawk's vlc process

insecure data stream (control stream still safe) but seems to work better than tunneling over 8080 too

next up is to try it over some other protocol than http... 
need to set up port forwarding for udp traffic and see fi that's faster

