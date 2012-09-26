---
layout: post
title: "LinuxPlumbers and Juju"
tags: ['cloud', 'production', 'juju']
---

Hey, so last month we ran scheduling for the 
[Linux Plumbers Conference](http://linuxplumbersconf.org)
entirely on juju!

Here's a little background on the experience.


## The Scheduling Stack

So [summit](https://launchpad.net/summit) is this great django app built for
scheduling conferences.  It's evolved over time to handle
[UDS](uds.ubuntu.com)-level traffic and is currently maintained by a
[Summit Hackers](https://launchpad.net/~summit-hackers) team that includes
[Chris Johnston](www.google.com) and [Michael Hall](www.google.com).

Chris contacted me to help him use juju to manage summit for this year's
Plumbers conference.  At the time the oneiric version of juju wasn't quite
blessed for production environments, but we figured it'd be a great opportunity
to try things out.

We forked [Michael Nelson](www.google.com)'s excellent
[django charm](lp:~michael.nelson/charms/oneiric/apache-django-wsgi/trunk)
to create a
[summit-charm](https://code.launchpad.net/~mark-mims/charms/oneiric/summit/trunk)
and freely specialized it for summit.  Note that we're updating this for precise
[here](https://code.launchpad.net/~mark-mims/charms/precise/summit/trunk), but
this will probably go away in favor of just using a generic django charm.  It
turns out we didn't do too much here that won't apply to django apps in
general, but I'll go over that more later.


### Services

A typical summit stack's got postgresql, the django app itself, and a memcached server.

[ picture ]

We additionally talked about putting this all behind some sort of a head like haproxy.

[ picture ]

This'd let the app scale horizontally as well as give us a stable point to
attach an elastic-ip.  We decided to not do this at the time b/c caching select
snippets into memcached meant we wouldn't likely need an additional django node
to handle the conference load.

This turned out to be true load-wise, but it really would've been a whole lot
easier to have a nice constant haproxy node out there to tack the elastic-ip
to.  During development (charm, app, and theme) you want the freedom to destroy
a service and respawn it without having to use external tools to go around and
attach public IP addresses to the right places.  That's a pain.


[ diff focus of ephemeral instances... throw stuff away... means problems with elastic-ips ]
[ problems with elastic ips ]



## Juju in Production

We chose to use ec2 to host the summit stack... mostly a matter of
convenience.  The juju openstack-native provider wasn't completed when we spun
up the production environment for linuxplumbers and we didn't have access to a
stable private ubuntu cloud running the openstack-ec2-api at the time.
All of this has subsequently landed, so we'd have more options today.

### a control environment

We had multiple people to manage the production summit environment.  What's the
best way to do that?  It turns out juju supports this pretty well right out of
the box.  There's an environment config for the set of ssh public keys to
inject into everything in the environment as it starts up.

Note that this is only useful to configure at the beginning of the stack.  Once
you're up, adding keys is problematic.  I don't even recommend trying b/c of
the risk of getting undetermined state for the environment.  i.e., different
nodes with different sets of keys depending on when you changed the keys relative
to what actions you've performed on the environment.  It's a problem.

What I recommend now is actually to use _another_ juju environment...  (and no,
I'm not paid to promote cloud providers by the instance :) ) a dedicated
"control" environment.  I bootstrap it, then set up a juju client that controls
the main production environment.  Then set up a shared tmux session that any of
the admins for the production environment can use.  Adding/changing the set of
admin keys is then done in a single place.  This technique isn't strictly
necessary, but it was certainly worth it here with different admins having
various different levels of familiarity with the tools.  I started it as a
teaching tool, left it up because it was an easy control dashboard, and now
recommend it because it works so well.


### it's chilly in here

freezing the code.  Yeah, so during development you break things.  There were a
couple of times using oneiric juju that changes to juju core prevented a client
from talking to an existing stack.  Aargh!  This wasn't going to fly for
production use.  We've subsequently done a _bunch_ to prevent this from
happening, but we needed production summit stable at the time.  The answer... freeze the
code.  Juju has an environment config option `juju-origin` to specify where to
get the juju installed on all instances in the environment.  I branched juju
core to `lp:~mark-mims/juju/running-summit` and just worked straight from there
for the lifetime of the environment (still up atm).

Ok, that's easy enough.  Well, the tricky part is to make sure that you're
always using the `lp:~mark-mims/juju/running-summit` version of the juju cli
when talking to the production summit environment.

I set up

    #!/bin/bash
    export JUJU_BRANCH=/home/ubuntu/src/juju/running-summit
    export PATH=$JUJU_BRANCH/bin:$PATH
    export PYTHONPATH=$JUJU_BRANCH

which my tmuxinator config sources into every pane in my `summit` tmux session.
This was also done on the `summit-control` instance so it's easy to make sure
we're all using the right version of the juju cli to talk to the production
environment.



### backups

The `juju ssh` subcommand to the rescue.  You can do all your standard ssh
tricks...

    juju ssh postgresql/0 'su postgres pg_dump summit' > summit.dump

... on a cronjob.  Juju just stays out of the way and just helps out a bit with
the addressing.  Real version pipes through bzip2 and adds timestamps of course.


Of course snapshots are easy enough too via euca2ools, but the pgsql dumps
themselves turned out to be more useful for maintaining data integrety for a
failover.


### logging

### monitoring

### spare environment for fallback



## Lessons Learned

What would I do differently next time?  Well, I've got a list :).

use stable ppa... instead of freezing!
- we now have a private ubuntu cloud that should work great for this kind of app
Additionally, it should probably sit behind some sort of a head like haproxy.
better backups straight to S3
better monitoring
failover/DR



