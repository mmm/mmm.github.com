---
layout:post
title: $i
tags: ["howto"]
---

create a server key:
# openssl genrsa -des3 -out server.key 1024

generate a csr for this key:
# openssl req -new -key server.key -out server.csr

generate a CA (secret) key:
# openssl genrsa -des3 -out MyCA.key 1024

create an x509 (public) certificate for the CA:
# openssl req -new -x509 -days 365 -key MyCA.key -out MyCA.crt

sign a cert:
# openssl -config ./openssl.cnf -in server.csr -out server.crt
where openssl.cnf is just a copy/mod of the dist one

read contents of a cert or key:
# openssl x509 -noout -text -in server.crt

Note that the server key for apache needs to be unencrypted for automatic httpd startup...
# mv crap.key crap.key.encrypted
# openssl rsa -in crap.key.encrypted -out crap.key
# chmod 400 crap.key


