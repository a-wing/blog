---
title: 关于 ajax 跨域调用 nginx
date: 2018-01-11 11:07:57+00:00
updated: 2018-01-11 11:07:57+00:00
categories: nginx
tags:
- nginx
---

今天遇上了就解决一下

关于HTTP访问控制（CORS）参考这篇文档

https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS



大体上分为两种情况。（这在好多文章里都没有。也可能是我理解有误。。）

一种是后端不支持跨域调用

用jsonp来解决。。。。应该是这样。好多文章鱼龙混杂。不太了解。后端代码可能为了一些认证问题吧jsonp（我不了解的事不应该乱说。。。）



一种是浏览器不支持跨域（我遇到的）

浏览器接收到了换返回信息，浏览器把信息拦截了 MDN文档里说的很清楚了

浏览器会检测信息是否同源。非同源要在header添加（貌似是规定）

`Access-Control-Allow-Origin: ×
`

用 nginx 代理转发添加header 来解决这个问题


    
    upstream localhost {
            server 127.0.0.1:3000;
    
    
        }
    
        server{
            server_name localhost;
            add_header Access-Control-Allow-Origin "*";
            location / {
                proxy_pass http://localhost;
                proxy_redirect off;
    
            }
    
        }





:补正。由于我用的是rails框架rails 内置cors方案 如用 new --api 默认不启用 要手动启用

如果不是要手动添加


    
    Gemfile
    
    gem 'rack-cors'
    
    cat config/initializers/cors.rb 
    
    
    
    # Be sure to restart your server when you modify this file.
    
    # Avoid CORS issues when API is called from the frontend app.
    # Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
    
    # Read more: https://github.com/cyu/rack-cors
    
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        #origins 'localhost:8080'
    
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end






