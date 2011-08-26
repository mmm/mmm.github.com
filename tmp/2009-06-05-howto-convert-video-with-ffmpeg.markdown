---
layout:post
title: $i
tags: ["howto"]
---


from https://wiki.ubuntu.com/ScreencastTeam/FfmpegConversion

--------8<---------------


This is the script I use to convert screencasts to various formats 

The script takes one argument which is the name of the video without the .avi file extension. It then makes videos with the format and resolution in the filename. 

So 20070704_samba_filesharing.avi becomes (for example) 20070704_samba_filesharing_mpeg4_mp3_1280x720.avi. 

--------8<---------------
export LD_LIBRARY_PATH=/usr/local/lib/

#/usr/local/bin/ffmpeg -i "$1.avi" -target ntsc-dvd -b 2000k -acodec mp2 -ar 22050 -ab 64 -aspect 16:9 $1_ntsc-dvd_720x480_low.mpg
/usr/local/bin/ffmpeg -i "$1.avi" -vcodec mpeg4 -s 1280x720 -b 300k -r 10 -acodec mp3 -ar 22050 -ab 64 -f avi $1_mpeg4_mp3_1280x720.avi
/usr/local/bin/ffmpeg -i "$1.avi" -vcodec mpeg4 -s 968x544 -b 300k -r 10 -acodec mp3 -ar 22050 -ab 64 -f avi $1_mpeg4_mp3_968x544.avi 
/usr/local/bin/ffmpeg -i "$1.avi" -vcodec mpeg4 -s 640x360 -b 300k -r 10 -acodec mp3 -ar 22050 -ab 64 -f avi $1_mpeg4_mp3_640x360.avi 

/usr/local/bin/ffmpeg -i $1.avi -vcodec xvid -s 1280x720 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f avi $1_xvid_mp3_1280x720.avi 
/usr/local/bin/ffmpeg -i $1.avi -vcodec xvid -s 968x544 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f avi $1_xvid_mp3_968x544.avi 
/usr/local/bin/ffmpeg -i $1.avi -vcodec xvid -s 640x350 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f avi $1_xvid_mp3_640x350.avi 

#likes multiples of 8
ffmpeg2theora "$1.avi" -x 1280 -y 720 -o $1_ogg_theora_1280x720.ogg 
ffmpeg2theora "$1.avi" -x 968 -y 544 -o $1_ogg_theora_968x544.ogg 
ffmpeg2theora "$1.avi" -x 640 -y 360 -o $1_ogg_theora_640x360.ogg 

/usr/local/bin/ffmpeg -i $1.avi -vcodec flv -s 1280x720 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f flv $1_flv_mp3_1280x720.flv 
/usr/local/bin/ffmpeg -i $1.avi -vcodec flv -s 968x544 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f flv $1_flv_mp3_968x544.flv 
/usr/local/bin/ffmpeg -i $1.avi -vcodec flv -s 960x540 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f flv $1_flv_mp3_960x540.flv 
/usr/local/bin/ffmpeg -i $1.avi -vcodec flv -s 640x360 -acodec mp3 -b 300k -r 10 -ar 22050 -ab 64 -f flv $1_flv_mp3_640x360.flv 

# likes multiples of 16
/usr/local/bin/ffmpeg -i $1.avi -vcodec h264 -s 1280x720 -b 300k -r 10 -acodec mpeg4aac -ar 22050 -ab 128 -f mov $1_h264_aac_1280x720.mov
/usr/local/bin/ffmpeg -i $1.avi -vcodec h264 -s 968x544 -b 300k -r 10 -acodec mpeg4aac -ar 22050 -ab 128 -f mov $1_h264_aac_968x544.mov
/usr/local/bin/ffmpeg -i $1.avi -vcodec h264 -s 640x360 -b 300k -r 10 -acodec mpeg4aac -ar 22050 -ab 128 -f mov $1_h264_aac_640x360.mov
--------8<---------------


Here's a test version where I generate 300K, 600K and 900K bitrate versions (to test and compare) and also use two-pass encoding. I need some serious help making this script easier. Help! 


--------8<---------------
# Short script to re-encode screencasts to other formats and resolutions

export LD_LIBRARY_PATH=/usr/local/lib/
mkdir ./ogg
mkdir ./mov
mkdir ./flv
mkdir ./avi

#
# Theora video, Vorbis audio in an OGG, high quality, 300k bitrate
#
#likes multiples of 8
ffmpeg2theora $1.* -x 1280 -y 720 -v 10 -V 300 -o ogg/$1_ogg_theora_1280x720.ogg
ffmpeg2theora $1.* -x 968 -y 544 -v 10 -V 300  -o ogg/$1_ogg_theora_852x480.ogg
ffmpeg2theora $1.* -x 640 -y 360 -v 10 -V 300  -o ogg/$1_ogg_theora_640x360.ogg

#
# Theora video, Vorbis audio in an OGG, high quality, 600k bitrate
#
#likes multiples of 8
ffmpeg2theora $1.* -x 1280 -y 720 -v 10 -V 600  -o ogg/$1_ogg_theora_1280x720.ogg
ffmpeg2theora $1.* -x 968 -y 544 -v 10 -V 600  -o ogg/$1_ogg_theora_852x480.ogg
ffmpeg2theora $1.* -x 640 -y 360 -v 10 -V 600  -o ogg/$1_ogg_theora_640x360.ogg

#
# Theora video, Vorbis audio in an OGG, high quality, 900k bitrate
#
#likes multiples of 8
ffmpeg2theora $1.* -x 1280 -y 720 -v 10 -V 900  -o ogg/$1_ogg_theora_1280x720.ogg
ffmpeg2theora $1.* -x 968 -y 544 -v 10 -V 900  -o ogg/$1_ogg_theora_852x480.ogg
ffmpeg2theora $1.* -x 640 -y 360 -v 10 -V 900  -o ogg/$1_ogg_theora_640x360.ogg

#
# MPEG4 video, MP3 audio in an AVI, 300k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 300k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_1280x720.avi 
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 300k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_1280x720.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 300k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_852x480.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 300k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_852x480.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 300k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_640x360.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 300k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_300k_mp3_640x360.avi

#
# MPEG4 video, MP3 audio in an AVI, 600k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 600k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_1280x720.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 600k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_1280x720.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 600k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_852x480.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 600k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_852x480.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 600k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_640x360.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 600k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_600k_mp3_640x360.avi

#
# MPEG4 video, MP3 audio in an AVI, 900k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 900k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_1280x720.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd720 -b 900k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_1280x720.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 900k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_852x480.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s hd480 -b 900k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_852x480.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 900k -r 10 -acodec mp3 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_640x360.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec mpeg4 -s 640x360 -b 900k -r 10 -acodec mp3 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_mpeg4_900k_mp3_640x360.avi

#
# XviD video, MP3 audio in an AVI, 300k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s hd720 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_1280x720.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s hd720 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_1280x720.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s hd480 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_852x480.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s hd480 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_852x480.avi

/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s 640x350 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_640x350.avi
/usr/local/bin/ffmpeg -y -i $1.* -vcodec xvid -s 640x350 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f avi avi/$1_xvid_300k_mp3_640x350.avi

#
# flv video, mp3 audio in an flv, 300k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_1280x720.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_1280x720.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_852x480.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_852x480.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 300k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_640x360.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 300k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_300k_mp3_640x360.flv

#
# flv video, mp3 audio in an flv, 600k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 600k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_1280x720.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 600k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_1280x720.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 600k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_852x480.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 600k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_852x480.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 600k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_640x360.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 600k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_600k_mp3_640x360.flv

#
# flv video, mp3 audio in an flv, 900k bitrate
#
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 900k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_1280x720.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd720 -acodec mp3 -b 900k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_1280x720.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 900k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_852x480.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s hd480 -acodec mp3 -b 900k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_852x480.flv

/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 900k -r 10 -pass 1 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_640x360.flv
/usr/local/bin/ffmpeg -y -i $1.* -vcodec flv -s 640x360 -acodec mp3 -b 900k -r 10 -pass 2 -ar 22050 -ab 64 -f flv flv/$1_flv_900k_mp3_640x360.flv

#
# h264 video, aac audio in a mov, 300k bitrate
#
# likes multiples of 16
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 300k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_1280x720.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 300k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_1280x720.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 300k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_852x480.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 300k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_852x480.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 300k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_640x360.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 300k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_300k_aac_640x360.mov

#
# h264 video, aac audio in a mov, 600k bitrate
#
# likes multiples of 16
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 600k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_1280x720.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 600k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_1280x720.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 600k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_852x480.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 600k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_852x480.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 600k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_640x360.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 600k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_600k_aac_640x360.mov

#
# h264 video, aac audio in a mov, 900k bitrate
#
# likes multiples of 16
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 900k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_1280x720.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd720 -b 900k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_1280x720.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 900k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_852x480.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s hd480 -b 900k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_852x480.mov

/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 900k -r 10 -acodec mpeg4aac -pass 1 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_640x360.mov
/usr/local/bin/ffmpeg -y -i $1.* -vcodec h264 -s 640x360 -b 900k -r 10 -acodec mpeg4aac -pass 2 -ar 22050 -ab 128 -f mov mov/$1_h264_900k_aac_640x360.mov
--------8<---------------
