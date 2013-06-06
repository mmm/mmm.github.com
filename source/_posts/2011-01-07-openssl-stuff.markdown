---
layout: post
title: using openssl
categories: howtos
comments: true
---


    openssl req -new -newkey rsa:2048 -nodes -out star_jsas7_com.csr -keyout star_jsas7_com.key -subj "/C=JM/ST=/L=Kingston/O=Jamaica Ministry of Education/OU=IT/CN=*.jsas7.com"
