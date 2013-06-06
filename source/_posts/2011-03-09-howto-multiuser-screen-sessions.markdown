---
layout: post
title: multiuser screen sessions
categories: howtos
comments: true
---


ok, trying to do this for real...


I set suid on screen, so

    mmm@kojiro:~/projects/ttu/doc$ ls -al /usr/bin/screen
    -rwxr-sr-x 1 root utmp 340604 2010-08-17 10:55 /usr/bin/screen

becomes

    mmm@kojiro:~/projects/ttu/doc$ ls -al /usr/bin/screen
    -rwsr-sr-x 1 root utmp 340604 2010-08-17 10:55 /usr/bin/screen

and then /var/run/screen needs to be 755 instead of 775... i.e.,

    mmm@kojiro:~/projects/ttu/doc$ ls -al /var/run | grep screen
    drwxrwxr-x  5 root     utmp      100 2011-02-08 10:17 screen

becomes

    mmm@kojiro:~/projects/ttu/doc$ ls -al /var/run | grep screen
    drwxr-xr-x  5 root     utmp      100 2011-02-08 10:17 screen


Now, user1:

    user1@kojiro:~$ screen -x -S junk -t junk

or just

    user1@kojiro:~$ screen -S junk

user1 sets multiusermode

    Ctrl-A :multiuser on
    Ctrl-A :acladd user2
    Ctrl-A :acladd user3

user2
 
    user2@kojiro:~$ screen -x mmm/

user3

    user3@kojiro:~$ screen -x mmm/

---

another version

    For security reasons, screen by default is installed so that other users within the system can not attach to your screen sessions. To allow this to be changed one must set screen to run SUID root by doing the following (once):
    sudo chmod +s /usr/bin/screen
    sudo chmod 755 /var/run/screen
    Then user1 can share their session on host as follows:
    screen -S shared-session
    Ctrla :multiuser on
    Ctrla :acladd user2

    user2 on host can then connect to the shared session like:
    ssh user2@host
    screen -x user1/shared-session

---

first view
    screen -S junk

second view
    screen -x -R junk

---


maybe this'll work...


user1

    screen -t junk

user2 becomes user1

    screen -x -t junk


---

looks like this works... maybe overkill but wtf?

screen -xR -t junk -S junk


allegedly, 
screen -t junk
screen -x -t junk
should work





below is old
---


It's possible for two users to share a screen session. This is particularly useful if multiple people want to monitor a long running task, and it's easy to do.

user #1:

screen -R longbuild

user #2:

screen -x -R longbuild

The -x flag tells screen to allow you to attach to an already attached session. This is also good for crazy stuff like a collaborative Vim session (if you're into that sort of thing).
