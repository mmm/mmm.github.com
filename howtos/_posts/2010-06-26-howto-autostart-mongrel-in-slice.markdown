---
layout: post
title: autostart mongrel in slice
tags: ['howto']
---

/usr/local/sbin/run_mongrel_cluster_ctl.sh
    
    #!/bin/bash
    
    export RUBYGEMS=/usr/local/rubygems
    export GEM_HOME=${RUBYGEMS}/gems
    export GEM_PATH=${RUBYGEMS}/gems
    export RUBYLIB=${RUBYGEMS}/lib
    export PATH=${RUBYGEMS}/gems/bin:${RUBYGEMS}/bin:$PATH
    
    mongrel_cluster_ctl $*
    

/etc/init.d/jsas_cluster

    
    #!/bin/sh
    #
    # mongrel jsas cluster init script
    #
    ### BEGIN INIT INFO
    # Provides:          jsas_cluster
    # Required-Start:    $network $local_fs $remote_fs
    # Required-Stop:
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: init-Script for jsas mongrel_cluster
    ### END INIT INFO
    
    #sudo -i -u jsas $DAEMON_CTL help
    
    set -e
    
    # Defaults
    PATH=/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin
    DAEMON_CTL=/usr/local/sbin/run_mongrel_cluster_ctl.sh
    USER=jsas
    OPTIONS=""
    
    PIDFILE="/var/run/mongrel_cluster.pid"
    
    test -f $DAEMON_CTL || exit 0
    
    . /lib/lsb/init-functions
    
    case "$1" in
    	start)
        sudo -i -u jsas $DAEMON_CTL start
    		;;
    	stop)
        sudo -i -u jsas $DAEMON_CTL stop
    		;;
    	force-reload|restart)
        sudo -i -u jsas $DAEMON_CTL restart
    		;;
    	status)
        sudo -i -u jsas $DAEMON_CTL status
    		;;
    	*)
    		log_warning_msg "Usage: /etc/init.d/jsas_cluster {start|stop|restart}"
    		log_warning_msg "  start - starts system-wide jsas_cluster service"
    		log_warning_msg "  stop  - stops system-wide jsas_cluster service"
    		log_warning_msg "  restart, force-reload - starts a new system-wide jsas_cluster service"
    		log_warning_msg "  status  - status of system-wide jsas_cluster service"
    		log_warning_msg "    system-wide jsas cluster service"
    		exit 1
    		;;
    esac
    
    exit 0

then update the rc scripts...

    update-rc.d jsas_cluster defaults 98 02
