---
layout: post
title: fix-hawk-screensaver
tags: ['howto']
---


From `http://ubuntuforums.org/showthread.php?t=1213325`

    #!/usr/bin/perl
    my $cmd = q[dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver',member='SessionIdleChanged'"];
    open (IN, "$cmd |");
    while (<IN>) {
        if (/^\s+boolean true/) {
            system '~/gpufolding/gpufah.bash';
        }
        elsif (/^\s+boolean false/) {
            system 'kill `pgrep gupfah.bash`';
            system 'kill `pgrep Folding.*home`';
        }
    }

---

From `http://www.linuxquestions.org/questions/fedora-35/start-and-stop-script-with-screensaver-728498/`


    #!/usr/bin/perl
    #gnome
    my $cmd = "dbus-monitor --session \"type='signal',interface='org.gnome.ScreenSaver',member='SessionIdleChanged'\"";

    open (IN, "$cmd |");

    while (<IN>) {
    if (m/^\s+boolean true/) {
    #when screensaver activates, run the following commands
    #system("/home/eric/compiled/scripts/rtorrentstart");
    system("touch /home/asoukenka/rtorrenthasstarted");
    } elsif (m/^\s+boolean false/) {
    #when screensaver deactivates, run the following commands
    #system("kill `pgrep rtorrent`");
    system("touch /home/asoukenka/rtorrenthasbeenkilled");
    }
    }

and

    #!/usr/bin/perl
    #requires:
    # rtorrent, screen, gnome/kde, perl
    #
    # Instructions:
    # - Properly comment the line for gnome or kde
    # - Give script execute permission (chmod +x)
    # - Run script ./<scriptname> **** do not use rtorrent in script name will mess up kill command
    #
    # There is a log file created by the script at /tmp/autortorrent 
    #
    #


    #gnome
    #my $cmd = "dbus-monitor --session \"type='signal',interface='org.gnome.ScreenSaver',member='SessionIdleChanged'\"";

    #kde
    my $cmd = "dbus-monitor --session \"type='signal',interface='org.freedesktop.ScreenSaver',member='ActiveChanged'\"";
    open (IN, "$cmd |");

    while (<IN>) {
    if (m/^\s+boolean true/) {
    #when screensaver activates, run the following commands
    system("echo \"--------------------------------------------------------------------\" >> /tmp/autortorrent");
    system("screen -dmS rtorrent rtorrent");
    system("echo \"started:\" >> /tmp/autortorrent");
    system("date >> /tmp/autortorrent");
    system("echo \"--------------------------------------------------------------------\" >> /tmp/autortorrent");
    } elsif (m/^\s+boolean false/) {
    #when screensaver deactivates, run the following commands
    system("echo \"--------------------------------------------------------------------\" >> /tmp/autortorrent");
    system("kill `pgrep rtorrent`");
    system("echo \"stopped:\" >> /tmp/autortorrent");
    system("date >> /tmp/autortorrent");
    #system("ps aux |grep rtorrent >> /tmp/autortorrent");
    system("echo \"--------------------------------------------------------------------\" >> /tmp/autortorrent");
    }
    }


---


from `http://ubuntuforums.org/showthread.php?t=1537241`

    #!/bin/sh
    gnome-screensaver-command --lock
    xset dpms force off
    gnome-screensaver-command --inhibit
    exit


also some stuff in `http://ubuntuforums.org/showthread.php?t=1358946`

Try to run gnome-screensave in no-daemon and debug mode to see what's going on...
according to `https://bugs.launchpad.net/ubuntu/+source/gnome-power-manager/+bug/193192`


---

Some inhibit stuff from `http://program-nix.blogspot.com/2010/08/python-inhibiting-gnome-screensaver.html`

    #!/usr/bin/python
    import subprocess

    #run inhibition
    ss_inhibit = subprocess.Popen(["gnome-screensaver-command", "-i", "-n", 
                                   "mplayer", "-r", "video"])

    #run gmplayer
    player = subprocess.Popen("gmplayer")

    #wait for mplayer to exit
    player.wait()

    #kill the inhibition
    ss_inhibit.kill()

---

or from `https://bbs.archlinux.org/viewtopic.php?pid=321620`

    dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call --print-reply --reply-timeout=20000 /org/gnome/ScreenSaver org.gnome.ScreenSaver.Inhibit string:"MPlayer" string:"Watching video"

or

    dbus-send --session --dest=org.freedesktop.ScreenSaver --type=method_call /ScreenSaver org.gnome.ScreenSaver.SimulateUserActivity
    dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call --print-reply --reply-timeout=20000 /org/gnome/ScreenSaver org.gnome.ScreenSaver.Inhibit string:"MPlayer" string:"Watching video"
    gnome-screensaver-command --poke

---


