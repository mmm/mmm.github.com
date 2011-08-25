---
layout: post
title: "Core Infrastructure Part 1 - Adding NFS to Ensemble Formulas"
tags: ['cloud', 'ensemble']
---

Several features have recently landed in Ensemble that make 
it easier to convert some common infrastructure-level components 
over and use them within your stack of services.
I figured it's worth a series of posts about core services,
storage, logging, monitoring, messaging, etc...  and how they
fit into the ensemble ecosystem.

We'll start with NFS.  I'd consider that vanilla workhorse to be
core infrastructure technology... it's still pretty much everywhere you
look.  Many friends keep ancient boxes around as dedicated NFS 
fileserver appliances that are usually in fairly critical roles.
Well, how would this fit into a sexy new ensemble of services?


## The Goal

In this post I'll walk through adapting a basic mediawiki
formula to enable using nfs mounts for shared resource directories.

At the end of the day, an example stack might look something like 

    $ ensemble bootstrap
    $ ensemble deploy --repository=~/formulas nfs myimages
    $ ensemble deploy --repository=~/formulas mysql
    $ ensemble deploy --repository=~/formulas mediawiki mywiki
    $ ensemble add-relation mysql:db mywiki:db
    $ ensemble add-relation myimages mywiki

which will result in a mediawiki setup with `images`
stored on an nfs server.

As expected,

    $ ensemble add-unit mywiki
    $ ensemble add-unit mywiki

will scale mediawiki instances.

Since the `mywiki`
service is related to the `myimages` service,
then all `mywiki` instances will share the same
resource directory on the nfs server.  This works
months into the deployment... we add another unit
and the relation hooks perform the mount.

The nfs server formula is pretty canned, it'll take 
config options, but has sane defaults.  There's 
little need to adjust anything in there.

To adapt your formula to use an ensemble-managed
NFS service, we copy two hooks from an nfs-client
example formula and adapt to suit the needs of
the formula we're working on (mediawiki in this
example).


## Detailed walk-through

Let's go through this process of adapting our formulas
to use NFS mounts.


### The Problem

Start with a simple mediawiki deploy,

    $ ensemble bootstrap
    $ ensemble deploy --repository=~/formulas mysql
    $ ensemble deploy --repository=~/formulas mediawiki mywiki
    $ ensemble add-relation mysql:db mywiki:db

With ensemble, it's easy to spin up multiple mediawiki
instances (or "service units" in ensemble-speak).

    $ ensemble add-unit mywiki
    $ ensemble add-unit mywiki

Now, since the `mywiki` service is related to the `mysql` service,
then all these mywiki units share the same database and hence
content.  Groovy.

Ok, well there's a problem.  Each wiki instance has its
own filesystem-store for various things... images, uploads, etc.
This is pretty common practice across different CMSes that
results in scaling pain.
The content in the database will point to resources that
only exist on one of the instances.

### The Solution

A common solution to this
is to just put these resource directories on a fileserver and
share them out to each of the wiki instances using NFS.

This, of course, isn't limited to content management
systems.  Just about every infrastructure has some sort of need
for shared storage.

Ubuntu packages for mediawiki install mediawiki's resource
directories with respect to `/var/lib/mediawiki/`.
So let's just set adapt the basic mediawiki formula to use
an nfs share for `/var/lib/mediawiki/images`.

Each mediawiki
service unit has a `/var/lib/mediawiki/images` directory
that points to 
up multiple mediawiki instances, they'll all share the
same `images` directory.

### Copy code examples over as a template

Let's grab some code and get cranking...

First, pull mediawiki as an example (or any formula you're
currently working on that might need shared storage)

    git clone http://github.com/mmm/ensemble-mediawiki -b nfsdemo mediawiki

This gives us

    /home/mmm/formulas/mediawiki
    |-- copyright
    |-- hooks
    |   |-- ...
    |   |-- db-relation-changed
    |   |-- install
    |   |-- start
    |   |-- stop
    |   |-- website-relation-changed
    |   |-- website-relation-joined
    |   `-- ...
    `-- metadata.yaml

a bare mediawiki formula that we can use as a starting
point to add our nfs client hooks.
Note this is an 'nfsdemo' branch just for this demo... the real
mediawiki formula should now have nfs support in the trunk.

Now, we can copy sample nfs client hooks from

    http://github.com/mmm/ensemble-nfs-client/tree/master/hooks

Grab `storage-relation-joined` and `storage-relation-changed`, 
and save them as mediawiki hooks... I'd rename them to something
that makes sense to future readers of our mediawiki formula.
Let's call them `nfs-imagestore-relation-joined` and 
`nfs-imagestore-relation-changed`.


### Adapt the example code to our formula

Let's look at the
`nfs-imagestore-relation-joined` hook:

    #!/bin/bash
    set -ue

    apt-get install -y nfs-common

    sed -i -e "s/NEED_IDMAPD.*/NEED_IDMAPD=yes/" /etc/default/nfs-common
    service idmapd restart || service idmapd start

    relation-set client=`hostname -f`


This looks pretty normal.
It installs some stuff nfs stuff when the relation is joined...
this is good it doesn't really install it until it's needed.
Then it tells the nfs server who we are for access control.
Ok, so no changes need to be made to get this working
on our mediawiki service unit... we can leave it as-is.

Next, what about the `nfs-imagestore-relation-changed` hook?

    #!/bin/bash
    set -ue

    remote_host=`relation-get hostname`
    if [ -z "$remote_host" ] ; then
        ensemble-log "remote host not set yet."
        exit 0
    fi
    export_path=`relation-get mountpoint`
    fstype=`relation-get fstype`

    local_mountpoint=`config-get mountpoint`
    local_owner=`config-get owner`
    mount_options=""

    create_local_mountpoint() {
      ensemble-log "creating local mountpoint"
      umask 002
      mkdir -p $local_mountpoint
      # create owner if necessary?
      chown -f $local_owner.$local_owner $local_mountpoint
    }
    [ -d $local_mountpoint ] || create_local_mountpoint 

    share_already_mounted() {
      `mount | grep -q $local_mountpoint`
    }
    mount_share() {
      for try in {1..3}; do

        ensemble-log "mounting nfs share"
        [ ! -z $mount_options ] && options="-o ${mount_options}" || options=""
        mount -t $fstype $options $remote_host:$export_path $local_mountpoint \
          && break

        ensemble-log "mount failed: $local_mountpoint"
        sleep 10

      done
    }
    share_already_mounted || mount_share 

    # ownership
    chown -f $local_owner.$local_owner $local_mountpoint

Ok, when parameters used within formula hooks are likely to change
from one service deployment to the next, they can be externalized
into a `config.yaml` for the formula.  This also allows you to
pass them in at deploy-time or change them throughout the lifetime
of the service using ensemble cli `--config` options and `set`
commands.  See the [docs](http://ensemble.ubuntu.com/docs/) for
how to do all of this.

There are two parameters in the `nfs-imagestore-relation-changed`
hook that are set using `config-get`:

    local_mountpoint=`config-get mountpoint`
    local_owner=`config-get owner`

Well, for mediawiki
these parameters aren't really going to change.  It's reasonable
to just hard-code them here as:

    mw_root="/var/lib/mediawiki"
    local_mountpoint="$mw_root/images"
    local_owner="www-data"

We could certainly just add these parameters to a `config.yaml`
for the mediawiki formula, but in this case, they're not really
interesting "tweakable" aspects of the mediawiki formula, so let's
keep the mediawiki config simple.
For other formulas this might not be the case,
but make that call in context.

Now, at this point, our version of the `nfs-imagestore-relation-changed`
hook:

    #!/bin/bash
    set -ue

    remote_host=`relation-get hostname`
    if [ -z "$remote_host" ] ; then
        ensemble-log "remote host not set yet."
        exit 0
    fi
    export_path=`relation-get mountpoint`
    fstype=`relation-get fstype`

    mw_root="/var/lib/mediawiki"
    local_mountpoint="$mw_root/images"
    local_owner="www-data"
    mount_options=""

    create_local_mountpoint() {
      ensemble-log "creating local mountpoint"
      umask 002
      mkdir -p $local_mountpoint
      # create owner if necessary?
      chown -f $local_owner.$local_owner $local_mountpoint
    }
    [ -d $local_mountpoint ] || create_local_mountpoint 

    share_already_mounted() {
      `mount | grep -q $local_mountpoint`
    }
    mount_share() {
      for try in {1..3}; do

        ensemble-log "mounting nfs share"
        [ ! -z $mount_options ] && options="-o ${mount_options}" || options=""
        mount -t $fstype $options $remote_host:$export_path $local_mountpoint \
          && break

        ensemble-log "mount failed: $local_mountpoint"
        sleep 10

      done
    }
    share_already_mounted || mount_share 

    # insure ownership
    chown -f $local_owner.$local_owner $local_mountpoint


will run fine.  It'll mount the `images` share and mediawiki
will run normally.


### Additional configuration

This next step depends greatly on your particular formula/service.
With mediawiki, the `images` directory isn't really used until
you tell mediawiki to turn on uploads.  This is true regardless
of whether `images` is an nfs mount or you're just using the
directory on the local filesystem.

The time to do this though is after the `images` share is mounted, 
so putting it in the `nfs-imagestore-relation-changed` hook after
the mount is a good place for it.

    mediawiki_installed() {
      [ -d "$mw_root/config" ]
    }
    enable_mediawiki_uploads() {
      ensemble-log "updating mediawiki config"
      sed -i 's/$wgEnableUploads.*/$wgEnableUploads = true;/' $mw_root/config/LocalSettings.php
      service apache2 status && service apache2 restart
    }
    mediawiki_installed && enable_mediawiki_uploads

So we end up with

    #!/bin/bash
    set -ue

    remote_host=`relation-get hostname`
    if [ -z "$remote_host" ] ; then
        ensemble-log "remote host not set yet."
        exit 0
    fi
    export_path=`relation-get mountpoint`
    fstype=`relation-get fstype`

    mw_root="/var/lib/mediawiki"
    local_mountpoint="$mw_root/images"
    local_owner="www-data"
    mount_options=""

    create_local_mountpoint() {
      ensemble-log "creating local mountpoint"
      umask 002
      mkdir -p $local_mountpoint
      # create owner if necessary?
      chown -f $local_owner.$local_owner $local_mountpoint
    }
    [ -d $local_mountpoint ] || create_local_mountpoint 

    share_already_mounted() {
      `mount | grep -q $local_mountpoint`
    }
    mount_share() {
      for try in {1..3}; do

        ensemble-log "mounting nfs share"
        [ ! -z $mount_options ] && options="-o ${mount_options}" || options=""
        mount -t $fstype $options $remote_host:$export_path $local_mountpoint \
          && break

        ensemble-log "mount failed: $local_mountpoint"
        sleep 10

      done
    }
    share_already_mounted || mount_share 

    # insure ownership
    chown -f $local_owner.$local_owner $local_mountpoint

    mediawiki_installed() {
      [ -d "$mw_root/config" ]
    }
    enable_mediawiki_uploads() {
      ensemble-log "updating mediawiki config"
      sed -i 's/$wgEnableUploads.*/$wgEnableUploads = true;/' $mw_root/config/LocalSettings.php
      service apache2 status && service apache2 restart
    }
    mediawiki_installed && enable_mediawiki_uploads


the same hook that's in `master` on `http://github.com/mmm/ensemble-mediawiki`.


### Update formula metadata

So we have hooks that should do what we'd like... 
(I'll developing and debugging hooks in another post).
Next we need to update the formula metadata so ensemble
knows when to fire them.

My `mediawiki/metadata.yaml` currently looks like

    ...
    requires:
      db:
        interface: mysql
      slave:
        interface: mysql
      cache:
        interface: memcache
    provides:
      website:
        interface: http
    ...

let's add our nfs requirement (_requirement_ is a strong word... they're
all optional),

    ...
    requires:
      db:
        interface: mysql
      slave:
        interface: mysql
      cache:
        interface: memcache
      nfs-imagestore:
        interface: mount
    provides:
      website:
        interface: http
    ...

The relation name's gotta match up with what we called the hooks.
I got the interface name from the nfs server formula's metadata:

    ...
    provides:
      nfs:
        interface: mount
    ...

which provides the [mount interface](http://ensemble.ubuntu.com/Interfaces/mount).

We can use the interface as a sanity check to insure we're providing
and using the right parameters when communicating with the nfs server
service (using `relation-get` and `relation-set`) in our hooks.


### Spin it up

Let's deploy our new formula:

    $ ensemble bootstrap
    $ ensemble deploy --repository=~/formulas nfs myimages
    $ ensemble deploy --repository=~/formulas mysql
    $ ensemble deploy --repository=~/formulas mediawiki mywiki
    $ ensemble add-relation mysql:db mywiki:db
    $ ensemble add-relation myimages mywiki
    $ ensemble expose mywiki

### Spread it out

Add a few more mediawiki instances...

    $ for i in {1..10}; do
    $ ensemble add-unit mywiki
    $ done

When everything's up, these should all share the same database
and image store.

In real life you'd probably want to start adding mysql slaves
to this.  Of course, in real life you'll also add remote logging,
monitoring, and other core infrastructure components too.
Keep an eye out for subsequent posts in this series.


### NFS server config

Up until now we've only talked about the NFS client.
The NFS *server* formula is pretty simple.

It lives at
[lp:principia/nfs](http://bazaar.launchpad.net/~ensemble-composers/principia/oneiric/nfs/trunk/files)
(or
[github.com/mmm/ensemble-nfs](http://github.com/mmm/ensemble-nfs)),
and supports configuration options at deploy(or run)-time via

    $ ensemble deploy --repository . --config ./mydata.yaml nfs mydata

where `mydata.yaml` looks like

    mydata:
      initial_daemon_count: 43
      storage_root: /srv/mydata
      export_options: rw,sync,no_root_squash,no_all_squash


### What's left?

This might not be an ideal NFS setup for your particular service.
What are some other ways we can tweak this?

Currently, the nfs server creates a separate share for each named service
that attaches to it.

We deployed mediawiki as `mywiki`, so all `mywiki` service units would
share an export.  Well, you could deploy another mediawiki service unit
called `someotherwiki` and all service units of `someotherwiki` would
share a different export.  The new export is created on the service when
the first unit of a new service name joins... subsequent units of that named
service are just connected to that new export.

Of course, this works for entirely separate services too.  Relating a 
`hadoop-master` service named `job27` to that same nfs service would result in 
the `job27` units sharing a new nfs export.

This behavior is a reasonable default, but there may be a need to do this a 
little differently in your infrastructure.  You could change the nfs server
formula to provide different levels of export sharing... either by some
additional `config.yaml` entries or by extending the `mount` interface.
An nfs client might request a unique export, for backups
say, or a named export for sharing.
