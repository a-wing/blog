---
author: shiyongxin
comments: true
date: 2017-07-03 08:28:00+00:00
layout: post
link: http://a-wing.top/rails_production/
slug: rails_production
title: rails部署
wordpress_id: 115
categories:
- ruby
---

就是记几个容易忘的地方




    
    vim config/secrets.yml
    ## 产品环境秘钥
    
    vim config/environments/production.rb
    ## 修改配置
    config.assets.compile = false
    ## 改成
    config.assets.compile = true
    
    ## 运行
    RAILS_ENV=production bin/rails assets:precompile
    
    
    ## 产品环境启动
    rails s -e production
    
    
    apache代理配置
    
    ## 启用模块
    LoadModule proxy_module modules/mod_proxy.so
    
    LoadModule proxy_http_module modules/mod_proxy_http.so
    
    ## 虚拟主机配置
    <VirtualHost *:80>
        ServerAdmin admin@admin.com
        ServerName localhost.com
        ProxyRequests Off
        <Proxy *>
            Order deny,allow
            Allow from all
        </Proxy>
        ProxyPass / http://localhost:3000/
        ProxyPassReverse / http://localhost:3000/
    </VirtualHost>
    
    
    




