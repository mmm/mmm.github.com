---
layout: post
title: kvm disk management
tags: ['howto']
---

    lots of LVM stuff here
    http://www.jmcneil.net/2010/05/kvm-virtual-disk-access/

---

also,

    <disk type='block' device='disk'>
      <source dev='/dev/sde1'/>
      <target dev='hdb' bus='ide'/>
    </disk>

worked fine (showed up as /dev/sdb)

    <disk type='block' device='disk'>
      <source dev='/dev/sde1'/>
      <target dev='vdb' bus='virtio'/>
    </disk>

worked too (showed up as /dev/vda)

trying... /dev/sde instead of the single partition...

    <disk type='block' device='disk'>
      <source dev='/dev/sde'/>
      <target dev='vda' bus='virtio'/>
    </disk>

multiple direct mounts don't work... no real surprise here

ok, what about with some other options like:

    <disk type='file'>
      <driver name="tap" type="aio" cache="default"/>
      <source file='/var/lib/xen/images/fv0'/>
      <target dev='hda' bus='ide'/>
      <encryption type='...'>
        ...
      </encryption>
      <shareable/>
      <serial>
        ...
      </serial>
    </disk>

like 

    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none'/>
      <source dev='/dev/sde'/>
      <target dev='vda' bus='virtio'/>
      <shareable/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </disk>

(driver and address came from dumpxml)

this didn't work either
