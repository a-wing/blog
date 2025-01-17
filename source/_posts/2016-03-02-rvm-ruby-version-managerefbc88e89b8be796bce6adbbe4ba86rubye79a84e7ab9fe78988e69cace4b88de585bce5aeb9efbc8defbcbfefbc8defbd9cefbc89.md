---
title: 'RVM: Ruby Version Manager（蛋疼死了ruby的竟版本不兼容－＿－｜）'
date: 2016-03-02 03:55:30+00:00
updated: 2016-03-02 03:55:30+00:00
categories: ruby
tags:
- linux
- ruby
---

安装RVM，软件源里没有

github:[https://github.com/rvm/rvm](https://github.com/rvm/rvm)

安装太简单不解释（加权限(chmod.......)，./install）

source ~/.rvm/scripts/rvm

rvm list known #列出已知的ruby版本

rvm install 1.9.3 #安装一个ruby版本

rvm use 1.9.3 #使用一个ruby版本

rvm use 1.9.3 --default

rvm list #查询已经安装的ruby

rvm remove 1.9.2 #卸载一个已安装版本

gemset的使用

rvm不仅可以提供一个多ruby版本共存的环境，还可以根据项目管理不同的gemset.

gemset可以理解为是一个独立的虚拟gem环境，每一个gemset都是相互独立的。

比如你有两个项目，一个是rails 2.3 一个是 rails 3. gemset可以帮你便捷的建立两套gem开发环境，并且方便的切换。

gemset是附加在ruby语言版本下面的，例如你用了1.9.2, 建立了一个叫rails3的gemset,当切换到1.8.7的时候，rails3这个gemset并不存在。

建立gemset

rvm use 1.8.7
rvm gemset create rails23

然后可以设定已建立的gemset做为当前环境

use 可以用来切换语言，或者gemset,前提是他们已经被安装(或者建立)。并可以在list命令中看到。

rvm use 1.8.7
rvm use 1.8.7@rails23

然后所有安装的gem都是安装在这个gemset之下。

列出当前ruby的gemset

rvm gemset list

清空gemset中的gem

如果你想清空一个gemset的所有gem,想重新安装所有gem，可以这样

rvm gemset empty 1.8.7@rails23

删除一个gemset

rvm gemset delete rails2-3

项目自动加载gemset

rvm还可以自动加载gemset.

例如我们有一个rails3.1.3项目，需要1.9.3版本ruby.整个流程可以这样。

rvm install 1.9.3
rvm use 1.9.3
rvm gemset create rails313
rvm use 1.9.3@rails313

下面进入到项目目录，建立一个.rvmrc文件。

在这个文件里可以很简单的加一个命令：

rvm use 1.9.3@rails313

如果上述有错误如下

rvm use 2.2.3@rails223 --create

参考如下文章

[https://ruby-china.org/topics/576](https://ruby-china.org/topics/576)
