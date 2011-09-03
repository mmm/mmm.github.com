---
layout: post
title: "Monitoring Hadoop Benchmarks TeraGen/TeraSort with Ganglia"
tags: ['cloud', 'hadoop', 'ensemble']
---

Here I'm using new features of
[Ubuntu Server](http://www.ubuntu.com/business/server/overview) 
(namely [Ubuntu Ensemble](http://ensemble.ubuntu.com))
to easily deploy
[Ganglia](http://ganglia.sourceforge.net)
alongside
a small [Hadoop](http://hadoop.apache.org) cluster
to play around with monitoring some
[benchmarks](http://sortbenchmark.org/)
like
[Terasort](http://www.michael-noll.com/blog/2011/04/09/benchmarking-and-stress-testing-an-hadoop-cluster-with-terasort-testdfsio-nnbench-mrbench/).

## Short Story

Deploy hadoop and ganglia using ensemble:

    $ ensemble bootstrap
    $ ensemble deploy --repository "~/formulas"  hadoop-master namenode
    $ ensemble deploy --repository "~/formulas"  ganglia jobmonitor
    $ ensemble deploy --repository "~/formulas"  hadoop-slave datacluster
    $ ensemble add-relation namenode datacluster
    $ ensemble add-relation jobmonitor datacluster
    $ for i in {1..6}; do
    $   ensemble add-unit datacluster
    $ done
    $ ensemble expose jobmonitor

When all is said and done (and EC2 has caught up),
run the jobs

    $ ensemble ssh namenode/0
    ubuntu@<ec2-url> $ sudo -su hdfs
    hdfs@<ec2-url> $ hadoop jar hadoop-*-examples.jar teragen 100000000 in_dir
    hdfs@<ec2-url> $ hadoop job -history all in_dir
    hdfs@<ec2-url> $ hadoop jar hadoop-*-examples.jar terasort in_dir out_dir
    hdfs@<ec2-url> $ hadoop job -history all in_dir

While these are running, we can run

    $ ensemble status

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
For real performance, I'd change my ensemble config file
to choose larger (and ephemeral) EC2 instances instead of
the defaults.


## A Few Details...

Let's grab the formulas necessary to reproduce this.

First, let's install ensemble and set up a repo for formulas.

    $ sudo add-apt-repository ppa:ensemble/ppa
    $ sudo apt-get install ensemble

Note that I'm describing all this using an Ubuntu laptop to run
the ensemble cli because that's how I roll, but you can certainly
use a Mac to drive your Ubuntu services in the cloud.
The Ensemble CLI is already available in ports, but I'm not sure
the version.  Note to myself to add it to homebrew and do more
testing with that setup.
Windows should work too, but I don't have a clue.

    ~$ mkdir ~/formulas
    ~$ cd ~/formulas
    ~/formulas$ git clone http://github.com/mmm/ensemble-ganglia ganglia
    ~/formulas$ git clone http://github.com/mmm/ensemble-hadoop-master hadoop-master
    ~/formulas$ git clone http://github.com/mmm/ensemble-hadoop-slave hadoop-slave


That's about all that's really necessary to get you up and
benchmarking/monitoring.

I'll do another post on how to adapt your own formulas to use monitoring
and the `monitor` ensemble interface as part of the "Core Infrastructure"
series I'm writing for formula developers.  Go over the process of
what I had to do to get the `hadoop-slave` service talking to the
`ganglia` service.

Until then, clone/test/enjoy... or better yet, fork/adapt/use!

