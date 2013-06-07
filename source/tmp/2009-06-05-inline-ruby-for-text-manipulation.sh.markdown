---
layout:post
title: $i
tags: ["howto"]
---


ruby -ne '@found=true if $_ =~ /^CREATE TABLE `foo`/i; next unless @found; exit if $_ =~ /^CREATE TABLE (?!`foo`)/i; puts $_;' giant_sql_dump.sql > foo.sql
