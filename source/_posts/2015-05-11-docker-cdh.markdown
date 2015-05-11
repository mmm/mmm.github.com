---
layout: post
title: "Docker CDH"
date: 2015-05-11 14:12
comments: true
categories: [docker, data_engineering, devops]
---


# Docker CDH


Pull

    docker pull markmims/cdh

run

    docker run -td markmims/cdh

attach

    docker exec -it <container-name> bash -l

and play

    hadoop fs -ls
    impala-shell
    hbase shell
    spark-shell



