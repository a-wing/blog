---
title: wordpres 伪静态设置
date: 2016-04-22 14:09:44+00:00
updated: 2016-04-22 14:09:44+00:00
categories: wordpress
tags:
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
