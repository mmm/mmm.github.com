---
layout:post
title: $i
tags: ["howto"]
---


cpu:
mpstat

network:
slurm
netstat 
ganglia

memory:
memstat
vmstat -S M
free -m
ps axl
pstree -G

I/O:
iostat

Misc:
sar/isar(?)
gkrellm

code:
LTT (Linux trace toolkit) (?)
ltrace
time
valgrind
** gprof **
strace
gdb
crash (kernel debugging util - gdb syntax)
kmtrace
leaktracer
oprofile
sysprof


old memory checkers:
electricfence
mcheck
checker

debuggers:
eclipse-cdt
gdb
insight
ddd
xxgdb
kdbg

