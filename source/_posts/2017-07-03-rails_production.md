---
title: rails 部署
date: 2017-07-03 08:28:00+00:00
updated: 2017-07-03 08:28:00+00:00
categories: ruby
tags:
- linux
- ruby
- rails
---

就是记几个容易忘的地方


```sh

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
```

### 半年之后来更新这篇文章。在bash上运行

##### Update 2018.03.06

新建用户

```sh
adduser rails

su rails

```
安转rvm && 配置。以2.5.0为例

```sh
curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

rvm install 2.5.0

rvm default 2.5.0
```



vim ~/.bashrc

在.bashrc 末尾添加
```bssh
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm


# 以下环境变量和rails 程序配置有关

# 设置产品环境
export RAILS_ENV=production

# postgreSQL 密码
export POSTGRESQL_DATABASE_PASSWORD=mFpbHNndW4Kawegewrrheswyrtueyrt

# 产品环境密钥
export SECRET_KEY_BASE=30a9359867c893f709d23a637awrhertewthtre9814533ac6f8c1e20fe0dbe1251055c70d00dd5accf487b6702443d7a0afde075f7fc8b85d1710668936

```


安装gem && 启动

> 非纯API应用要编译JavaScript
>
> 其实这个参数我也不太理解。如果是默认值会有找不到编译玩的js的情况。改了这个就好了
>
> vim config/environments/production.rb
>
> config.assets.compile = true
>
> 编译JavaScript
>
> rails assets:precompile

```sh
bundle install

rails server
```

产品环境应该已服务类型启动

```sh
rails server -d

# 关闭服务
kill `cat tmp/pids/server.pid`
```



