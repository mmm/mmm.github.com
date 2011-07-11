---
layout: post
title: Some more VLC
tags: ['howto']
---


Following some more stuff from [This post](http://www.linuxquestions.org/questions/linux-networking-3/playing-audio-files-over-ssh-connection-linux-linux-432640/).

this was for audio to stream out ogg quality 0

    vlc -I http --control http:rc --rc-host :4800 --http-host :7000 --no-rc-show-pos --volume 500 --spdif -vvv /home/laptop/all.m3u --random --sout-keep --sout '#duplicate{dst=display,dst="transcode{acodec=vorb,anc=vorbis{quality=2},ab=64,samplerate=44100,channels=2}:standard{access=http,mux=ogg,url=192.168.3.2:8000}"}'


To explain what's going on:
vlc opens in the background with an http interface available. vlc can be controlled by both the http interface, on port 7000, and a remote control advanced telnet interface on port 4800. It's playing the all.m3u playlist, at random, and keeps the stream-out alive between tracks. The stream-out (sout) is duplicated: the first stream plays locally (display), whilst the duplicate stream is transcoded via vorbis, to a quality of 2, at a bitrate of 64, 44100 mhz, stereo, with an ogg stream via http on port 8000. (whew)

