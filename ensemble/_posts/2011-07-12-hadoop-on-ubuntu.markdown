---
layout: post
title: Painless Hadoop / Ubuntu / EC2
tags: ['ensemble']
---


Thanks Michael Noll for the posts where I first learned how to do this stuff:

  - [Running Hadoop on Ubuntu Linux (Single-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/)
  - [Running Hadoop on Ubuntu Linux (Multi-Node Cluster)](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/)

I'd like to show how to run his exact examples, but this time around I'll use Ensemble for hadoop deployment/management.

## The Short Story

### Setup

- install/configure ensemble client tools

- run hadoop services with ensemble

    $ ensemble bootstrap
    $ ensemble deploy --repository . hadoop-master
    $ ensemble deploy --repository . hadoop-slave
    $ ensemble add-relation hadoop-master hadoop-slave

- optionally add slaves to scale horizontally

    $ ensemble add-unit hadoop-slave
    $ ensemble add-unit hadoop-slave
    $ ensemble add-unit hadoop-slave

(you can add/remove these later too)

Scaling is so easy there's no point in standalone -vs- multinode 
versions of the setup.


### Data and Jobs

- Load your data and jars

    $ ensemble ssh hadoop-master/0

    ubuntu$ sudo -s -u hdfs

    hdfs$ mkdir /tmp/gutenberg
    hdfs$ cd /tmp/gutenberg
    hdfs$ wget http://url/to/simple/sample/data

- copy the data into hdfs

    hdfs$ hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg

- run mapreduce jobs against the dataset

    hdfs$ hadoop jar hadoop-examples.jar wordcount gutenberg gutenberg-output


---

## Details

### Installing Ensemble

Install ensemble client tools from `ppa:ensemble` onto your local machine

    # sudo add-apt-repository ppa:ensemble
    # sudo apt-get install ensemble

generate your environment settings with

    $ ensemble

and then edit `~/.ensemble/environments.yaml` to use your EC2 keys.
It'll look something like:

    ensemble: environments

    environments:
      sample:
        type: ec2
        control-bucket: ensemble-<hash>
        admin-secret: <hash>
        access-key: <your ec2 access key>
        secret-key: <your ec2 secret key>



### Hadoop


#### Grab the Ensemble Formulas

Make a place for formulas to live

    mkdir ensemble
    cd ensemble

now grab the actual formulas we'll be using

    bzr checkout lp:~negronjl/+junk/hadoop-master
    bzr checkout lp:~negronjl/+junk/hadoop-slave

(If you don't have bazaar installed, you'll need to get that
first with `apt-get install bzr`)


#### Starting up the Hadoop Services

Spin up ensemble

    ensemble bootstrap

wait a minute or two for EC2 to comply.
You're welcome to watch the water boil with

    ensemble status

which'll give you output like

    [ es output with bootstrap up and ready ]

Next, you need to deploy the hadoop services:

    ensemble deploy --repository . hadoop-master
    ensemble deploy --repository . hadoop-slave

(the '.' is important)

wait a minute or two for EC2 to comply, then
when both services are in a `started` state, as in

    [ es output with master/slave started ]

relate them:

    ensemble add-relation hadoop-master hadoop-slave

that's it.

You can tell everything's happy when `ensemble status`
gives you something like:

    [ es output with master/slave started and related ]

#### Loading Data

Log into the master node

    ensemble ssh hadoop-master/0

and become the hdfs user

    ubuntu$ sudo -su hdfs

pull the example data

    hdfs$ mkdir /tmp/gutenberg
    hdfs$ cd /tmp/gutenberg
    hdfs$ wget http://path/to/my/data

and copy it into hdfs

    hdfs$ hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg


#### Running Jobs

Similar to above, but now do

    hdfs$ hadoop jar hadoop-examples.jar wordcount gutenberg gutenberg-output

You can look at logs on the slaves by

    ensemble ssh hadoop-slave/0
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-datanode*.log
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-tasktracker*.log

similarly for subsequent slave nodes

    ensemble ssh hadoop-slave/1

or 

    ensemble ssh hadoop-slave/2

#### Horizontal Scaling

To resize your cluster,

    ensemble add-unit hadoop-slave

or even

    ensemble add-unit hadoop-slave
    ensemble add-unit hadoop-slave
    ensemble add-unit hadoop-slave
    ensemble add-unit hadoop-slave

That's it... really.

Wait for `ensemble status` to show everything in a happy state and then run your jobs.

I don't know yet how the hadoop ensemble formulas behave when nodes are added in the middle of a run.  I'll test and update.
