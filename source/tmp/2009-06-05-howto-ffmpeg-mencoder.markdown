---
layout:post
title: $i
tags: ["howto"]
---



  389  ffmpeg -i 0001_20130.avi -s vga vga_out.avi
    390  ffmpeg -i 0001_20130.avi  vga_out.avi
      391  ffmpeg -i 0001_20130.avi -r 24 -s vga vga_out.avi
        392  ffmpeg -i 0001_20130.avi -r 24 -s 320x200 lowres_out.avi
          396  ffmpeg -i 0001_20130.avi  vga_out.avi
            397  ffmpeg -i 0001_20130.avi -r 24 -s vga vga_out.avi
              398  ffmpeg -i 0001_20130.avi -r 24 -s 320x200 lowres_out.avi
                408  ffmpeg -i 0001_20130.avi  vga_out.avi
                  409  ffmpeg -i 0001_20130.avi -r 24 -s vga vga_out.avi
                    413  ffmpeg -i 0001_20130.avi -r 24 -s 320x200 lowres_out.avi
                      416  ffmpeg -i 0001_20130.avi -r 24 -s 640x480 lowres_out.avi
                        417  ffmpeg -i 0001_20130.avi -r 24 -s 640x480 medres_out.avi
                          418  ffmpeg -i 0001_20130.avi -s 640x480 medres_30_out.avi
                            446  ffmpeg -i 0001_12175.avi -s 800x600 jsas_screencast-800x600.avi
                              460  man ffmpeg
                                462  ffmpeg -i demo1.ogv demo1.ogg
                                  463  ffmpeg -i demo1.ogv demo1.avi
                                    464  history | grep ffmpeg





