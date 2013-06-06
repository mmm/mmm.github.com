---
layout: post
title: Stir that memory of autotools
categories: howtos
comments: true
---


Ok, never going to forget these again, dammit!

    $ aclocal
    $ autoconf --force
    $ automake --add-missing --copy --force-missing
    $ ./configure
    $ OS_ARCH=amd64 make


or sometimes you can use

    $ autoreconf --force --install

