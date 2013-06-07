---
layout:post
title: $i
tags: ["howto"]
---


Phone:
  Change Start->Setup->Connections->USB->"USB Connection Setting" from ActiveSync to Modem
  (rumor has it the device won't charge when in this configuration)

---------8<----------------
cut from http://favias.org/node/45

Luckily the phone, once connected by the supplied USB cable, is automatically recognized by Feisty (Ubuntu 7.04) and the proper kernel modules and devices are loaded. All that remain is for you to run gnome-ppp as root, configure the connection and enjoy.

If you don't have gnome-ppp just install it using Synaptic or apt-get.
Open gnome-ppp as root by either creatinga desktop launcher with "gksudo gnome-ppp" as the command line or typing that into the command line your self.
Enter credentials
ISP@CINGLARGPRS.COM for the username
CINGULAR1 as the password
*99# as the phone number.
Click setup
Click detect to auto detect your modem (it shoudl find it as ttyACM0)
Click init string andmakemake the following changes:
Init 2 should read: ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Init 3 should read: AT+CGDCONT=1,"IP","isp.cingular"
Close "setup" and click on connect. After a sort pause at "Waiting for prompt" it should connect you.
Hope that helps someone else. You can of course configure it to dock into the system tray too.
  
