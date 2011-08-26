---
layout:post
title: $i
tags: ["howto"]
---

dump
find . -depth -print0 | cpio --create --null --format=crc --file=/dev/nrst0

restore
cpio --extract --null --make-dir --unconditional --preserve --file=/dev/nrst0

cpio --extract --null --make-dir --unconditional --preserve -I ../junk.cpio log/maillog log/messages run/"*"
cpio --extract --make-dir --unconditional --preserve -I ../junk.cpio log/maillog log/messages run/"*"

--------------
in a pipe
find . -depth -print0 | cpio -0o -Hnewc | rsh OTHER_MACHINE "cd `pwd` && cpio -i0dum"

-mount or -xdev to stay on the same filesystem
-mtime or -ctime for modify or change time in days...
i.e., find /u/bill -ctime +2 -ctime -6
list files in /u/bill that were last changed between 2 to 6 days ago
i.e., >2 and <6


or compare timestamps

touch -t 02010000 /tmp/timestamp
find /usr -newer /tmp/timestamp
rm -f /tmp/timestamp

-anewer -cnewer -newer


-------------------
     For example, to skip the directory `src/emacs' and all files and
     directories under it, and print the names of the other files found:

          find . -path './src/emacs' -prune -o -print


-----------------
     find /usr/local -type f -perm +a=x \
       \( -exec unstripped '{}' \; -fprint ubins -o -fprint sbins \)





