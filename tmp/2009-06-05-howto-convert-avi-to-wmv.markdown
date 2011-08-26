---
layout:post
title: $i
tags: ["howto"]
---


This worked:
ffmpeg -i jsas-200810171537.avi -b 1000k -vcodec wmv2 -ar 44100 -acodec wmav2 jsas-200810171537.wmv


-----------------------------------------
don't know about these...

mencoder input.avi -of lavf -lavfopts i_certify_that_my_video_stream_does_not_use_b_fram es -ovc lavc -lavcopts vcodec=wmv2:vbitrate=100 -vf scale=176:144 -oac lavc -lavcopts acodec=mp3:abitrate=48 -o ./output.wmv

# this allegedly didn't work
mencoder Koyaanisqatsi.avi -ofps 23.976 -ovc lavc -oac copy -o Koyaanisqatsi.wmv


ffmpeg -i "********.avi" -b 1000k -vcodec wmv2 -ar 44100 -acodec wmav2 "*****.wmv"

mencoder -oac copy -ovc copy *******.avi -o *****.wmv

ffmpeg -i INPUT -b 700k -vcodec wmv2 -ar 44100 -acodec wmav2 OUTPUT.WMV

ffmpeg -i INPUT -b 700k -vcodec wmv2 -ar 44100 -acodec wmav2 OUTPUT.WMV

#the latest mplayer and ffmpeg have successfully decoded the vc1 codec aka wmv-hd

