---
layout: post
title: PreSonus FireBox in Ubuntu
categories: howtos
comments: true
---

Just some notes to myself for later.

I want a little better sounding audio on screencasts so I dusted off
the firewire soundcard I got a few years ago for recording bass tracks.

This model 
[FireBox 24-bit/96kHz](
http://www.amazon.com/PreSonus-FireBox-Firewire-Recording-Interface/dp/B0006VYH1Q/ref=sr_1_17?s=musical-instruments&ie=UTF8&qid=1313592982&sr=1-17
)
from [PreSonus](http://www.presonus.com/) 
worked great for me on audio production stuff several years
ago, but at the time I could give jackd and friends a realtime kernel
to have their way with.

Now, I don't really have the spare hardware to dedicate to a RT audio setup...  
gotta run several ubuntu server VMs for work and can't really hand the whole
shebang over to jack every time I wanna record something.

Here's my attempt to do it without realtime priorities...
I'll track my progress here.

<!--more-->

## The quick and the dirty...

Starting from a Natty desktop.

install jack

    # apt-get install jackd

when the installer asks to do realtime by default, I said no.

Note that I installed `ffado-mixer-qt4 ffado-tools ffado-dbus-server`
earlier trying to get this to work with pulse, without jack... but gave up.
I don't know if these packages effect the current setup, but they're still
installed

start the jack daemon... 

    $ jackd -r -dfirewire

Connect to jackd

    $ qjackctl 

(in the foreground so I could watch messages)

Install something like `Ardour`

    # apt-get install ardour

and wire stuff together with the qjackctl patchpanel,
start `jackd` and go.

I used to use a better jack patch panel in the past... have to find it.

## resources

    http://wiki.jon.geek.nz/index.php/Presonus_Firebox
    http://ubuntuforums.org/showthread.php?t=835477
    http://rgrwkmn.hubpages.com/hub/Recording-in-Linux-aka-Free-and-Open-Source-Digital-Audio-Workstation

