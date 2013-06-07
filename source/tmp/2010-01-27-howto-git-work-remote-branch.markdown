---
layout:post
title: $i
tags: ["howto"]
---



$ git checkout --track -b <local name> origin/<remote name>
Note: this creates a local branch <local name> based on the upstream branch and switches your working copy to that branch.
$ git pull
$ git push origin <local name>
Sometimes you may need to use the following instead of that last commit:

$ git push origin <local name>:<remote name without origin/>

