---
layout:post
title: $i
tags: ["howto"]
---


just to mirror video:
gst-launch-0.10 v4l2src ! video/x-raw-yuv,width=960,height=720 ! ffmpegcolorspace ! xvimagesink



use a usb webcam to create a video for youtube upload
http://jbuberel.typepad.com/blog/2008/03/using-a-usb-web.html




Side note: If you just want to record audio to an mp3 file using the microphone on your webcam, use the following command: 
gst-launch-0.10 alsasrc device="hw:1,0" 
    ! audio/x-raw-int,rate=16000,channels=1,depth=16 
    ! audioconvert ! lame ! filesink location=test.mp3
To do the same but using Vorbis encoded Ogg-formatted output: 
gst-launch-0.10 alsasrc device="hw:1,0" 
    ! audio/x-raw-int,rate=16000,channels=1,depth=16 
    ! audioconvert ! vorbisenc ! oggmux 
    ! filesink location=test.ogg
And if you just want to play the audio back to yourself: 
gst-launch-0.10 alsasrc device="hw:1,0" 
    ! audio/x-raw-int,rate=16000,channels=1,depth=16 
    ! audioconvert 
    ! alsasink
If all you want is to show the video being captured by the camera in a window on your desktop: 
gst-launch-0.10 v4l2src 
    ! video/x-raw-yuv,width=800,height=600 
    ! ffmpegcolorspace 
    ! xvimagesink
For those of you who need to adjust the color/contrast/brightness settings of their webcam, I suggest luvcview.
