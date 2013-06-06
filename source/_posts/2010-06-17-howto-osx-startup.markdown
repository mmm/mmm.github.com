---
layout: post
title: osx startup scripts
categories: howtos
comments: true
---

edit `Library/LaunchAgents/hawk.videos.sshfs.plist`

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
            <key>Label</key>
            <string>hawk.videos.sshfs</string>
            <key>ProgramArguments</key>
            <array>
                    <string>/usr/local/bin/sshfs-authsock</string>
                    <string>mmm@hawk:/home/mmm/Videos</string>
                    <string>/mnt/hawk</string>
                    <string>-oreconnect</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>AbandonProcessGroup</key>
            <true/>
    </dict>
    </plist>
    
now, just

    launchctl load ~/Library/LaunchAgents/hawk.videos.sshfs.plist
    launchctl start hawk.videos.sshfs
