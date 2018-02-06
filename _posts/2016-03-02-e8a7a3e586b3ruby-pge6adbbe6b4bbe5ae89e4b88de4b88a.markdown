---
author: shiyongxin
comments: true
date: 2016-03-02 04:01:26+00:00
layout: post
link: http://a-wing.top/%e8%a7%a3%e5%86%b3ruby-pg%e6%ad%bb%e6%b4%bb%e5%ae%89%e4%b8%8d%e4%b8%8a/
slug: '%e8%a7%a3%e5%86%b3ruby-pg%e6%ad%bb%e6%b4%bb%e5%ae%89%e4%b8%8d%e4%b8%8a'
title: 解决ruby pg死活安不上
wordpress_id: 53
categories:
- ruby
- 环境
---

问题如下

    
    gem install pg -v '0.17.1'
    Building native extensions.  This could take a while...
    ERROR:  Error installing pg:
    	ERROR: Failed to build gem native extension.
    
        /home/metal/.rvm/rubies/ruby-2.2.3/bin/ruby -r ./siteconf20160302-12784-fo1uxu.rb extconf.rb
    checking for pg_config... yes
    Using config values from /usr/bin/pg_config
    You need to install postgresql-server-dev-X.Y for building a server-side extension or libpq-dev for building a client-side application.
    You need to install postgresql-server-dev-X.Y for building a server-side extension or libpq-dev for building a client-side application.
    checking for libpq-fe.h... no
    Can't find the 'libpq-fe.h header
    *** extconf.rb failed ***
    Could not create Makefile due to some reason, probably lack of necessary
    libraries and/or headers.  Check the mkmf.log file for more details.  You may
    need configuration options.
    
    Provided configuration options:
    	--with-opt-dir
    	--without-opt-dir
    	--with-opt-include
    	--without-opt-include=${opt-dir}/include
    	--with-opt-lib
    	--without-opt-lib=${opt-dir}/lib
    	--with-make-prog
    	--without-make-prog
    	--srcdir=.
    	--curdir
    	--ruby=/home/metal/.rvm/rubies/ruby-2.2.3/bin/$(RUBY_BASE_NAME)
    	--with-pg
    	--without-pg
    	--with-pg-config
    	--without-pg-config
    	--with-pg_config
    	--without-pg_config
    	--with-pg-dir
    	--without-pg-dir
    	--with-pg-include
    	--without-pg-include=${pg-dir}/include
    	--with-pg-lib
    	--without-pg-lib=${pg-dir}/lib
    
    extconf failed, exit code 1
    
    Gem files will remain installed in /home/metal/.rvm/gems/ruby-2.2.3/gems/pg-0.17.1 for inspection.
    Results logged to /home/metal/.rvm/gems/ruby-2.2.3/extensions/x86_64-linux/2.2.0/pg-0.17.1/gem_make.out


原因是缺少postgresql的开发库

debian : apt-get install postgresql-server-dev-all

contsos : yum install postgresql-devel
