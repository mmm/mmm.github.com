---
layout: post
title: supermicro ipmi
categories: howtos
comments: true
---


SuperMicro IPMI Firewall Connection Information

    HTTP: 80 (TCP)
    HTTPS: 443 (TCP)
    IPMI: 623 (UDP)
    Remote console: 5900 (TCP)
    Virtual media: 623 (TCP)
    SMASH: 22 (TCP)
    WS-MAN: 8889 (TCP)
    Source: http://www.supermicro.com/manuals/other/Onboard_BMC_IPMI.pdf


--or--

    ipmitool -I lanplus -H proteus.mgmt.inside.ttu.edu.vn -U ADMIN -P ADMIN sol info
    ipmitool -I lanplus -H proteus.mgmt.inside.ttu.edu.vn -U ADMIN -P ADMIN sol activate


-------------------------------------


Stop a Serial-Over-LAN session

From an existing sol session:

    ~.

If your existing sol session is in a terminal you've ssh'd into, you'll have to prepend a tilde for each ssh layer:

    ~~~.

From the SOL help:

    Supported escape sequences:
    ~.  - terminate connection
    ~^Z - suspend ipmitool
    ~^X - suspend ipmitool, but don't restore tty on restart
    ~B  - send break
    ~?  - this message
    ~~  - send the escape character by typing it twice
    (Note that escapes are only recognized immediately after newline.)


Using the Serial-Over-LAN session

    
    The serial BIOS interface is a bit brain-damaged in that it does not recognise the "F11", and "F12" key escape codes that most terminal programs send, instead you can send "Esc-!", and "Esc-@" (yes very logical, as long as the '@' key is normally typed using 'Shift-2' - as on US keyboards, not miles away from the '2' key, as on many non-US keyboards). These escapes from HP, and Dell serial BIOS' may or may not be useful:

    Defined As     F1     F2     F3     F4     F5     F6     F7     F8     F9     F10    F11    F12
    Keyboard Entry <ESC>1 <ESC>2 <ESC>3 <ESC>4 <ESC>5 <ESC>6 <ESC>7 <ESC>8 <ESC>9 <ESC>0 <ESC>! <ESC>@
    
    Defined As     Home   End    Insert Delete PageUp PageDn
    Keyboard Entry <ESC>h <ESC>k <ESC>+ <ESC>- <ESC>? <ESC>/
    
    Use the <ESC><Ctrl><M> key sequence for <Ctrl><M>
    
    Use the <ESC><Ctrl><H> key sequence for <Ctrl><H>
    
    Use the <ESC><Ctrl><I> key sequence for <Ctrl><I>
    
    Use the <ESC><Ctrl><J> key sequence for <Ctrl><J>
    
    Use the <ESC><X><X> key sequence for <Alt><x>, where x is any letter key, and X is the upper case of that key
    
