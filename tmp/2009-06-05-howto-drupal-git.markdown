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

git checkout -b modules
mkdir drupal/sites/all/modules
cd drupal/sites/all/modules
tar xzvf ~/Desktop/mymodule.tar.gz
git add mymodule
git commit -a -m'added mymodule'
git push origin modules

git checkout -b production
cd drupal/sites/default
deal with settings.php
git push origin production

***updating drupal***

git checkout drupal
rm -Rf drupal
tar xzvf new-drupal-version
mv drupal-new drupal
git add drupal
git commit -a -m'new-drupal-version'
git push

git checkout modules
git pull . drupal
git checkout production
git pull . modules

***updating module***

git checkout modules
cd sites/all/modules
tar xzvf ~/new-module-version.tar.gz
git add new-module
git commit -a -m'new-module-version'
git push

git checkout production
git pull . modules

********************



mostly just work in production branch

git checkout production
vi drupal/sites/all/themes/mytheme/page.tpl.php
git commit -a -m'some kind of update'
git push

cap deploy





