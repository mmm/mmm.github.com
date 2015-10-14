---
layout: post
title: "Develop Spark Apps on Yarn using Docker"
date: 2015-10-13 15:07
comments: true
categories: [docker, data-engineering, spark, devops]
---


At svds, we'll often run spark on yarn in production.  Add some artful tuning
and this works pretty well.  However, developers typically build and test spark
application in _standalone_ mode... not on yarn.

Rather than get bitten by the ideosyncracies involved in running spark on yarn
-vs- standalone when you go to deploy, here's a way to set up a development
environment for spark that more closely mimics how it's used in the wild.

<!--more-->


## A simple yarn "cluster" on your laptop

Run a docker image for a cdh standalone instance

    docker run -d --name=mycdh svds/cdh

when the logs

    docker logs -f mycdh

stop going wild, you can run the usual hadoop-isms to set up a workspace

    docker exec -it mycdh hadoop fs -ls /
    docker exec -it mycdh hadoop fs -mkdir -p /tmp/blah


## Run spark

Then, it's pretty straightforward to run spark against yarn

    docker exec -it mycdh \
      spark-submit \
        --master yarn-cluster \
        --class org.apache.spark.examples.SparkPi \
        /usr/lib/spark/examples/lib/spark-examples-1.3.0-cdh5.4.3-hadoop2.6.0-cdh5.4.3.jar \
        1000

Note that you can _submit_ a spark job to run in either "yarn-client" or "yarn-cluster" modes.

In "yarn-client" mode, the spark driver runs outside of yarn and logs to
console and all spark executors run as yarn containers.

In "yarn-cluster" mode, all spark executors run as yarn containers, but then
the spark driver also runs as a yarn container.  Yarn manages all the logs.

You can also run the spark shell so that any workers spawned run in yarn

    docker exec -it mycdh spark-shell --master yarn-client

or

    docker exec -it mycdh pyspark --master yarn-client


## Your Application

Ok, so `SparkPi` is all fine and dandy, but how do I run a real application?

When you start up the `cdh` container, map your local host drive up and into
the container

    docker run -d -v target --name=mycdh svds/cdh 

where the `-v target` option will mount the `target` directory under your
current directory over to the container's `/target` directory.

So,

    sbt clean assembly

leaves a jar under target, which you can run jobs from using something like

    docker exec -it mycdh \
      spark-submit \
        --master yarn-cluster \
        --name MyFancySparkJob-name \
        --class org.markmims.MyFancySparkJob \
        /target/scala-2.10/My-assembly-1.0.1.20151013T155727Z.c3c961a51c.jar \
        myarg

where the `--name` makes it easier to find in the midst of multiple yarn jobs.


## Logs

While a spark job is running, you can get its yarn "applictionId" from

    docker exec -it mycdh yarn application -list

or if it finished already just list things out with more conditions

    docker exec -it mycdh yarn application -list -appStates FINISHED

You can dig through the yarn-consolidated logs after the job is done
by using

    docker exec -it mycdh yarn logs -applicationId <applicationId>



## Consoles

Web consoles are critical for application development.  Spend time up front
getting ports open or forwarded correctly for all environments.  Don't wait
until you're actually trying to debug something critical to figure out how to
forward ports to see the staging UI in all environments.

### Yarn ResourceManager UI

Yarn gives you quite a bit of info about the system right from the
ResourceManager on its ip address and webgui port (usually 8088)

    open http://<resource-manager-ip>:<resource-manager-port>/



### Spark Staging UI

Yarn also conveniently proxies access to the spark staging UI for a given
application.  This looks like

    open http://<resource-manager-ip>:<resource-manager-port>/proxy/<applicationId>

for example,

    open http://localhost:8088/proxy/application_1444330488724_0005/


### Ports and Docker

There are a few ways to deal with accessing port `8088` of the yarn resource
manager from outside of the docker container.  I typically use ssh for everything
and just forward ports out to `localhost` on the host.  Most people will
expect to access ports directly on the `docker-machine ip` address.

Map that when you first spin up the container via

    docker run -d -v target -P 8088 --name=mycdh svds/cdh 

Then you should be good with something like

    open http://`docker-machine ip`:8088/

to access the yarn console.



---




## Tips and Gotchas

- The docker image `svds/cdh` is quite large (2GB).  I like to do a separate
  `docker pull` from any `docker run` commands just to isolate the download.
  In fact, I recommend pinning the cdh version for the same reason... so
  `docker pull svds/cdh:5.4.0` for instance, then refer to it that way
  throughout `docker run -d --name=mycdh svds/cdh:5.4.0` and that'll insure
  you're not littering your laptop's filesystem with docker layers from
  multiple cdh versions.  The bare `svds/cdh` (equiv to `svds/cdh:latest`)
  floats with the most recent cloudera versions

- I'm using a CDH container here... but there's an HDP one on the way as well.
  Keep an eye out for it on [svds's dockerhub page](`hub.docker.com/u/svds`)

- web consoles and forwarding ports through SSH



## Bonus

Ok, so the downside here is that the image is fat.  The upside is that it lets
you play with the full suite of CDH-based tools.  I've tested out (besides the
spark variations above)

### Impala shell

    docker exec mycdh impala-shell

### HBase shell

    docker exec mycdh hbase shell

### Hive

    echo "show tables;" | docker exec mycdh beeline -u jdbc:hive2://localhost:10000 -n username -p password -d org.apache.hive.jdbc.HiveDriver



