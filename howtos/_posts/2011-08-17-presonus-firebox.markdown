---
layout: post
title: Presonus Firebox in Ubuntu
tags: ['howto', 'audio']
---

Just some notes for later.

I want a little better sounding audio on screencasts so I dusted off
the firewire soundcard I got a few years ago for recording bass tracks.

This model [link](link)
worked great for me on audio production stuff several years
ago, but at the time I could give jackd and friends a realtime kernel
to have their way with.

Now, I don't really have the spare hardware to dedicate to a RT audio setup...  
gotta run several ubuntu server VMs for work and can't really hand the whole
shebang over to jack every time I wanna record something.

Here's my attempt to do it without realtime priorities... I'll let you know
how it sounds.

## The quick and the dirty...

Starting from a Natty desktop.

install jack

    # apt-get install jackd

when the installer asks to do realtime by default, I said no.

Note that I installed `ffado-mixer-qt4 ffado-tools ffado-dbus-server`
earlier trying to get this to work without jack, but gave up.  I don't
know if these packages effect the current setup, but they're still
installed

start the jack daemon... 

    $ jackd -r -dfirewire

saw other posts referring to `-dfirebob` but `firewire` worked.

Connect to jackd

    $ qjackctl 

(in the foreground so I could watch messages)

Install something like `Ardour`

    # apt-get install ardour

and wire stuff together with the qjackctl patchpanel.

I used to use a better jack patch panel in the past... have to find it.
