---
layout: post
title: "A Hybrid Approach to DevOps for DataScience Pipelines"
date: 2016-05-23 14:21
comments: true
categories: [data-engineering, ansible, terraform, devops]
---

Here's an approach we like to use at SVDS for managing datascience pipelines.
The heart of the idea is to mix upstream cluster management tools such as
ClouderaManager/Ambari with configuration management tools such as Ansible...
and do it in _just_ the right way that you get opinionated, reproducible
datascience pipelines that're also tightly managed by upstream tooling.  Why
would we do such a thing?  How does it work?  What planet are you from?

<!--more-->

At SVDS, we work with a lot of Hadoop clusters and tend to prefer cluster
management tools such as ClouderaManager and Ambari to handle the version-soup
of services that make up the various complex and dynamic Hadoop ecosystems.  A
tool like ClouderaManager is fairly tightly maintained, tested, and supported
upstream.

However, we _also_ like to have programmatically maintained, reproducible
infrastructure...  which is unfortunately somewhat at odds with the nature of
point-and-click cluster management tools like ClouderaManager.  Configuration
Management Tools like chef, puppet, ansible keep things programmatic and
reproducible.  If you're more of an image baker than an instance cooker...
docker, packer, etc end you up in the same place.  How can these tools play
nicely together with ClouderaManager?

A key aspect is that ClouderaManager's preferred way to manage services on
containers is to use what it calls "Parcels" which are just tarball installs
managed from somewhere off in the corner like `/opt/cloudera/`.  For config
management tools it's more ideomatic to manage installed services using
operating system "Packages" a la `apt` or `rpm`.

Well, these turn out to be orthogonal.  It's possible to use standard
configuration management tools to use _packages_ to prepare what's effectively
empty containers of appropriate sizes, name them appropriately, and then hand
them over to ClouderaManager to dynamically manage using _parcels_ from there.

This effectively decouples the programmatic _deployment_ of containers from the
configuration of hadoop services.  However, how is this reproducible?  Well,
ClouderaManager and Ambari both have APIs.  So we use the configuration
management tools to prep and register the empty containers, in a role, with
ClouderaManager.  We then use the configuration management tools to
additionally hit the ClouderaManager APIs to _configure_ the hadoop services on
top of the cluster in a reproducible manner.

##

##

##

