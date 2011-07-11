---
layout: post
title: mimic dropbox
tags: ['howto']
---

this is from http://news.ycombinator.com/item?id=429573


    #-------- ~/backup.command -----------

    # Backup up home dir using git. Note the full path to git (needed for cron jobs):
    cd ~/
    /opt/local/bin/git add . 
    /opt/local/bin/git commit -a -m "home dir backup"
    /opt/local/bin/git pull
    /opt/local/bin/git push

    # Backup binary stuff using rsync
    rsync -Cauvzd  /Users/Shared/Music/ user@server:/var/backups/music
    rsync -Cauvzd  /Users/Shared/Photos/ user@server:/var/backups/photos


---

so the plan would be to clone the dropbox

    git clone mydropbox@hawk:/home/mydropbox/var/MyDropBox.git

and copy over the sync script

    scp mydropbox@hawk:/home/mydropbox/bin/sync-MyDropBox.sh .

and then run it in a cronjob...

    SHELL=/bin/bash
    PATH=/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin
    MAILTO=mark.mims@agiledynamics.com
    HOME=/home/mmm

    # m h  dom mon dow   command

    */10 * * * *  $HOME/bin/sync-MyDropBox.sh


---

the sync script looks like

    #!/bin/bash

    MY_DROP_BOX=${HOME}/MyDropBox
    MY_DROP_BOX_SERVER="mydropbox@hawk:/home/mydropbox/"
    GIT=/usr/bin/git
    RSYNC=/usr/bin/rsync

    if [ -d $MY_DROP_BOX ]
    then
      cd $MY_DROP_BOX
      $GIT add .
      $GIT commit -a -m'MyDropBox sync'
      $GIT pull
      $GIT push
    fi

    for directory in Downloads Music Photos Videos
    do
      rsync -Cauvzd ${MY_DROP_BOX}/${directory} ${MY_DROP_BOX_SERVER}var/binary-data/${directory}
    done
