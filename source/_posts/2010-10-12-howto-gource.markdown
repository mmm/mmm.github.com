---
layout: post
title: gource
categories: howtos
comments: true
---

From gource docs:

##Linux / Mac

You can create a video of Gource using the --output-ppm-stream option. This creates an uncompressed sequence of screenshots in PPM format which can then be processed by another program (such as ffmpeg) to produce a video. The below command line will create a video at 60fps in x264 format (assumes you have ffmpeg with x264 support):

    gource --disable-progress --stop-at-end --output-ppm-stream - | ffmpeg -y -b 3000K -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 gource.mp4

Note: You may need to add one of '-vpre default', '-vpre libx264-default' or '-fpre /path/to/libx264-default.ffpreset' to get ffmpeg to work. The arguments for ffmpeg may vary depending on the version you have. There is a good guide to using x264 with ffmpeg here.

You can also adjust the output frame rate with --output-framerate. Note you will need to adjust the frame rate used by the encoder (eg ffmpeg -r) as well.
