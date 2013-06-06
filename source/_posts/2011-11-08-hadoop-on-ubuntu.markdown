---
layout: post
title: "Painless Hadoop / Ubuntu / EC2"
categories: cloud
comments: true
---

    #########################################################
    NOTE: Repost

The ubuntu project "ensemble" is now publicly known as "juju".
This is a repost of an older article [Painless Hadoop / Ubuntu / EC2](http://markmims.com/cloud/2011/07/12/hadoop-on-ubuntu.html) to reflect the new names and updates to the api.

    #########################################################

---

Thanks Michael Noll for the posts where I first learned how to do this stuff:

- [Running Hadoop on Ubuntu Linux (Single-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/)
- [Running Hadoop on Ubuntu Linux (Multi-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/)

I'd like to run his exact examples, but this time around I'll use 
[juju](http://juju.ubuntu.com/) for hadoop deployment/management.

---

## The Short Story

### Setup

install/configure juju client tools

    $ sudo apt-get install juju charm-tools
    $ mkdir ~/charms && charm getall ~/charms

run hadoop services with juju

    $ juju bootstrap
    $ juju deploy --repository ~/charms local:hadoop-master namenode
    $ juju deploy --repository ~/charms local:hadoop-slave datanodes
    $ juju add-relation namenode datanodes

optionally add datanodes to scale horizontally

    $ juju add-unit datanodes
    $ juju add-unit datanodes
    $ juju add-unit datanodes

(you can add/remove these later too)

Scaling is so easy there's no point in separate standalone -vs- multinode 
versions of the setup.


### Data and Jobs

Load your data and jars

    $ juju ssh namenode/0

    ubuntu$ sudo -su hdfs

    hdfs$ cd /tmp
    hdfs$ wget http://files.markmims.com/gutenberg.tar.bz2
    hdfs$ tar xjvf gutenberg.tar.bz2

copy the data into hdfs
 
    hdfs$ hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg

run mapreduce jobs against the dataset

    hdfs$ hadoop jar /usr/lib/hadoop-0.20/hadoop-examples.jar wordcount -Dmapred.map.tasks=20 -Dmapred.reduce.tasks=20 gutenberg gutenberg-output


That's it!

---

Now, again with some more details...


## Installing juju

Install juju client tools onto your local machine...

    # sudo apt-get install juju charm-tools

We've got the juju CLI in ports now too for Mac clients
(Homebrew is in progress).

Now generate your environment settings with

    $ juju

and then edit `~/.juju/environments.yaml` to use your EC2 keys.
It'll look something like:

    environments:
      sample:
        type: ec2
        control-bucket: juju-<hash>
        admin-secret: <hash>
        access-key: <your ec2 access key>
        secret-key: <your ec2 secret key>
        default-series: oneiric

In real life you'd probably want to specify `default-image-type` to at least `m1.large` too,
but I'll give some examples of that in later posts.

## Hadoop


### Grab the juju charms

Make a place for charms to live

    $ mkdir charms/oneiric
    $ cd charms/oneiric
    $ charm get hadoop-master
    $ charm get hadoop-slave

(optionally, you can `charm getall` but it'll take a bit to pull all charms).


### Start the Hadoop Services

Spin up a juju environment

    $ juju bootstrap

wait a minute or two for EC2 to comply.
You're welcome to watch the water boil with

    $ juju status

or even 

    $ watch -n30 juju status

which'll give you output like

    $ juju status
    2011-07-12 15:20:54,978 INFO Connecting to environment.
    The authenticity of host 'ec2-50-17-28-19.compute-1.amazonaws.com (50.17.28.19)' can't be established.
    RSA key fingerprint is c5:21:62:f0:ac:bd:9c:0f:99:59:12:ec:4d:41:48:c8.
    Are you sure you want to continue connecting (yes/no)? yes
    machines:
      0: {dns-name: ec2-50-17-28-19.compute-1.amazonaws.com, instance-id: i-8bc034ea}
    services: {}
    2011-07-12 15:21:01,205 INFO 'status' command finished successfully


Next, you need to deploy the hadoop services:

    $ juju deploy --repository ~/charms local:hadoop-master namenode
    $ juju deploy --repository ~/charms local:hadoop-slave datanodes

now you simply relate the two services:

    $ juju add-relation namenode datanodes

Relations are where the juju special sauce is,
but more about that in another post.

You can tell everything's happy when `juju status`
gives you something like (looks a bit different, but basics are the same):

    $ juju status
    2011-07-12 15:29:20,331 INFO Connecting to environment.
    machines:
      0: {dns-name: ec2-50-17-28-19.compute-1.amazonaws.com, instance-id: i-8bc034ea}
      1: {dns-name: ec2-50-17-0-68.compute-1.amazonaws.com, instance-id: i-4fcf3b2e}
      2: {dns-name: ec2-75-101-249-123.compute-1.amazonaws.com, instance-id: i-35cf3b54}
    services:
      namenode:
        formula: local:hadoop-master-1
        relations: {hadoop-master: datanodes}
        units:
          namenode/0:
            machine: 1
            relations:
              hadoop-master: {state: up}
            state: started
      datanodes:
        formula: local:hadoop-slave-1
        relations: {hadoop-master: namenode}
        units:
          datanodes/0:
            machine: 2
            relations:
              hadoop-master: {state: up}
            state: started
    2011-07-12 15:29:23,685 INFO 'status' command finished successfully



### Loading Data

Log into the master node

    $ juju ssh namenode/0

and become the hdfs user

    ubuntu$ sudo -su hdfs

pull the example data

    hdfs$ cd /tmp
    hdfs$ wget http://files.markmims.com/gutenberg.tar.bz2
    hdfs$ tar xjvf gutenberg.tar.bz2

and copy it into hdfs

    hdfs$ hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg


### Running Jobs

Similar to above, but now do

    hdfs$ hadoop jar /usr/lib/hadoop-0.20/hadoop-examples.jar wordcount gutenberg gutenberg-output

you might want to explicitly call out the number of jobs to use...

    hdfs$ hadoop jar /usr/lib/hadoop-0.20/hadoop-examples.jar wordcount -Dmapred.map.tasks=20 -Dmapred.reduce.tasks=20 gutenberg gutenberg-output

depending on the size of the cluster you decide to spin up.

You can look at logs on the slaves by

    $ juju ssh datanodes/0
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-datanode*.log
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-tasktracker*.log

similarly for subsequent slave nodes if you've spun them up

    $ juju ssh datanodes/1

or 

    $ juju ssh datanodes/2

### Horizontal Scaling

To resize your cluster,

    $ juju add-unit datanodes

or even

    $ for i in {1..10}
    $ do
    $   juju add-unit datanodes
    $ done

Wait for `juju status` to show everything in a happy state and then run your jobs.

I was able to add slave nodes in the middle of a run... they pick up load and crank.

Check out the `juju status` output for a simple 10-slave cluster [here](http://pastebin.com/FMF3TQEJ)

