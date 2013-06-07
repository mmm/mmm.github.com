---
layout:post
title: $i
tags: ["howto"]
---


on hawk (git version 1.5+)

part A:
mkdir repo.git
cd repo.git
git --bare init
cd ..
rsync -avP repo.git phantom:/git/destination

from hawk,
git clone phantom:/git/destination/repo.git <local dir name if other than "repo">

then do pulls/pushes as necessary to update the repository


doesn't seem to work right now...
ok, let's try:

do part A again,
then from a local repo
git push --all <remote_url>
git remote add origin <remote_url>

--or--

git config branch.master.remote 'origin'
git config branch.master.merge 'refs/heads/master'
git push origin master:refs/heads/master


then from another location, 
git clone <remote_url>
don't get all the remote branches though... ugh

just do all of this shit _before_ creating any branches!



--------

so, I've been just
doing part A,
followed by:
git config branch.master.remote 'origin'
git config branch.master.merge 'refs/heads/master'
git push origin master:refs/heads/master


and then clone from other machine.


-----


git push origin redirect:refs/heads/redirect
seemed to create the remote branch

then on the second workstation,
git branch --track redirect refs/remotes/origin/redirect
created a local version of the branch that tracks the remote one 
(there were various fetches and pulls in here)
use gitk --all to see the status of each workstation

------

git checkout --track -b redirect origin/redirect
works on the secondary workstations as well.
