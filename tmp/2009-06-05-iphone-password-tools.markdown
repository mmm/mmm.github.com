---
layout:post
title: $i
tags: ["howto"]
---

wilbur:~ $ openssl passwd -crypt -salt /s alpine
/smx7MYTQIi2M
wilbur:~ $ openssl passwd -crypt -salt 2A thnksfrmMe
Warning: truncating password to 8 characters
2ADXViAMbc/l.
wilbur:~ $ perl -e 'print crypt("thnksfrmMe", "2A")."\n"'
2ADXViAMbc/l.
wilbur:~ $ 


