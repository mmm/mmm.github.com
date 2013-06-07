---
layout:post
title: $i
tags: ["howto"]
---


build


Re: Howto: [Edgy] Fix random xgl crashes with Mobility Radeon 9000 + fglrx
Yeah, unfortunately this won't fix the GL bug. You could still run 3D apps on the main X server by prefacing the command with DISPLAY=:0 but there won't be any window borders or anything like that.

Basically, to patch a package you'd have to do:

Code:
sudo apt-get build-dep xserver-xgl
This would get dependencies needed to compile it. Then, to get the code:

Code:
apt-get source xserver-xgl
Now it will create a directory with the sources. In that directory, put the patch you want in the debian/patches subdirectory and also edit the list file (I think its something like 00list) and add the filename to the end. Now, you need to increment the verison of the package:

Code:
dch -i
Put in your comments and save the file. Now to compile:

Code:
dpkg-buildpackage -rfakeroot -us -uc
And you will have your debs. Unfortunately, I'm not 100% sure of the package names where you can get some of the d* commands so you will need to play around looking for debian in synaptic (debhelper or something like that is one, also you need build-depend).

Misha

Quote:
Originally Posted by Paerez  
Hey I wrote a guide for xgl/fglrx with beryl, so I am interested in this fix. However I have no experience in patching source files. I am assuming I have to get xserver-xgl-dev and then compile it somehow?

Also, I am unable to get 3d acceleration in any applications once xgl/beryl is working. For example, I can't run fgl_glxgears or "mplayer -vo gl2" (mplayer using opengl). Do you think this will help or do I have a different bug?

Thanks.
    





debug


Re: Howto: [Edgy] Fix random xgl crashes with Mobility Radeon 9000 + fglrx
Hmm... so are these crashes like with wobbly windows and openoffice (non-OpenGL applications) or with OpenGL applications (glxgears or google earth, etc). If it's the first, then I need to look into it further (how much video RAM do you have? It might be that the number of OpenGL arrays that fglrx can draw is not really fixed as <4000 but depends on your specific machine, so for me <4000 works great, but maybe for you it has to be <3000 or something). If it is only with OpenGL apps, then it is a different bug that I don't think is related. Anyway, waiting for your reply.

Also the next thing you could do is to start a regular X session, then
type:
Code:
gdb Xgl 
run :1 -fullscreen -ac -accel glx:pbuffer -accel xv:pbuffer
Then open another terminal or a tab in a new terminal (XGl is running but so is your regular X session, so you can use Alt-TAB to switch back and forth between Xgl and the regular X server apps, only trick is that when you switch back to Xgl with Alt-TAB it still thinks you are holding down the Alt key so you need to hit it before you type anything else, otherwise it will act as if the Alt key is pressed). Run emerald & beryl like this:

Code:
export DISPLAY=:1
emerald &
beryl-xgl &
Now run some other apps in the Xgl session, for example:

Code:
gnome-terminal &
Do some stuff until it crashes. Then you can go back to the terminal/tab where gdb is running and type:

Code:
bt
and that will give you a backtrace. Of course it would be more helpful with a version of Xgl compiled with debugging support, which unfortunately is about 10 times as big, but it might be helpful (specifically if the lines aren't __R200TCLDrawArrays than chances are you are having a different bug). 
Misha
