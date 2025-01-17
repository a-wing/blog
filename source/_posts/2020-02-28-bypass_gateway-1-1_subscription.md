---
title:  "自制旁路网关（一点一） ——增加clash订阅功能"
series: "自制旁路网关"
date:   2020-02-28 22:00:00 +0800
updated:   2020-02-28 22:00:00 +0800
categories: network
tags:
- linux
- network
- proxy
---

说起来也惭愧，因为觉得自己维护线路太麻烦，所以买了机场的服务，不过要使用机场，肯定要配合订阅来一起食用

订阅功能原理：本质上就是访问一个带 token 的 url。所以直接去 `curl` 那个地址就可以拿到配置文件

本文是接上一篇文章[自制旁路网关（一） ——使用clash做代理](/network/2020/02/22/bypass_gateway-1_clash.html)

其实就是定时去获取最新配置，从配置文件中取出自己需要的内容，然后重新加载配置文件（订阅到的配置可能不是你都需要的，只需要提取你需要的字段）

我用的是 n3ro.host（我并没有收广告费，n3ro 请打钱） 。。是基于 SSPanel 的机场，使用的是 clash 的订阅

先写一个核心文件用于处理配置文件，去更新关键性的字段。（这一步请自行判断自家使用的机场，订阅的配置文件内容）

你可以用这种方式来更新配置
```sh
cat config.yaml | head -32 > result.yaml && curl '<Your Subscription Address>' | grep Proxy: -A 1000 >> result.yaml && cp result.yaml config.yaml
```
不过这种方法极为不靠谱，不去理解配置文件语义，只靠行和关键字匹配，自己用好像没什么问题

我还是觉得理解配置文件并从中提取关键字段来更新的方法更好

先把这个服务命名为 subladder（不要吐槽命名）

创建文件`/etc/clash/subladder.rb`
```ruby
#!/usr/bin/env ruby
# Author: Metal A-wing
# E-mail: 1@233.email
# Create: 2020.02.22
# Update: 2020.02.22

require 'yaml'

raw = YAML.load_file(ENV['SOURCE_REMOTE'] || 'remote.yaml')
config = YAML.load_file(ENV['SOURCE_CONFIG'] || 'config.yaml')

update_whitelist = ["Proxy", "Proxy Group", "Rule"]

update_whitelist.each do |white|
	config[white] = raw[white]
end

File.open(ENV['RESULT_CONFIG'] || 'result.yaml', 'w') {|f| f.write config.to_yaml }
```
预留里一下可配置的项。

#### **肯定会有人有些这样的疑问**

1. 为什么要用 ruby 去实现这个功能？
> **老子想用什么语言就用什么语言，不服自己来写，我尽可能把这个处理脚本写的简单易懂**
>
> 很多语言 yaml 处理是使用第三方库来处理

2. 为什么不用 ruby 获取配置文件？
> 单独的文件处理应该是对整体无害的。只负责处理并生成的新的配置文件就够了


这里我们把配置用的字段统一提取放到一个新文件里 `/etc/clash/subladder.conf`
```sh
# 订阅地址
ADDRESS="https://nnn3ro.link/link/<Your Token>"

# 订阅的源文件缓存的文件名。被更新的字段来源的文件
SOURCE_REMOTE="remote.yaml"

# clash 实际加载的配置文件。（以这个文件为基本配置文件，去更新关键的字段）
SOURCE_CONFIG="config.yaml"

# 处理后的文件，更新了关键字段的结果文件
RESULT_CONFIG="result.yaml"
```


然后添加一个 systemd 单元的配置文件
`/etc/systemd/system/subladder.service`

```sh
[Unit]
Description=Subscription Remote Configuration
After=network.target

[Service]
Type=oneshot
WorkingDirectory=/etc/clash/
EnvironmentFile=/etc/clash/subladder.conf
ExecStartPre=/usr/bin/curl ${ADDRESS} -o ${SOURCE_REMOTE}
ExecStart=/usr/bin/ruby subladder.rb
ExecStartPost=/bin/sh -c "cp ${SOURCE_REMOTE} backup && cp ${RESULT_CONFIG} ${SOURCE_CONFIG} && systemctl restart clash.service"

[Install]
WantedBy=multi-user.target
```
这个文件我不想解释了。应该都能读懂

简单的说就是用 curl 去获取订阅到的配置文件，然后生成自己需要的配置文件，备份原来的配置，更新并重启


最后使用使用 systemd.timer 来定时执行任务 `/etc/systemd/system/subladder.timer`
```sh
[Unit]
Description=Run Subladder Daily

[Timer]
#OnCalendar=daily
OnCalendar=*-*-* 04:00:00
RandomizedDelaySec=60m

[Install]
WantedBy=timers.target
```
为什么不使用 `OnCalendar=daily` 。。。这个会在每天零点更新，实际测试的结果是：零点更新会失败，可能机场本身会在零点定时跑什么服务

然后启用这个定时器 `systemctl enable subladder.timer`

可以用这个来查看定时执行状态 `systemctl list-timers`

