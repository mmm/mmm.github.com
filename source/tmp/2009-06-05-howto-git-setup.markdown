---
layout:post
title: $i
tags: ["howto"]
---


*** on the server...

mkdir /git/academy/app.git
cd /git/academy/app.git
git --bare init


*** on the client
mkdir work
cd work
git init
vi README
git add .
git commit -a -m'initial revision'

git-config remote.origin.url dev:/git/academy/app.git
git checkout master
git push origin master

git checkout -b drupal
tar xzvf ~/Desktop/drupal-6.9.tar.gz
mv drupal-6.9 drupal
git add drupal/
git commit -a -m'drupal-6.9'
git tag drupal-6.9
git push origin drupal

