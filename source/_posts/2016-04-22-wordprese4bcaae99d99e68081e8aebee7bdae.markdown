---
author: shiyongxin
comments: true
date: 2016-04-22 14:09:44+00:00
layout: post
link: http://a-wing.top/wordpres%e4%bc%aa%e9%9d%99%e6%80%81%e8%ae%be%e7%bd%ae/
slug: wordpres%e4%bc%aa%e9%9d%99%e6%80%81%e8%ae%be%e7%bd%ae
title: wordpres伪静态设置
wordpress_id: 68
categories:
- wordpress
---

我操作系统是debian，apache

    
    ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load


载入重写模块

    
    <code>    <Directory /var/www/html>
            Options FollowSymLinks MultiViews
            AllowOverride all
            Order allow,deny
            allow from all
        </Directory></code>


允许重写

    
    sudo service apache2 restart


重启apache服务

设置wordpress
