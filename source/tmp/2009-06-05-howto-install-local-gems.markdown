---
layout:post
title: $i
tags: ["howto"]
---


rpm -Uvh http://mirror.centos.org/centos/5/os/i386/CentOS/python-iniparse-0.2.... 
rpm -Uvh http://mirror.centos.org/centos/5/os/i386/CentOS/yum-[latest].rpm 
yum remove ruby 
wget ftp://ftp.ruby-lang.org:21/pub/ruby/1.8/ruby-1.8.6.tar.gz 
tar xzvf ruby-1.8.6.tar.gz && cd ruby-1.8.6 
./configure && make && make install 
source /etc/profile;ruby -v 
ruby 1.8.6 (2007-03-13 patchlevel 0) [i686-linux] 
echo 'export PATH=/usr/local/bin:$PATH' > /etc/profile.d/ruby.sh; source /etc/profile 
wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz 
tar -xzvf rubygems-1.3.1.tgz 
cd rubygems-1.3.1 
export GEM_HOME=/usr/local/rubygems/gems; mkdir -p $GEM_HOME 
ruby setup.rb all --prefix=/usr/local/rubygems 

vi /etc/profile.d/rubygems.sh   
export GEM_HOME=/usr/local/rubygems/gems 
export GEM_PATH=/usr/local/rubygems/gems 
export RUBYLIB=/usr/local/rubygems/lib 
export PATH=/usr/local/rubygems/gems/bin:/usr/local/rubygems/bin:$PATH 

source /etc/profile 

Now the gem installations 
gem install --version '=2.2.2' actionmailer 
gem install --version '=2.2.2' activeresource activesupport 
gem install --version '=1.0.1' fastthread 
gem install --version '=2.7' mysql -- --with-mysql-config 
gem install --version '=2.0.6' passenger 
gem install --version '=0.8.3' rake 
gem install --version '=2.2.2' rails 
gem install --version '=1.2.4' sqlite3-ruby 
gem install --version '2.0.6' passenger 
passenger-install-apache2-module 

==================== 
These are the steps follow
