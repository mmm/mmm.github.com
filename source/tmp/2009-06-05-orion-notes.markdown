---
layout:post
title: $i
tags: ["howto"]
---

svnadmin create /usr/local/svn/agile/doc
svnadmin create /usr/local/svn/agile/src

svn import doc file://localhost/usr/local/svn/agile/doc/orion -m'initial
revision'
svn import src file://localhost/usr/local/svn/agile/src/orion -m'initial
revision'


cd ~/etc
svn checkout svn+ssh://phantom/usr/local/svn/agile/doc/orion/trunk orion

cd ~/src/agile
svn checkout svn+ssh://phantom/usr/local/svn/agile/src/orion/trunk orion


