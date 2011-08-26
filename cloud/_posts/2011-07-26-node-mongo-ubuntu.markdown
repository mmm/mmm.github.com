---
layout: post
title: "Node.js and MongoDB on Ubuntu"
tags: ['cloud', 'ensemble', 'node', 'mongo']
---


I gave my first talk on IRC the other day on deploying Node.js & Mongo in Ubuntu... 
it was quite a new experience.
Figured I'd post details of the talk here.

# The stack

We'll use [Ensemble](http://ensemble.ubuntu.com/) to deploy a basic node.js app
along with a couple of typical surrounding services..
- haproxy to catch inbound web traffic and route it to our node.js app cluster
- mongodb for app storage

Along the way, we'll see what it takes to connect and scale this particular stack
of services.  I'll err on the side of too much detail over simplicity in this
example, but I'll try to make it clear when there's a sidebar topic.

# Ensemble

There are two types of ensemble formulas used in this example:

1. "Canned" formulas

    http://github.com/mmm/ensemble-haproxy
    http://github.com/mmm/ensemble-mongodb

2. User-generated "application" or "framework" formulas

    http://github.com/mmm/ensemble-mynodeapp

Canned formulas can be used as-is right off the shelf.

This framework formula is meant to be an example that you can
fork/adapt and use to maintain custom aspects of your
infrastructure.


## Deployment


Let's start with the usual ensemble deployment

    $ ensemble bootstrap

    (pregnant pause to allow EC2 to catch up)

    $ ensemble deploy --repository . mongodb
    $ ensemble deploy --repository . mynodeapp
    $ ensemble add-relation mongodb mynodeapp

    $ ensemble deploy --repository . haproxy
    $ ensemble add-relation mynodeapp haproxy
    

Done.  We can get the service URLs from

    $ ensemble status

and hit the head of the haproxy service to see the app in action.


# User-generated "framework" formula

The `mynodeapp` formula is the key feature we want to look at.
It's a formula that will pull your app from revision control
and configure/deploy/maintain it as a service within your
infrastructure.

Clone this formula from

    git clone http://github.com/mmm/ensemble-mynodeapp mynodeapp

and we'll walk through it.

    README.markdown
    copyright
    metadata.yaml
    hooks/
      formula-tools.rb
      install
      mongodb-relation-changed
      mongodb-relation-departed
      mongodb-relation-joined
      start
      stop
      website-relation-joined


We've got the usual `install`, `start`, and `stop` hooks for the
node.js service.

The key to every formula is in the relation hooks.


# Example node.js app

The example app I'm using for this

    http://github.com/mmm/testnode

just logs hits in mongo and reports results.

As usual, I have absolutely no graphic design gifts so things look a little
bare-bones.  Don't let that fool you... it's quite easy to dress this up
a la topfunky's (peepcode.com) node examples.

This is a really basic node app that...

Reads config info

    var config = require('./config/config'),
        mongo = require('mongodb'),
        http = require('http');

from a file `config.js` that looks like

    module.exports = config = {
       "name" : "mynodeapp"
      ,"listen_port" : 8000
      ,"mongo_host" : "localhost"
      ,"mongo_port" : 27017
    }

attaches to the mongo instance in the config file

    db = new mongo.Db('mynodeapp', new mongo.Server(config.mongo_host, config.mongo_port, {}), {});
    db.addListener("error", function(error) {
      console.log("Error connecting to mongo");
    });

spins up a webservice

    var server = http.createServer(function (request, response) {
      var address = request.headers['x-forwarded-for'] || request.connection.remoteAddress;

      response.writeHead(200, {"Content-Type": "text/plain"});
      response.write("Hello " + address + "\n");
      response.write("\n");
      response.end("request:" + JSON.stringify(request.headers) + "\n");
    });
    server.listen(config.listen_port);


The entire app would look like

    //require.paths.unshift(__dirname + '/lib');
    //require.paths.unshift(__dirname);

    var config = require('./config/config'),
        mongo = require('mongodb'),
        http = require('http');

    db = new mongo.Db('mynodeapp', new mongo.Server(config.mongo_host, config.mongo_port, {}), {});
    db.addListener("error", function(error) {
      console.log("Error connecting to mongo");
    });

    var server = http.createServer(function (request, response) {
      var address = request.headers['x-forwarded-for'] || request.connection.remoteAddress;

      response.writeHead(200, {"Content-Type": "text/plain"});
      response.write("Hello " + address + "\n");
      response.write("\n");
      response.end("request:" + JSON.stringify(request.headers) + "\n");
    });
    server.listen(config.listen_port);

    console.log("Server running at http://0.0.0.0:8000/");


We won't get into my node.js skillz at the moment... it's an example.


# MongoDB


### Start the Hadoop Services

Spin up ensemble

    ensemble bootstrap

wait a minute or two for EC2 to comply.
You're welcome to watch the water boil with

    ensemble status

which'll give you output like

    $ ensemble status
    2011-07-12 15:20:54,978 INFO Connecting to environment.
    The authenticity of host 'ec2-50-17-28-19.compute-1.amazonaws.com (50.17.28.19)' can't be established.
    RSA key fingerprint is c5:21:62:f0:ac:bd:9c:0f:99:59:12:ec:4d:41:48:c8.
    Are you sure you want to continue connecting (yes/no)? yes
    machines:
      0: {dns-name: ec2-50-17-28-19.compute-1.amazonaws.com, instance-id: i-8bc034ea}
    services: {}
    2011-07-12 15:21:01,205 INFO 'status' command finished successfully


Next, you need to deploy the hadoop services:

    ensemble deploy --repository . hadoop-master
    ensemble deploy --repository . hadoop-slave

(the '.' is important)

now you simply relate the two services:

    ensemble add-relation hadoop-master hadoop-slave

Relations are where the ensemble special sauce is,
but more about that in another post.

You can tell everything's happy when `ensemble status`
gives you something like:

    $ ensemble status
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

    ensemble ssh hadoop-master/0

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

    ensemble ssh hadoop-slave/0
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-datanode*.log
    ubuntu$ tail /var/log/hadoop/hadoop-hadoop-tasktracker*.log

similarly for subsequent slave nodes

    ensemble ssh hadoop-slave/1

or 

    ensemble ssh hadoop-slave/2

### Horizontal Scaling

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

Check out the `ensemble status` output for a 10-slave cluster [here](http://pastebin.com/FMF3TQEJ)

