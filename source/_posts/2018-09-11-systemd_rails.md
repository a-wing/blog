---
title:  "使用 systemd 来管理你的 rails 应用"
date:   2018-09-11 07:00:00 +0800
updated:   2018-09-11 07:00:00 +0800
categories: ruby
tags:
- linux
- systemd
- ruby
- rails
---

这篇文章属于没什么卵用系列

我并不喜欢 `capistrano`


众所周知 rails 的项目启动用 `RAILS_ENV=production bundle exec rails server -p 3000 -d`

如果服务器经常重启。。最简单的办法：那我们就要把这条命令放在 /etc/rc.local 里(目前deb系的发行版是保留的。本质上是用 systemd 来执行这里的命令)。。。

不过目前。大部分 Linux Distribution 都是 systemd 来启动的（gentoo 除外。gentoo 默认是 openrc，可以换成 systemd ）

在改之前。我们先把 rails 监听的端口换成 unix sock
```sh
sed -i 's#port        ENV.fetch("PORT") { 3000 }#bind        "unix://\#{Rails.root}/tmp/sockets/puma.sock"#g' config/puma.rb
```


例如我的项目叫kiss2u 大概是这样:

```sh
$ cat ~/.config/systemd/user/kiss2u.service
```

```
[Unit]
Description=KISS2U Puma application server
After=network.target

[Service]
WorkingDirectory=/home/a-wing/.srv/KISS2U
PIDFile=/home/a-wing/.srv/KISS2U/tmp/pids/puma.pid
ExecStart=/usr/bin/sh /home/a-wing/.srv/KISS2U/run.sh

[Install]
WantedBy=default.target
```

没错。这个是用户级 systemd

但由于 systemd 要写绝对路径。。但我可不想手动改 QAQ

然后我们定义一个 template，就像这样。定义几个标签
```
$ cat config/kiss2u.service.template
[Unit]
Description=KISS2U Puma application server
After=network.target

[Service]
WorkingDirectory=<DIR>
Environment=RAILS_ENV=production
PIDFile=<DIR>/tmp/pids/puma.pid
ExecStart=<BUNDLE> exec rails server

[Install]
WantedBy=default.target
```

在 bin 目录下创建生成真正的systemd 的配置文件 bin/generate_service.sh

当然我们是要新建一个用户来跑的。不然 generate_service.sh 就没意义了

```bash
#!/bin/bash

SYSTEMD=kiss2u.service

cp config/${SYSTEMD}.template ${SYSTEMD}
sed -i s#\<DIR\>#`pwd`#g ${SYSTEMD}
sed -i s#\<BUNDLE\>#`which bundle`#g ${SYSTEMD}


echo "Install ~/.config/systemd/user/${SYSTEMD}"
echo "Please Run: systemctl --user start ${SYSTEMD}"

install ${SYSTEMD} -D ~/.config/systemd/user/${SYSTEMD}
rm ${SYSTEMD}
```

然后来使用 `systemctl --user start kiss2u` 就可以启动了

要开机启动的话 `systemctl --user enable kiss2u` 就可以

### **不过。这么做仍然有问题**

我在 rbenv 下测试是好使的。。。在有些环境下就会出现启动不了的情况。我也不知道是为什么啊 QAQ

如果你启动出问题请更改 `ExecStart=`

解决办法： 兼容性最好`ExecStart=` 来启动一段 shell 脚本。在 shell 脚本里加载必要的变量
```sh
source ./config.sh

echo RAILS_ENV=${RAILS_ENV}
ruby -v

if test -e tmp/pids/server.pid
then
  echo 'Restarting'
  kill `cat tmp/pids/server.pid`
else
  echo 'Starting'
fi

bundle install --path vendor/bundle
bundle exec rake db:migrate
bundle exec rails server -p ${PORT} -d
```
类似这样。。。好吧。我承认这很不优雅。。。不过兼容性最好。。


### 对了 kiss2u 是开源项目，你可以直接去看源代码 <-----自买自夸

[https://github.com/a-wing/KISS2U](https://github.com/a-wing/KISS2U)


参考文章：
- [Arch Linux wiki](https://wiki.archlinux.org/index.php/Rails)
- [依云's Blog: systemd 之用户级服务管理](https://blog.lilydjwg.me/2014/2/2/systemd-user-daemons.42631.html)


