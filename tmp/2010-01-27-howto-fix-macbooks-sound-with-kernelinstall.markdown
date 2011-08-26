---
layout:post
title: $i
tags: ["howto"]
---




cd /usr/local/src/alsa-driver-...
make clean
./configure --enable-dynamic-minors --without-oss --with-cards="hda-intel"
make
sudo make install


