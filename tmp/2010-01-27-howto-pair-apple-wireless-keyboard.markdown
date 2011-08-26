---
layout:post
title: $i
tags: ["howto"]
---



from http://ubuntuforums.org/archive/index.php/t-224673.html


hidd --search
finds the keyboard
then enter the following into /etc/bluetooth/hcid.conf

device BD_ADDR {
name "Apple Wireless Keyboard";
auth enable;
encrypt enable;
}


sudo /etc/init.d/bluetooth restart


user@ubuntu:~$ sudo /etc/init.d/bluetooth restart
Restarting Bluetooth services... [ ok ]


Notice that this will terminate any active bluetooth connections. However, reconnecting should not be a problem ;-)

Finally, we're ready to do the actual pairing. Restart the keyboard again using the switch on the bottom to make it discoverable. Do not hit any keys on your Apple Keyboard unless this tutorial says so. It might cause all sorts of strange trouble during the pairing procedure. Okay, so, right after restarting the keyboard, run the following command (replacing BD_ADDR by the actual address, of course :-) ):


 user@ubuntu:~$ sudo hidd --connect BD_ADDR
 user@ubuntu:~$


Ubuntu will now try to connect to the keyboard without showing any progress bar or other output. It will just sit there and wait. Okay, enter a PIN consisting of 4 digits and hit the enter key (both on your Apple Keyboard). Right after hitting enter, a notification window should pop up on your desktop asking you for the PIN you just entered. Enter it. "hidd" should finish without further outputs. You should now be set up.

