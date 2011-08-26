---
layout:post
title: $i
tags: ["howto"]
---



interface=eth0
bridge=br0
sudo sed -i "s/^iface $interface inet \(.*\)$/iface $interface inet manual\n\nauto br0\niface $bridge inet \1/" /etc/network/interfaces
sudo tee -a /etc/network/interfaces <<EOF
        bridge_ports $interface
        bridge_fd 9
        bridge_hello 2
        bridge_maxage 12
        bridge_stp off
EOF
sudo /etc/init.d/networking restart

