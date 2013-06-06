---
layout: post
title: VM buildout notes for dlb
categories: howtos
comments: true
---


added sources.list

packages:

    ruby
    rdoc ri irb
    build-essential
    ruby1.8-dev
    libapache2-mod-fcgid
    libfcgi-dev
    libxml2
    libxml2-dev
    libxslt1-dev
    sqlite3
    libsqlite3-dev
    mysql-server (had to force this for some reason ... bitching about locale not being set)
    libmysql-ruby1.8
    libdbd-mysql-ruby
    libmysqlclient15-dev
    rsync
    screen
    libopenssl-ruby


    apt-get update
    apt-get -u upgrade
    apt-get -u dist-upgrade

install rubygems in /usr/local

install gems
    rails
    mongrel
    mongrel_cluster
    passenger
    capistrano
    capistrano-ext
    fcgi
    ferret
    haml
    hpricot
    htmlentities
    nokogiri
    mechanize
    cucumber
    mocha
    open4
    runt
    spreadsheet
    sqlite3
    termios
    will_paginate


    adduser --home /usr/local/dlb dlb

rsync `/usr/local/dlb` over to VM

scp `/etc/apache2/sites-available/dlb-sites` over to VM

test to get apache up

test to get rails up


apache config for mods-enabled:
    ln -s ../mods-available/deflate.conf .
    ln -s ../mods-available/deflate.load .
    ln -s ../mods-available/file_cache.load .
    ln -s ../mods-available/mem_cache.load .
    ln -s ../mods-available/mem_cache.conf .
    ln -s ../mods-available/headers.load .
    ln -s ../mods-available/proxy_balancer.load .
    ln -s ../mods-available/proxy.conf
    ln -s ../mods-available/proxy_http.load .
    ln -s ../mods-available/proxy.load .
    ln -s ../mods-available/rewrite.load .
    ln -s ../mods-available/include.load .
    ln -s ../mods-available/cache.load .

