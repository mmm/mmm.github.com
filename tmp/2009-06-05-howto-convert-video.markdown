---
layout:post
title: $i
tags: ["howto"]
---


(convert ogg to mp4)
mencoder out.ogg -ovc lavc -oac mp3lame -lavcopts vcodec=mpeg4 -o out1.mp4

(resizing)
ffmpeg -i out1.mp4 -s 320x240 out2.avi

(convert avi to mp4 or flv)
ffmpeg -i out2.avi -r 30 -vcodec mpeg4 out2.mp4


other stuff:
mencoder -oac copy -ovc copy video.avi -audiofile audio.mp3 -o final.avi


(convert ogg video to dv)
mencoder out.ogv -ovc libdv -oac pcm -vf scale=720:480 -o editme.dv

