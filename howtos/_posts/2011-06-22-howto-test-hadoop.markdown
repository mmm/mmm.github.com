---
layout: post
title: hadoop-test-install
tags: ['howto']
---


From [Michael Noll's hadoop on ubuntu post](http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/)

    mkdir /var/lib/hadoop
    chown mmm.mmm /var/lib/hadoop

    hadoop datanode -format

    bin/start-all.sh 

    hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg

    hadoop dfs -ls

    hadoop jar /usr/local/hadoop/hadoop-mapred-examples-0.21.0.jar wordcount gutenberg gutenberg-output

    hadoop dfs -ls
    hadoop dfs -ls gutenberg-output

    bin/hadoop dfs -cat gutenberg-output/part-r-00000
    mkdir /tmp/gutenberg-output
    bin/hadoop dfs -getmerge gutenberg-output /tmp/gutenberg-output
    head /tmp/gutenberg-output/gutenberg-output

