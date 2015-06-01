---
layout: post
title: "Working with upstreams"
date: 2015-06-01 13:57
comments: true
categories: 
---

Starting to collect notes to help first-time contributors work with open source
projects.

These are quite rough atm, but I'll flesh them out as I get time.

## Contents

- Upstream of What?
- Issues
- Repo Management
- Pull Requests
- Programming Style

<!--more-->


## Upstream of What?

- [TODO] define / describe
- [TODO] advice on compatibility


## Issues

- [TODO] basic ticket management
- [TODO] too many ticketing systems
- [TODO] starter tickets
- [TODO] advice


## Repo Management

Start with an upstream...

    https://github.com/apache/spark

Fork this on github through the gui...

    git@github.com:mmm/spark.git

Clone this locally

    git clone git@github.com:mmm/spark
    cd spark

verify you can push and pull accordingly

    git pull
    git push

and check the remote

    git remote -v

Now, add upstream to the same repo:

    git remote add upstream https://github.com/apache/spark
    git remote -v

Periodically, pull any changes from upstream

    git fetch upstream

or 

    git fetch -all

or

    git pull --all

is usually what I do.

Now, merge any upstream changes into your local `master`

    git checkout master
    git merge upstream/master

Then push this back up to your fork

    git push 

which should work as shorthand for 

    git push origin master


- [TODO] more "advice"



## Pull Requests

Example of a PR from a feature branch on a fork.

    git checkout master
    git pull --all

Create a new feature branch

    git checkout -b add-install-notes

Write code... commit code

    vi README.md
    git commit -a -m'added install notes to the project readme'
    
push that feature branch up to github...

    git push origin add-install-notes

Now, the easiest thing to do is go to your fork on github
and click the button to create a new pull request against the
original project... in this case, we'd be 



Note that some projects give you direct push rights to a repo.  When several
people use feature branches on the same common repository, it's a common
practice to namespace the feature branches with user names... so instead of a
branch named `add-install-notes` I'd call it `mmm-add-install-notes`.


- [TODO] more "advice"


## Style

- [TODO] project style guidelines are important


