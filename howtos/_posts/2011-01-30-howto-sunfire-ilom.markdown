---
layout: post
title: sunfire ilom
tags: ['howto']
---

log into the agent

    SP -> set /SP/SystemInfo/CtrlInfo PowerCtrl=reset  
    The System will be Reset.
    Do you wish to Continue..?(y/n)y
    Set 'PowerCtrl' to 'reset'
    /SP -> 

    start /SP/AgentInfo/console



    /SP -> set /SP/SystemInfo/CtrlInfo PowerCtrl=forceoff
    The System will be force Powered Off.
    Do you wish to Continue..?(y/n)y
    Set 'PowerCtrl' to 'forceoff'
    /SP -> show /SP/SystemInfo/CtrlInfo                  

      /SP/SystemInfo/CtrlInfo
        Targets:

        Properties:
            PowerStatus = off
            PowerCtrl = (Cannot show property)
            BootCtrl = regular
            IdLedCtrl = off

        Target Commands:
            show
            set


