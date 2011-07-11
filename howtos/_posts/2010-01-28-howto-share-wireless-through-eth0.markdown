---
layout: post
title: Share wireless through eth0
tags: ['howto']
---

#Share ganymede's wifi (eth1) connection out through eth0

Bonus: plug helga into eth0 and re-share wireless over helganet

on ganymede, set up eth0.

/etc/network/interfaces... add:

    auto eth0
    #iface eth0 inet dhcp
    iface eth0 inet static
      address 192.168.20.254
      netmask 255.255.255.0


/etc/default/iptables... should read:

    *nat
    :PREROUTING ACCEPT [7126:609382]
    :POSTROUTING ACCEPT [25:2066]
    :OUTPUT ACCEPT [32:4056]
    -A POSTROUTING -o eth1 -s 192.168.20.0/24 -d ! 192.168.20.0/24 -j MASQUERADE 
    #-A PREROUTING -d 216.82.212.101/32 -p tcp --dport 80 -j DNAT --to 10.12.10.1:80
    COMMIT

    *filter
    :INPUT DROP [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT ACCEPT [8409:705642]
    :LOGDROP - [0:0]
    :NEVER - [0:0]
    :external-if - [0:0]
    :external-internal - [0:0]
    :icmp-accept - [0:0]
    :internal-external - [0:0]
    :internal-if - [0:0]

    -A LOGDROP -m limit --limit 3/hour -j LOG --log-prefix "filter: " 
    -A LOGDROP -j DROP 

    -A NEVER -j LOG --log-prefix "filter ERROR: " --log-level 1 
    -A NEVER -j DROP 

    -A external-if -m state --state RELATED,ESTABLISHED -j ACCEPT 
    -A external-if -p icmp -m icmp --icmp-type 0 -j ACCEPT 
    -A external-if -j icmp-accept 
    -A external-if -j DROP 

    #-A internal-if -s 192.168.20.0/24 -p tcp --dport 22 -j ACCEPT
    -A internal-if -s 192.168.20.0/24 -j ACCEPT
    -A internal-if -p icmp -m icmp --icmp-type 0 -j ACCEPT 
    -A internal-if -j icmp-accept 
    -A internal-if -j DROP 

    -A icmp-accept -p icmp -m icmp --icmp-type 8 -j ACCEPT 
    -A icmp-accept -p icmp -m icmp --icmp-type 11 -j ACCEPT 
    -A icmp-accept -p icmp -m icmp --icmp-type 3 -j ACCEPT 
    -A icmp-accept -p icmp -m icmp --icmp-type 4 -j ACCEPT 
    -A icmp-accept -p icmp -m icmp --icmp-type 11 -j ACCEPT 
    -A icmp-accept -p icmp -m icmp --icmp-type 12 -j ACCEPT 

    -A external-internal -m state --state RELATED,ESTABLISHED -j ACCEPT 
    -A external-internal -p tcp -m tcp --sport 22 ! --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT 
    #-A external-internal -p tcp -o eth0 -d 192.168.100.2 --dport 22 -m state --state NEW -j ACCEPT
    -A external-internal -p icmp -m icmp --icmp-type 0 -j ACCEPT 
    -A external-internal -j DROP 

    -A internal-external -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT 
    -A internal-external -j DROP 

    -A INPUT -i eth1 -j external-if 
    -A INPUT -i eth0 -j internal-if 

    -A FORWARD -i eth1 -o eth0 -j external-internal 
    -A FORWARD -i eth0 -o eth1 -j internal-external 
    -A FORWARD -j NEVER 

    COMMIT

of course you need to turn on ip forwarding

    echo "1" > /proc/sys/net/ipv4/ip_forwarding

and uncomment lines in /etc/sysctl.conf

Also need a dhcpd server running with /etc/dhcp3/dhcpd.conf containing

    subnet 192.168.20.0 netmask 255.255.255.0 {
      range 192.168.20.10 192.168.20.20;
      option routers 192.168.20.254;
      option domain-name "globalsuite.net";
      option domain-name-servers 4.2.2.1;
    }

but could probably do this easier with dnsmasq.

Ca y est!
