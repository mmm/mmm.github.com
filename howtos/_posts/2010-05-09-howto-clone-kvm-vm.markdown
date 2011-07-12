---
layout: post
title: clone kvm vm
tags: ["howto"]
---


    mkdir /usr/local/kvm/newvm
    cd /usr/local/kvm/newvm

    # this didn't work...
    #virt-clone --original oldvm --name newvm --file /usr/local/kvm/newvm/root.qcow2 

    # this did
    virt-clone --connect=qemu:///system -o oldvm -n newvm -f /usr/local/kvm/newvm/root.qcow2
