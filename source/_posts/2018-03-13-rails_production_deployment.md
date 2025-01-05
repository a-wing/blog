---
layout: post
title:  "浅谈rails 项目自动部署"
author: metal A-wing
date:   2018-03-13 20:00:35 +0800
comments: true
categories: ruby
---

#### 一个项目从开发到上线。该记录点什么。

大概在几个月前开始开发一个管理系统，中间为了练手又写了个开源程序 [RailsGun](https://github.com/MoePlayer/RailsGun)

我觉得值得记录的就是从push 之后的自动化流程了

私有项目也在github

- 1.push 提交代码触发github webhook
- 2.jenkins跑持续集成，跑测试单元（公司项目用jenkins。练手项目用travis-ci.org。开源项目用org结尾的域名。闭源项目用com结尾的域名）
- 3.自动升级部署脚本


### github 触发没啥说的。github 有jenkins 应用插件

### jenkins
jenkins 要装github插件。接收github的触发hook

当然检测发布分支

为jenkins 服务器单独添加 deploy keys. 把公钥传给github 以确保可以clone 代码

jenkins 有rvm 插件。ruby 环境就变得很容易了。（刚开始不知道rvm，手动配环境。终于明白rvm 有多复杂了。手动配建议用rbenv）

rails test 我知道我测试单元写的很烂。。对集成测试单元测试的理解还不够

### 自动部署。（这里是重头戏）
先上代码：

```sh
#!/bin/bash
export RAILS_ENV=production
export POSTGRESQL_DATABASE_PASSWORD=97b841a29f151ed58e64c
export SECRET_KEY_BASE=97b841a29f151ed58e64cc2d7aa6c666360a8a470fde108fec2aff7ed103db38ecbaa85a533bd39890b3f83adcb0000274a7e6b3fc36b9b0830dc30b97a2818d


export PATH="$HOME/.rbenv/bin:$PATH:$HOME/.rbenv/shims"

echo $RAILS_ENV
pwd
ruby -v

cd 程序路径/
pwd

if test -e tmp/pids/server.pid
then
    echo 'Restarting'
    kill `cat tmp/pids/server.pid`
else
    echo 'Starting'
fi

bundle install
rake db:migrate
rails assets:precompile
rails server -d

```
每次覆盖代码运行这个脚本

原理：

> 程序执行之后会创建./tmp/pids/server.pid 文件。并把pid 写入里面

我在测试的时候加了这段代码，不然会找不到编译后的js和css

```sh
sed -i 's/config.assets.compile = false/config.assets.compile = true/g' config/environments/production.rb
```

我不太理解rails 这个默认参数。以后有待补充


两天后再来补充：

好多ruby on rails 自动部署的都是用`capistrano` 。关于这个以后有时间再研究



