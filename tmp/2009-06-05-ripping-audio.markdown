---
layout:post
title: $i
tags: ["howto"]
---



1.) the rip:
mkdir d1
cd d1
cdparanoia -B


2.) the transcode:

for i in d10 d09 d08 d07; do cd $i; for j in *; do lame --preset medium ${j} ${j%%.cdda.wav}.mp3; done; cd ..; done
for i in *; do mv $i/*.mp3 ../mp3/$i; done


3.) labels:

for i in *; do cd $i; for j in *.mp3; do eyeD3 -G"Audio Books" -a"David Balducci" -A"Simple Genius ${i}" -t"Simple Genius ${i} ${j}" $j; done; cd ..; done

-or-

for i in *; do eyeD3 -G"Classical" -a"Franz Liszt" -A"Piano Works" -t"${i/-liszt*1886_/}" $i; done


