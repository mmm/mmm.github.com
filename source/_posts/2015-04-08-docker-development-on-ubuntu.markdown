---
layout: post
title: "Docker Development on Ubuntu"
date: 2015-04-08 12:00
comments: true
categories: 
---


Ok, so what's up with all this `DEBCONF_FRONTEND` nonsense in dockerfiles
everywhere?

Well, some packages need config before they can be installed, so they selfishly
pop up ncurses dialogs on the console and wait patiently for user input.

This is totally a holdback from the days where people interacted directly with
individual server installations.  Now, it's just a roadblock to installing
services transparently in containers.

Here's a simple way for docker to work with packages that prompt for settings.

<!--more-->

## tl;dr

Dockerfiles can safely use `debconf-set-selections` alongside
`DEBCONF_FRONTEND=noninteractive` to configure any packages that normally
prompt for initial configuration upon installation.

Docker developers can easily discover all configurable settings for packages
using `debconf-get-selections` during `Dockerfile` development.


## Packages

### Package Config




## Docker Development

- create a bare container to interact with
- manually install any packages that require initial settings
- install `debconf-tools`

```
    apt-get install debconf-utils
```

- get the package config

```
    root@1bad1842db71:/# debconf-get-selections | grep -i mysql
    # Repeat password for the MySQL "root" user:
    mysql-server-5.5  mysql-server/root_password_again  password  
    # New password for the MySQL "root" user:
    mysql-server-5.5  mysql-server/root_password  password  
    # Remove all MySQL databases?
    mysql-server-5.5  mysql-server-5.5/postrm_remove_databases  boolean false
    # Unable to set password for the MySQL "root" user
    mysql-server-5.5  mysql-server/error_setting_password error 
    mysql-server-5.5  mysql-server/no_upgrade_when_using_ndb  error 
    # Start the MySQL server on boot?
    mysql-server-5.5  mysql-server-5.5/start_on_boot  boolean true
    mysql-server-5.5  mysql-server-5.5/really_downgrade boolean false
    mysql-server-5.5  mysql-server-5.5/nis_warning  note  
    mysql-server-5.5  mysql-server/password_mismatch  error 
```

the ones we care about are

```
    # New password for the MySQL "root" user:
    mysql-server-5.5  mysql-server/root_password  password  
    # Repeat password for the MySQL "root" user:
    mysql-server-5.5  mysql-server/root_password_again  password  
```


- let's add these to the dockerfile using `debconf-set-selections` 

```
    dconf = Popen(['debconf-set-selections'], stdin=PIPE)
    dconf.stdin.write("%s %s/root_password password %s\n" % (package, package, root_pass))
    dconf.stdin.write("%s %s/root_password_again password %s\n" % (package, package, root_pass))
```

- test it out


<!--more-->
