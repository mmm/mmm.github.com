---
layout:post
title: $i
tags: ["howto"]
---


1.) capture ogg
run gtk-recordMyDesktop

2.) convert to mp4
mencoder out.ogg -ovc lavc -oac mp3lame -lavcopts vcodec=mpeg4 -o out1.mp4

3.) use avidemux to remove audio and save as an avi
set the "source" for both audio tracks to "None"
save




--------------------------

other stuff...

Capture whole screen (change your device - I use a logitech usb mike)
recordmydesktop -fps 15 -device hw:1,0

Capture an application window (after executing click the app window that you wish to record)
recordmydesktop -windowid $( xwininfo -frame | awk '/Window id:/ {print $4}' ) -fps 15 -device hw:1,0

Type Ctrl+c to stop recording.
