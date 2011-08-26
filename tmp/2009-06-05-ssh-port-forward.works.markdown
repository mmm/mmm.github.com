---
layout:post
title: $i
tags: ["howto"]
---

#!/bin/bash
#
# source function library
. /etc/rc.d/init.d/functions

RETVAL=0
prog="ssh-port-forward"

LOCK_FILE=/var/lock/subsys/ssh-port-forward
PID_FILE=/var/run/ssh-port-forward.pid

start()
{
	echo -n $"Starting $prog:"

	#initlog -c "$SSHD $OPTIONS" && success || failure
#       daemon --check "$prog" ssh -l root -N -R"443:192.168.2.110:22" wendel
        if [ -f $LOCK_FILE ] ; then
            echo "process already running..."
            return -1
        fi
        ssh -l root -N -R"443:192.168.2.110:22" wendel &
        echo $! > $PID_FILE


	RETVAL=$?
	[ "$RETVAL" = 0 ] && touch $LOCK_FILE
	echo
}

stop()
{
	echo -n $"Stopping $prog:"

#	killproc $prog -TERM
        kill `cat $PID_FILE`
        rm -f $PID_FILE

	RETVAL=$?
	[ "$RETVAL" = 0 ] && rm -f $LOCK_FILE
	echo
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	status)
		status $SSHD
		RETVAL=$?
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|status}"
		RETVAL=1
esac
exit $RETVAL
