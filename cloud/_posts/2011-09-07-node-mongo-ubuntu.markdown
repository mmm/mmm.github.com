---
layout: post
title: "Node.js and MongoDB on Ubuntu"
tags: ['cloud', 'juju', 'node', 'mongo']
---


I gave my first talk on IRC the other day on deploying Node.js & Mongo in Ubuntu... 
it was quite a new experience.
Figured I'd post details of the talk here.

## An example stack

We'll use [juju](http://juju.ubuntu.com/) to deploy a basic
[node.js](http://nodejs.org)
app along with a couple of typical surrounding services..
- [haproxy](http://haproxy.1wt.eu/) to catch inbound web traffic and route it to our node.js app cluster
- [mongodb](http://mongodb.org/) for app storage

Along the way, we'll see what it takes to connect and scale this particular stack
of services.  I'll err on the side of too much detail over simplicity in this
example, but I'll try to make it clear when there's a sidebar topic.

At the end of the day, the deployment for our application
would look like the usual juju deployment

    $ juju bootstrap

(with a pregnant pause to allow EC2 to catch up)

    $ juju deploy --repository ~/charms local:mongodb
    $ juju deploy --repository ~/charms local:node-app myapp
    $ juju add-relation mongodb myapp

    $ juju deploy --repository ~/charms local:haproxy
    $ juju add-relation myapp haproxy
    $ juju expose haproxy
    
(with another pregnant pause to allow EC2 to catch up)

We can get the service URLs from

    $ juju status

and hit the head of the haproxy service to see the app in action.

We can scale it out with

    $ for i in {1..4}; do
    $   juju add-unit myapp
    $ done

and we'll soon have a cluster of one haproxy node balancing
between five application nodes all talking to a single mongo
node in the backend.  Of course, we can scale mongo too,
but that's another post.


## juju "Application" charms

There are two types of juju charms used in this example:

"Canned Charms", like the
[haproxy charm](http://github.com/mmm/juju-haproxy)
and the
[mongodb charm](http://github.com/mmm/juju-mongodb),
and "Application Charms", like
the [node.js app charm](http://github.com/mmm/juju-node-app).

Canned charms can be used as-is right off the shelf.

Application charms are used to manage your custom application
as an juju service.  We haven't nailed down the language on
this, but these charms create a contained environment,
"framework", or "wrapper" around your custom application and
help it to play nicely with other services.

The 
[node-app charm](http://github.com/mmm/juju-node-app)
we use here
is meant to be an example that you can fork/adapt and use
to maintain custom components of your infrastructure.

## The `node-app` charm

The `node-app` charm is the key feature we want to look at.
It's a charm that will pull your app from revision control
and config/deploy/maintain it as a service within your
infrastructure.

Setup and clone this charm

    $ mkdir ~/charms
    $ cd ~/charms
    ~/charms$ git clone http://github.com/charms/node-app

and we'll walk through it.

    README.markdown
    config.yaml
    copyright
    metadata.yaml
    revision
    hooks/
      install
      mongodb-relation-changed
      mongodb-relation-departed
      mongodb-relation-joined
      start
      stop
      website-relation-joined


We can see the usual `install`, `start`, and `stop` hooks for the
node.js service, along with a couple of other hooks for relating to
other services.

Before we go into this in detail, let's take a little sidebar on
the Node.js app we'll be deploying...


### Example node.js app

The example app I'm using for this

    http://github.com/mmm/testnode

just logs page hits in mongo and reports results.

As usual, I have absolutely no graphic design gifts so things look a little
bare-bones.  Don't let that fool you... it's quite easy to dress this up
with some svg maps and some client-side js a la topfunky's (peepcode.com)
node examples.

This is a really basic node app that...

Reads config info

    var config = require('./config/config'),
        mongo = require('mongodb'),
        http = require('http');

from a file `config/config.js`

    module.exports = config = {
       "name" : "mynodeapp"
      ,"listen_port" : 8000
      ,"mongo_host" : "localhost"
      ,"mongo_port" : 27017
    }

attaches to the mongo instance specified in the config file

    var db = new mongo.Db('mynodeapp', new mongo.Server(config.mongo_host, config.mongo_port, {}), {});

spins up a webservice

    var server = http.createServer(function (request, response) {

      var url = require('url').parse(request.url);

      if(url.pathname === '/hits') {
        show_log(request, response);
      } else {
        track_hit(request, response);
      }

    });
    server.listen(config.listen_port);

and handles requests.

The entire app would look something like

    //require.paths.unshift(__dirname + '/lib');
    //require.paths.unshift(__dirname);

    var config = require('./config/config'),
        mongo = require('mongodb'),
        http = require('http');

    var show_log = function(request, response){
      var db = new mongo.Db('mynodeapp', new mongo.Server(config.mongo_host, config.mongo_port, {}), {});
      db.addListener("error", function(error) { console.log("Error connecting to mongo"); });
      db.open(function(err, db){
        db.collection('addresses', function(err, collection){
          collection.find({}, {limit:10, sort:[['_id','desc']]}, function(err, cursor){
            cursor.toArray(function(err, items){
              response.writeHead(200, {'Content-Type': 'text/plain'});
              for(i=0; i<items.length;i++){
                response.write(JSON.stringify(items[i]) + "\n");
              }
              response.end();
            });
          });
        });
      });
    }

    var track_hit = function(request, response){
      var db = new mongo.Db('mynodeapp', new mongo.Server(config.mongo_host, config.mongo_port, {}), {});
      db.addListener("error", function(error) { console.log("Error connecting to mongo"); });
      db.open(function(err, db){
        db.collection('addresses', function(err, collection){
          var address = request.headers['x-forwarded-for'] || request.connection.remoteAddress;

          hit_record = { 'client': address,'ts': new Date() };

          collection.insert( hit_record, {safe:true}, function(err){
            if(err) { 
              console.log(err.stack);
            }
            response.writeHead(200, {'Content-Type': 'text/plain'});
            response.write(JSON.stringify(hit_record));
            response.end("Tracked hit from " + address + "\n");
          });
        });
      });
    }

    var server = http.createServer(function (request, response) {

      var url = require('url').parse(request.url);

      if(url.pathname === '/hits') {
        show_log(request, response);
      } else {
        track_hit(request, response);
      }

    });
    server.listen(config.listen_port);

    console.log("Server running at http://0.0.0.0:" + config.listen_port + "/");


We won't get into my node.js skillz at the moment... 
it's a deployment example.

I've also got a `package.json` in there to let `npm` resolve
some example dependencies upon install.

Now, there's no standard way to handle configuration in node
apps, so it's quite likely your app's config looks a bit 
different.  No problem, it's pretty straightforward to adapt
this example charm to handle the way your app works...
and use your own config file paths, and config parameter names.

End-of-sidebar... Back to the `node-app` charm.

### Hooks

Let's go through the hooks as they would be executing during
deployment and service relation.

The `install` hook is kicked off upon deployment,
reads its config from `config.yaml` and then will

- install `node`/`npm`
- clone your node app from the repo specified in `app_repo`
- run `npm` if your app contains `package.json`
- configure networking if your app contains `config/config.js`
- create a startup service for your app
- wait to startup once we're joined to a `mongodb` service

`start` and `stop` are trivial in this charm because
we want to wait for mongo to join before we actually run
the app.  If your app was simpler and didn't depend on
a backing store, then you could use these hooks to
manage the service created during installation.

### MongoDB

The key to almost every charm is in the relation hooks.

This particular app is written against mongodb
so the app's charm has hooks that get fired when
the "app" service is related to the mongo service.

This relation was defined when we did

    $ juju add-relation mongodb myapp

and the `relation-joined/changed` hooks
get fired after the `install` and `start`
hooks have successfully completed for both
ends of the relationship.

The `mongodb-relation-changed` hook in this charm
will read config from `config.yaml`

- get relation info from the mongo service (i.e., hostname)
- configure the app to use that host for mongo connections
- start the node app service we created during `install`

That's it really... our app is up and running at this
point.

Note that the example here depends on mongo,
but juju makes it easy to relate to some other backend db.
Just like we have `mongodb-relation-changed` hooks, we
could just as easily have `cassandra-relation-changed` hooks
that would look strikingly similar.  Of course, our app would
have to be written in such a way that it could use either,
but that's another topic.  The deployment tool supports
the choice being made dynamically when relations are joined.
I'd say "at deployment time" but it's even better than that
because I can remove relations and add other ones at 
any time throughout the lifetime of the service... and the
correct hooks get called.


### HAProxy

For this example, I'd like to use haproxy to load balance

This example stack uses haproxy to handle initial
web requests from outside.  haproxy will load balance
across multiple instances of our app.  That way we
could just attach an elastic ip to haproxy, configure
dns, and we're cruising 
(of course we're leaving out
plenty of infrastructure aspects like 
monitoring/logging/backups/etc that are
pretty important for a production deployment
in the cloud).

The app charm has
hooks that get fired when
the "app" service is related to the haproxy service.
Just as above, this relation was defined when we did

    $ juju add-relation haproxy myapp

and the `relation-joined/changed` hooks
get fired after the `install` and `start`
hooks have successfully completed for both
ends of the relationship.

The `website-relation-changed` hook in this charm
in its entirety:

    #!/bin/sh
 
    app_port=`config-get app_port`
    relation-set port=$app_port hostname=`hostname -f`

simply tells the haproxy service which 
address and port our application uses to handle
requests.

We could of course configure our app to listen on port
80, tell the charm to open port 80 in its firewall,
and then expose port 80 for our app service to the
outside world.  That'd be fine if we never needed to
scale or we were planning to load balance multiple
units of our app using dns, elastic load balancer instances,
or something else external.

Again, note that the example here uses haproxy, but
we could easily swap that out with any other service
that consumed the juju `http` interface.


### Charm configuration

Ok, so I lied a little up above when I said that the hooks
read config info from `config.yaml`.  Yes, they do read config
information from there, but that's not the whole story.
The values of the configurable parameters can be set/overidden
in a number of different ways throughout the lifecycle of
the service.

You can pass in dynamic configuration during deployment or later
at runtime using the cli

    `juju set <service_name> <config_param>=<value>`

or configure the charm at deployment time via a `yaml` file
passed to the `juju deploy --config` command.


### Scaling tips

Scaling with juju works really well.  The key
to this lies in the boundaries between
configuration for the service itself, versus configuration for
the service _in the context of_ a relation with another service.

When these two types of configuration are well isolated,
scaling with juju just works.  I've caught myself several
times working on just getting a service charm working, with
no real thought to scalability, and being pleasantly surprised
to find out that the service pretty much scales as written.

The best way to grok this is to walk through the process
of joining your relations as single unit services...

In our example,

    haproxy <-> myapp <-> mongodb

containers for each service get instantiated, then the `install`
and `start` hooks are run for each service.  Once both sides
of relations are `started` then the relation hooks get called:
`joined` and then usually several rounds of `changed` depending
on the relation parameters being set.  Once these are complete,
the services are up, related, and running.

Ok, now comes scaling.  `juju add-unit myapp` adds a new
`myapp` service node and goes through the whole cycle above.
The "services" are already related, so the relation hooks are
automatically fired as each new unit is `started`.
Since we divided up
the installation/configuration/setup/startup of the service
into the parts that are specific to the service and parts that
are specific to the relation with another service, then each
new unit runs "just enough" configuration to join it to the
cluster.

Not all tools can be configured like that, but that's the key
to strive for when writing relation hooks.
Identify the components of your application
configuration that really depend on another service, and 
isolate them as much as possible.
Only configure 
relation-specific things in the relation hooks.
The more minimal the relation hooks,
the more scalable the service.


