---
layout: post
title: git and bzr
categories: howtos
comments: true
---


---

# update

Some tools from this were broken... got a decent set of revisions working... yay!

Grab and install the following:

## git-bzr-ng

    git clone http://github.com/termie/git-bzr-ng.git
    (working HEAD was 280eba)

Now install

    cd /usr/local/bin
    sudo ln -s ../src/git-bzr-ng/git-bzr-ng git-bzr

## bzr-fastimport
  
    bzr branch lp:bzr-fastimport -r327

Now install.  
I know there're much better ways to do this...
I'm just capturing what I did to get it to work

    cd bzr-fastimport
    sudo ./setup.py install
    mv /usr/local/lib/python2.7/dist-packages/bzr-fast"*" /usr/lib/python2.7/dist-packages/
    mv /usr/local/lib/python2.7/dist-packages/bzrlib/plugins/fastimport /usr/lib/python2.7/dist-packages/bzrlib/plugins/

---

# original post

from http://wiki.openstack.org/GitBzrInstructions

on Ubuntu/Debian:

    apt-get install git-core bzr bzr-fastimport; 
    git clone git://github.com/kfish/git-bzr
    cd git-bzr
    sudo cp git-bzr /usr/local/bin

Using git-bzr:

An example session goes like this:

    $ git init
    $ git bzr add upstream ../bzr-branch
    $ git bzr fetch upstream
    $ git checkout -b local_branch upstream
    $ Hack hack, merge merge....

    $ git bzr push upstream

see also http://doc.bazaar.canonical.com/migration/en/survival/bzr-for-git-users.html

