---
layout: post
title: "Painless Hadoop / Ubuntu / EC2"
categories: cloud
comments: true
---

    #########################################################
    NOTE: This is outdated... 

The internal project "ensemble" is now publicly known as "juju".
Please see the repost [Painless Hadoop / Ubuntu / EC2](http://markmims.com/cloud/2011/11/08/hadoop-on-ubuntu.html)
of this article with new names and updates to the api.

    #########################################################

---

Thanks Michael Noll for the posts where I first learned how to do this stuff:

- [Running Hadoop on Ubuntu Linux (Single-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/)
- [Running Hadoop on Ubuntu Linux (Multi-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/)

I'd like to run his exact examples, but this time around I'll use 
[juju](http://juju.ubuntu.com/) for hadoop deployment/management on
Ubuntu.

---

## The Short Story

### Setup

install/configure juju client tools

run hadoop services with juju

    $ juju bootstrap
    $ juju deploy --repository "~/charms" local:hadoop-master namenode
    $ juju deploy --repository "~/charms" local:hadoop-slave datanode
    $ juju add-relation namenode datanode
    $ juju expose namenode

optionally add slaves to scale horizontally

    $ juju add-unit datanode
    $ juju add-unit datanode
    $ juju add-unit datanode

(you can add/remove these later too)

Scaling is so easy there's no point in standalone -vs- multinode 
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

    hdfs$ hadoop jar /usr/lib/hadoop-0.20/hadoop-examples.jar wordcount gutenberg gutenberg-output


That's it!

---

Now, again with some more details...


## Installing juju

Install juju client tools from `ppa:juju/pkgs` onto your local machine

    # sudo add-apt-repository ppa:juju/pkgs
    # sudo apt-get update
    # sudo apt-get install juju

generate your environment settings with

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



## Hadoop


### Grab the juju Formulas

Make a place for formulas to live

    mkdir -p ~/charms/oneiric
    cd charms/oneiric

now grab the actual formulas we'll be using

    bzr checkout lp:charm/hadoop-master
    bzr checkout lp:charm/hadoop-slave

(If you don't have bazaar installed, you'll need to get that
first with `apt-get install bzr`)


### Start the Hadoop Services

Spin up juju

    juju bootstrap

wait a minute or two for EC2 to comply.
You're welcome to watch the water boil with

    juju status

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

    juju deploy --repository "~/charms" hadoop-master namenode
    juju deploy --repository "~/charms" hadoop-slave datanode

now you simply relate the two services:

    juju add-relation namenode datanode

Relations are where the juju special sauce is,
but more about that in another post.

You can tell everything's happy when `juju status`
gives you something like:

    $ juju status
    2011-07-12 15:29:20,331 INFO Connecting to environment.
    machines:
      0: {dns-name: ec2-50-17-28-19.compute-1.amazonaws.com, instance-id: i-8bc034ea}
      1: {dns-name: ec2-50-17-0-68.compute-1.amazonaws.com, instance-id: i-4fcf3b2e}
      2: {dns-name: ec2-75-101-249-123.compute-1.amazonaws.com, instance-id: i-35cf3b54}
    services:
      hadoop-master:
        formula: local:hadoop-master-1
        relations: {hadoop-master: hadoop-slave}
        units:
          hadoop-master/0:
            machine: 1
            relations:
              hadoop-master: {state: up}
            state: started
      hadoop-slave:
        formula: local:hadoop-slave-1
        relations: {hadoop-master: hadoop-master}
        units:
          hadoop-slave/0:
            machine: 2
            relations:
              hadoop-master: {state: up}
            state: started
    2011-07-12 15:29:23,685 INFO 'status' command finished successfully


### Loading Data

Log into the master node

    juju ssh namenode/0

and become the hdfs user

    ubuntu$ sudo -su hdfs

pull the example data

    hdfs$ cd /tmp
    hdfs$ wget http://markmims.com/files/gutenberg.tar.bz2
    hdfs$ tar xjvf gutenberg.tar.bz2

and copy it into hdfs

    hdfs$ hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg


### Running Jobs

Similar to above, but now do

    hdfs$ hadoop jar /usr/lib/hadoop-0.20/hadoop-examples.jar wordcount gutenberg gutenberg-output

You can look at logs on the slaves by

    juju ssh datanode/0
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-datanode*.log
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-tasktracker*.log

similarly for subsequent slave nodes

    juju ssh datanode/1

or 

    juju ssh datanode/2

### Horizontal Scaling

To resize your cluster,

    juju add-unit datanode

or even

    for i in {1..10}; do
      juju add-unit datanode
    done

That's it... really.

Wait for `juju status` to show everything in a happy state and then run your jobs.

You can add nodes in the middle of a run without any problems.  Wanna write a script
to watch your loads and add nodes as necessary?  no problem... just parse the json juju
status output.  We're working on an API to make this process easier.

Check out the `juju status` output for a 10-slave cluster [here](http://pastebin.com/FMF3TQEJ)


### disclaimer

I work on Ubuntu juju for Canonical.

