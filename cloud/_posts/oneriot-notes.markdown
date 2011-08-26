
# oneriot infrastructure

20 data-nodes

fedora 13 (2.6.34.8-68)


kickstart
three classes of servers

heap
mappers
reducers

python
ssh to machines


"master site config"

namenode is set master


hadoop-env.sh
mapred-site
hdfs-site

---

config files in svn

xml


---

cloudera incremental updates

lzo compression 
(licensing?)

or 
snappy
talk to Juan about cloudera's use

















python scripts parse these

just hadoop config


lots of scripting ssh
system file limits
process limits

restarting datanode
after config changes


they stagger restart tasktracker
10minute timeout in hadoop
new datanode





---

hw no good raid mgmt
dell (old hardware)
in a colo

storage?

typical node:
6 disks (146
one boot 146
+ 750G drives

xen on xcp
  nn:
  job tracker:
  hive server:

65k files on the hadoop cluster

how to HA the NN?
plan to HA this

hadoop 20.1 release
one release before
backup node
checkpoint node

JVM
latest sun jvm
gc collection settings
heap 

and disk config is the only real changes between systems

single set of configs for all the jobs run

dev can override

dev happens on same cluster


fair schedule
interruptability by
preemt-timeout-scheduler 1minute














