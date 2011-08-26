---
layout:post
title: $i
tags: ["howto"]
---

pick a wiki database name

mysqladmin create dbname
mysql
grant all...
use dbname;
alter database default character set utf8 collate utf8_general_ci;

set up svn repo for the project

pick a wiki path

trac-admin <path> initenv
the database url looks like mysql://agile:agile@localhost/agile_trac

copy over apache configuration info (with fastcgi lines too) to set up new site.


also something different in the templates directories


then set admin roles using trac-admin:
cd <trac directory>
sudo trac-admin . permission add mmm TRAC_ADMIN
for i in `sudo trac-admin . permission list | awk '/anonymous/ { print $2 }'`; do sudo trac-admin . permission add authenticated $i; done
for i in `sudo trac-admin . permission list | awk '/anonymous/ { print $2 }'`; do sudo trac-admin . permission remove anonymous $i; done
sudo trac-admin . permission list


----------------------------------------

  441  passgen; echo
  442  exit
  443  cd /usr/local/soy/
  444  less ../Agile/wiki/conf/trac.ini
  445  trac-admin trac initenv
  446  ls
  447  ls trac/
  448   cd ../soy/trac/
  449  cd
  450  cd /usr/local/
  451  sudo chmod 2775 soy/
  452  sudo chmod 2775 cause/
  453  cd soy/
  454  cd ../cause/
  455  find . -not -type d | xargs chmod 664
  456  find . -type d | xargs chmod 2775
  457  ls htdocs/
  458  ls log/
  459  cd ../../soy/trac/
  460  mkdir images
  461  sudo chown www-data.www-data htdocs/ images/ log/
  462  cd ..
  463  ls -al ../hot/wiki/conf/
  464  ls -al trac/
  465  ls -al trac/conf/
  466  cd trac/
  467  cd conf/
  468  cd ../../../cause/trac/conf/
  469  cp trac.ini trac.ini.dist
  470  sudo chown mmm.www-data trac.ini
  471  ls -al
  472  history 
phantom:/usr/local/cause/trac/conf $ 
  463  ls ../hot/
  464  ls ../hot/cgi-bin/
  465  mkdir cgi-bin
  466  ls -al ../hot/cgi-bin/
  467  cp ../hot/cgi-bin/trac.fcgi .
  468  mv trac.fcgi cgi-bin/
  469  cp -R ../hot/cgi-bin .
  470  sudo chown -Rf mmm.dev trac
  471  cd ../../cause/
  472  sudo chown -Rf mmm.dev trac/
  473  cd trac/
  474  sudo chown -Rf www-data.www-data htdocs images log
  475  diff /usr/local/hot/wiki/conf/trac.ini trac.ini
  476  diff /usr/local/hot/wiki/conf/trac.ini trac.ini -u | less
  477  cd /usr/local/hot/
  478  cd ../soy/
  479  cd cgi-bin/
  480  cd ../../cause/cgi-bin/
  481  vi trac.fcgi 
  482  cd ../../hot/cgi-bin/
  483  cd wiki/
  484  cd images/
  485  ls latex/
  486  ls ht
  487  ls htdocs/
  488  cd /usr/local/svnroot/
  489  mkdir soy
  490  mkdir cause
  491  cd soy/
  492  ls -al
  493  svnadmin create src
  494  cd ..
  495  cd
  496  cd /usr/local/cause/trac/
  497  cd conf/
  498  ls
  499  vi trac.ini
  500  history
phantom:/usr/local/cause/trac/conf $ 




------------------------------------------------



  501  cd /etc/apache2/
  502  cd sites-enabled/
  503  ls
  504  ls ../sites-available/
  505  cd ../sites-available/
  506  ls
  507  less litmus
  508  less secure 
  509  ls ../sites-enabled/
  510  ls
  511  less hot 
  512  ls
  513  cp litmus soy
  514  cp litmus cause
  515  vi soy cause -p
  516  vi secure 
  517  vi agile 
  518  cd ../sites-enabled/
  519  ls
  520  ln -s ../sites-available/soy 008-soy
  521  ln -s ../sites-available/cause 009-cause
  522  ls
  523  cd /usr/local/Agile/wiki/
  524  ls -al
  525  cd htdocs/
  526  ls -al
  527  cd ../log/
  528  ls -al
  529  cd ..
  530  ls
  531  ls -al
  532  cd ../../hot/
  533  ls -al
  534  cd wiki/
  535  ls -al
  536  history
root@phantom:/usr/local/hot/wiki# 
  476  cd /usr/local/cause/trac/htdocs/
  477  ls -al
  478  cp /usr/local/hot/wiki/htdocs/agile_logo.jpg .
  479  ls -al
  480  cd ../../../soy/trac/htdocs/
  481  cp /usr/local/hot/wiki/htdocs/agile_logo.jpg .
  482  apache2ctl restart
  483  ps auwx | grep python
  484  ps auwx | grep python
  485  ps auwx | grep python
  486  ps auwx | grep python
  487  ps auwx | grep python
  488  ps auwx | grep python
  489  ps auwx | grep python
  490  ps auwx | grep python
  491  cd ../../cgi-bin/
  492  ls -al
  493  vi trac.fcgi 
  494  cd ../..
  495  vi cause/cgi-bin/trac.fcgi 
  496  apache2ctl restart
  497  ps auwx | grep python
  498  ps auwx | grep python
  499  apache2ctl restart
  500  exit
  501  history
root@phantom:~# 




