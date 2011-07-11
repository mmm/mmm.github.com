---
layout: post
title: git and bzr
tags: ['howto']
---

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

