---
layout: post
title: "Scaling Juju: manage a 2000-node cluster in EC2"
tags: ['cloud', 'hadoop', 'juju']
---
 
  -Lately we've been fleshing out our testing frameworks for Juju and Juju Charms.  There's
  -lots of great stuff going on here, so I figured it's time to start shouting out about it.
   
   -First off, the coolest thing we did during last month's Ubuntu Developer Summit (UDS)
   -was get the go-ahead to spend more time/effort/money scale-testing Juju.




When it comes to big data, there is no small. You need to go big or go home, after all a tool isn’t useful if it doesn’t scale to meet your needs. When it comes to tools like Hadoop jobs, we’re talking in the hundreds and thousands, not a few dozen.

So recently we’ve been putting juju through scaling paces to see how we can manage these sorts of workloads. We decided to fire up 2,000 hadoop nodes in Amazon’s ec2  Web Service to see how that would look. So Mark Mims set out to make this happen as an example on how you can deploy Hadoop on AWS with Ubuntu Server. Mark has extensive experience with big data, so he put this expertise to work with James Page, Ben Howard, and Kapil Thangavelu lending their support and recommendations. 

Go big or go home, indeed! So how did we do? 

Initial deployment

As we’re on a public cloud we typically want to scale up gradually, so this is the approach we took. It’d be a shame to spend money on 2,000 instances and then find out you have a simple problem. Also when you are doing things like this you will need to work with your AWS representative ahead of time and they will work with you on getting you the capacity you need.  And we know that juju makes scaling Hadoop straight forward, so we started off with 40 instances.








## The Plan

- spin up and manage a cluster of this service in such a way that engages all nodes in the cluster
  - instrument
  - profile
  - optimize
  - grow

We started with 40 nodes and iterated up 100, 500, 1000 and 2000.  Here're the notes on the process.

## Hadoop

Hadoop was a pretty obvious choice here.
It's a great actively-maintained
[project](http://hadoop.apache.org/)
with a large community of users.
It scales in a somewhat known manner, and the
[hadoop charm](http://jujucharms.com/charms/precise/hadoop)
makes it super-simple to manage.
There are also several known benchmarks that are pretty straightforward to get going,
and distribute load throughout the cluster.

There's an entire science/art to tuning hadoop jobs to run optimally given the 
characteristics of a particular cluster.  Our sole goal in tuning hadoop benchmarks
was to _engage_ the entire cluster and profile juju during various activities throughout
an actual run.  For our purposes, we're in no hurry... a slower/longer run gives us a
good profiling picture for managing the nodes themselves under load (with a sufficient
mix of i/o -vs- cpu load).

## EC2

Surprisingly enough, I don't really have that many servers just lying around... so EC2 to the rescue.

Disclaimer... we're testing our infrastructure tools here, not benchmarking hadoop in EC2.
Some folks advocate running hadoop in a cloudy virtualized environment... while some
folks are die-hard server huggers.  That's actually a really interesting discussion.
It comes down to the actual jobs/problems you're
trying to solve and how those jobs fit in your data pipeline.
Please note that we're not
trying to solve that problem here or even provide realistic benchmarking data to contribute
to the discussion... we're simply testing how our infrastructure tools perform at scale.

If you _do_ run hadoop in EC2, Amazon's Elastic Map Reduce service is likely to perform
better at scale in EC2 than just running hadoop itself on general purpose instances.
Amazon can do all sorts of stuff internally to show hadoop lots of love.
We chose not to use EMR because we're interested in testing how juju performs
with _generic_ Ubuntu Server images, not EMR... at least for now.

Note that stock EC2 accounts limit you to 20 instances.  To grow beyond that, you have to
call AWS to get your limits bumped up.


## Juju

We started scale testing from a fresh branch of juju trunk... what gets deployed to
the PPA nightly... this freed us up to experiment with live changes to add instrumentation,
profiling information, and randomly mess with code as necessary.  This also locks in 
the branch of juju that the scale testing environment uses.  Also a best practice
for running long-term environments in juju.

As usual, juju will keep track of the state of our infrastructure going forward and
we can make changes as necessary via juju commands.  To bootstrap and spin up the
initial environment we'll just use shell scripts.

### Spinning up a cluster

These scripts are really just
hadoop versions of my standard juju demo scripts such as those used for 
a simple [rails stack](https://gist.github.com/2050525)
or an HA [wiki stack](https://gist.github.com/1406018).

The hadoop scripts for EC2 will get a little more complex as we grow simply because
we don't want AWS to think we're a DoS attack... we'll pace ourselves during spinup.

From the hadoop charm's readme, the basic steps to spinning up a simple combined
hdfs and mapreduce cluster are:

    juju bootstrap

    juju deploy hadoop hadoop-master
    juju deploy -n3 hadoop hadoop-slavecluster

    juju add-relation hadoop-master:namenode hadoop-slavecluster:datanode
    juju add-relation hadoop-master:jobtracker hadoop-slavecluster:tasktracker

which we expand on a bit to get:

    #!/bin/bash

    juju_env=${1:-"-escale"}
    juju_root="/home/ubuntu/scale"
    juju_repo="$juju_root/charms"

    [ -f $juju_root/etv/scale-environment ] && . $juju_root/etc/scale-environment && echo "using juju found at `which juju`"

    ############################################

    timestamp() {
      date +"%G-%m-%d-%H%M%S"
    }

    deploy_monitor() {
      local monitor_name=$1
      juju deploy $juju_env --repository $juju_repo local:ganglia $monitor_name
      juju expose $juju_env $monitor_name
    }

    current_load() {
      juju ssh $juju_env 0 "ps -ef | grep juju.agents.provision | grep -v grep | awk '{ print \$2 }' | xargs top -b -n1 -p | grep python | awk '{ print \$9 }'"
    }

    wait_for_load_to_clear() {
      local target_load=90

      #local i=0
      #while (( $(current_load) <= $target_load )) && [ -z "$timeout" ]; do
      #  sleep 120
      #done
    }

    add_units_when_load_clears() {
      local num_units=$1
      local service_name=$2

      echo "waiting for load to clear"
      #if load_is_below 90; then
      #fi
      #wait_for_load_to_clear 90

      echo "sleeping"
      sleep 120

      echo "adding another $num_units units at $(timestamp)"
      juju add-unit $juju_env -n $num_units $service_name
    }

    deploy_slaves() {
      local cluster_name=$1
      local slave_config="$juju_root/etc/hadoop-slave.yaml"
      local slave_size="instance-type=m1.medium"
      local slaves_at_a_time=99
      #local num_slave_batches=10

      juju deploy $juju_env --repository $juju_repo --constraints $slave_size --config $slave_config -n $slaves_at_a_time local:hadoop ${cluster_name}-slave
      echo "deployed $slaves_at_a_time slaves"

      juju add-relation $juju_env ${cluster_name}-master:namenode ${cluster_name}-slave:datanode
      juju add-relation $juju_env ${cluster_name}-master:jobtracker ${cluster_name}-slave:tasktracker

      for i in {1..9}; do
        add_units_when_load_clears $slaves_at_a_time ${cluster_name}-slave
        echo "deployed $slaves_at_a_time slaves at $(timestamp)"
      done
    }

    deploy_cluster() {
      local cluster_name=$1
      local monitor_name=$2
      local master_config="$juju_root/etc/hadoop-master.yaml"
      local master_size="instance-type=m1.large"

      juju deploy $juju_env --repository $juju_repo --constraints $master_size --config $master_config local:hadoop ${cluster_name}-master

      deploy_slaves ${cluster_name}

      juju expose $juju_env ${cluster_name}-master

      [ -z "$monitor_name" ] || juju add-relation $juju_env ${cluster_name}-slave $monitor_name
    }

    main() {
      echo "deploying stack at $(timestamp)"

      juju bootstrap $juju_env --constraints="instance-type=m1.xlarge"

      #deploy_monitor monitor

      sleep 120
      #deploy_cluster hadoop monitor
      deploy_cluster hadoop

      echo "done at $(timestamp)"
    }
    main $*
    exit 0

and which we adjust the sizes manually for each cluster.


### Configuring Hadoop

Note that we're specifying constraints to tell juju to use an m1.large for the
hadoop master and m1.mediums for the slaves.

    juju deploy ... --constraints "instance-type=m1.large" ... hadoop-master

and pass config files to specify different heap sizes

    juju deploy ... --config "hadoop-master.yaml" ... hadoop-master

where `hadoop-master.yaml` looks like

    # m1.large
    hadoop-master:
      heap: 2048
      dfs.block.size: 134217728
      dfs.namenode.handler.count: 20
      mapred.reduce.parallel.copies: 50
      mapred.child.java.opts: -Xmx512m
      mapred.job.tracker.handler.count: 60
    #  fs.inmemory.size.mb: 200
      io.sort.factor: 100
      io.sort.mb: 200
      io.file.buffer.size: 131072
      tasktracker.http.threads: 50
      hadoop.dir.base: /mnt/hadoop

and

    juju deploy ... --config "hadoop-slave.yaml" ... hadoop-slave

where `hadoop-slave.yaml` looks like

    # m1.medium
    hadoop-slave:
      heap: 1024
      dfs.block.size: 134217728
      dfs.namenode.handler.count: 20
      mapred.reduce.parallel.copies: 50
      mapred.child.java.opts: -Xmx512m
      mapred.job.tracker.handler.count: 60
    #  fs.inmemory.size.mb: 200
      io.sort.factor: 100
      io.sort.mb: 200
      io.file.buffer.size: 131072
      tasktracker.http.threads: 50
      hadoop.dir.base: /mnt/hadoop



## 40 nodes and 100 nodes

Both the 40-node and 100-node runs went as smooth as silk.
The only thing to note was that it took a while to get AWS to increase
our limits to allow for 100+ nodes in one availability zone.


## 500 nodes

Once we had permission from Amazon to spin up 500 nodes on our account,
we initially just naively spun
up 500 instances... and quickly got throttled by ec2.
(we're not using multiplicity in the ec2 api, nor are we using an autoscaling
group)... we must look like a DoS attack.
The order was eventually fulfilled, but long spin-up time overall.

Deployment took about an hour and 15 minutes.

The job script used was

    #!/bin/bash

    SIZE=10000000000
    NUM_MAPS=1500
    NUM_REDUCES=1500
    IN_DIR=in_dir
    OUT_DIR=out_dir

    hadoop jar /usr/lib/hadoop/hadoop-examples*.jar teragen -Dmapred.map.tasks=${NUM_MAPS} ${SIZE} ${IN_DIR}

    sleep 10

    hadoop jar /usr/lib/hadoop/hadoop-examples*.jar terasort -Dmapred.reduce.tasks=${NUM_REDUCES} ${IN_DIR} ${OUT_DIR}

which engaged the entire cluster just fine, gave almost 200TB of HDFS
storage

<a href="/images/scale-500-50070.png">
<img src="/images/scale-500-50070.png" width="720px" />
</a>

and ran terasort with no problems

<a href="/images/scale-500-50030.png">
<img src="/images/scale-500-50030.png" width="720px" />
</a>


## 1000 nodes

To get around the api throttling, we start up
batches of 99 slaves at a time with a 2-minute wait
between each batch.

The job was run with

    SIZE=10000000000
    NUM_MAPS=3000
    NUM_REDUCES=3000

which gave almost 350TB of HDFS storage

<a href="/images/scale-1000-50070.png">
<img src="/images/scale-1000-50070.png" width="720px" />
</a>

and eventually completed

<a href="/images/scale-1000-50030.png">
<img src="/images/scale-1000-50030.png" width="720px" />
</a>



python to serialize yaml in zk... switched to json with considerable speedup.



## 2000 nodes

again, batches of 99 w/2-minute waits between

removed more yaml from zk

slow job run.. with our naive job config, we're considerably past the point of diminishing returns for chattiness in ec2.

This gave almost 760TB of HDFS storage

<a href="/images/scale-2000-50070.png">
<img src="/images/scale-2000-50070.png" width="720px" />
</a>

and was running fine

<a href="/images/scale-2000-50030.png">
<img src="/images/scale-2000-50030.png" width="720px" />
</a>

but was stopped early b/c waiting would've just been wasteful.


## Lessons Learned

- streamline our usage of multiplicity
  - use multiplicity in EC2 api calls
- reaper scripts

- don't use yaml to serialize juju stuff into zookeeper
- replace security groups with per-instance firewalls
- perhaps use features available in more recent versions of zookeeper

## What's Next?

- more clouds and MaaS!

- regular scale testing?
  - can this coincide with upstream scale testing?

- test scaling for various services?


## Wishlist

- use spot instances on ec2



Cranking up the knob 

Ok good to go, now let’s crank this up to to 2,000. 

juju add-unit -n 1500 hadoop-slave


Results

Charts and results and stuff that show we did it.

Total Storage and Number of CPU’s would be good - think we got that! 

Conclusions and Next Steps.

As you can see no matter how you slice it, when it comes to deploying big you run into some issues blah blah. We learned a bunch but let’s not make it look like we totally suck. 

(Make sure we talk about how juju will improve in this regard) 

And of course, we’re now doing scalability tests of juju on a blah blah basis to make sure we’re rocking it. This is just one of many scalability tests we plan on doing with juju on the cloud. With today’s proliferation of OpenStack-based clouds we look forward to doing these sort of tests on other clouds as well. With juju and Ubuntu server we can just point to whichever cloud we want and reuse the exact same commands. 

And of course while Terasort is mildly interesting and it shows that it actually works, we didn’t do anything useful with the cluster, so we’re thinking of useful things we can do with scaling tests that can help contribute to some of the big data problems that are out there. 

As far as for Hadoop itself, we have plans for how to make the Hadoop ecosystem move forward in Ubuntu.






Other considerations/questions (this might just be something we should consider, like a Rude Q+A, not sure how we integrate this into the blog or if we just prep for these kinds of questions)


Why not use Elastic Map Reduce, it’s designed for this kind of thing 

EMR is great, and if you’re planning on sticking with Amazon it’s a great solution. However with the proliferation of cloud providers recently using juju provides a cloud agnostic way to deploy Hadoop. Deploy this exact same way to HP Cloud, Rackspace, or your own OpenStack cloud so you can make the decision based on your preferred provider.

So, Amazon just let you guys fire up 2000 nodes, just like that? Uh huh.

Get your own Ben Howard!

Why not use spot instances?
I know right. Juju should totally support this. Let’s blame Kapil. :)

What’s the bill?



---


Here’s what the other guys are doing: http://virtualgeek.typepad.com/virtual_geek/2012/05/project-razor-and-my-friend-nick-weaver.html

---
copy/paste stuff for formatting


[Ubuntu Server](http://www.ubuntu.com/business/server/overview) 


<a href="/images/terasort-ganglia-1.png">
<img src="/images/terasort-ganglia-1.png" width="720px" />
</a>

