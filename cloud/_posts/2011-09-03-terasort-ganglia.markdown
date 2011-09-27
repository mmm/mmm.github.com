---
layout: post
title: "Monitoring Hadoop Benchmarks TeraGen/TeraSort with Ganglia"
tags: ['cloud', 'hadoop', 'juju']
---

Here I'm using new features of
[Ubuntu Server](http://www.ubuntu.com/business/server/overview) 
(namely [Ubuntu juju](http://juju.ubuntu.com))
to easily deploy
[Ganglia](http://ganglia.sourceforge.net)
alongside
a small [Hadoop](http://hadoop.apache.org) cluster
to play around with monitoring some
[benchmarks](http://sortbenchmark.org/)
like
[Terasort](http://www.michael-noll.com/blog/2011/04/09/benchmarking-and-stress-testing-an-hadoop-cluster-with-terasort-testdfsio-nnbench-mrbench/).

## Short Story

Deploy hadoop and ganglia using juju:

    $ juju bootstrap
    $ juju deploy --repository "~/charms"  hadoop-master namenode
    $ juju deploy --repository "~/charms"  ganglia jobmonitor
    $ juju deploy --repository "~/charms"  hadoop-slave datacluster
    $ juju add-relation namenode datacluster
    $ juju add-relation jobmonitor datacluster
    $ for i in {1..6}; do
    $   juju add-unit datacluster
    $ done
    $ juju expose jobmonitor

When all is said and done (and EC2 has caught up),
run the jobs

    $ juju ssh namenode/0
    ubuntu@<ec2-url> $ sudo -su hdfs
    hdfs@<ec2-url> $ time hadoop jar hadoop-*-examples.jar teragen -Dmapred.map.tasks=8000 1000000000 in_dir
    hdfs@<ec2-url> $ hadoop job -history all in_dir
    hdfs@<ec2-url> $ time hadoop jar hadoop-*-examples.jar terasort -Dmapred.reduce.tasks=5300 in_dir out_dir
    hdfs@<ec2-url> $ hadoop job -history all in_dir

While these are running, we can run

    $ juju status

to get the URL for the jobmonitor ganglia web frontend

    http://<jobmonitor-instance-ec2-url>/ganglia/

and see...

<a href="/images/terasort-ganglia-1.png">
<img src="/images/terasort-ganglia-1.png" width="720px" />
</a>

and a little later as the jobs run...

<a href="/images/terasort-ganglia-2.png">
<img src="/images/terasort-ganglia-2.png" width="720px" />
</a>

Of course, I'm just playing around with ganglia at the moment...
For real performance, I'd change my juju config file
to choose larger (and ephemeral) EC2 instances instead of
the defaults.


## A Few Details...

Let's grab the charms necessary to reproduce this.

First, let's install juju and set up a repo for charms.

    $ sudo add-apt-repository ppa:juju/pkgs
    $ sudo apt-get install juju

Note that I'm describing all this using an Ubuntu laptop to run
the juju cli because that's how I roll, but you can certainly
use a Mac to drive your Ubuntu services in the cloud.
The juju CLI is already available in ports, but I'm not sure
the version.  Note to myself to add it to homebrew and do more
testing with that setup.
Windows should work too, but I don't have a clue.

    ~$ mkdir ~/charms
    ~$ cd ~/charms
    ~/charms$ git clone http://github.com/charms/ganglia
    ~/charms$ git clone http://github.com/charms/hadoop-master
    ~/charms$ git clone http://github.com/charms/hadoop-slave


That's about all that's really necessary to get you up and
benchmarking/monitoring.

I'll do another post on how to adapt your own charms to use monitoring
and the `monitor` juju interface as part of the "Core Infrastructure"
series I'm writing for charm developers.  Go over the process of
what I had to do to get the `hadoop-slave` service talking to the
`ganglia` service.

Until then, clone/test/enjoy... or better yet, fork/adapt/use!

