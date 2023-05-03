---
layout: post
title:  "嘿 siri 把家里的门打开"
author: metal A-wing
date:   2019-03-15 17:00:00 +0800
comments: true
categories: diy
---

![argus_active](/assets/img/hey_siri_open_door/argus.webp)


这东西本来是我上大学时写的一个项目，现在把他重构了一遍

这回还真是从焊电路到前端，一个人全干了

我最熟悉语言是 `ruby` 。。为什么要用 `python` 来重写？

我只是想用一门通用的编程语言来把他表现出来。编程是思维，而不是仅限于语言和框架（写之前用来几个小时把python语法重新看了一边）

同时也有一种想法，把他变成教科书级的项目（我的水品太差，`pylint` 一测，一点也不够 `pep8` ）

**看到这，你也应该明白了。这篇文章不是教程，而是开发笔记**

* * *
<br>
<br>
<br>

尽量使用最基本的库，最精简的实现（依赖只有 bottle ）

### ？？？ 什么用了树莓的 GPIO 竟然没用gpio库？

没错，你没有听错，如果你了解 gpio 库的实现，其实就会明白，其实gpio根本不需要库。。。（当然，比较复杂的项目最好还是用库）

[先来上个地址：](https://sourceforge.net/projects/raspberry-gpio-python/)

这个是树莓 gpio 库的的代码仓库

[看这段：](https://sourceforge.net/p/raspberry-gpio-python/code/ci/default/tree/source/event_gpio.c#l82)

其实不难看出，操控 gpio 其实就是在向 `/sys/class/gpio/` 里面写数据

基本的操作很简单，直接看这段代码： https://github.com/JRT-FOREVER/argus/blob/master/scripts/init.sh

```shell
# 初始化 2, 3 gpio接口
echo 2 > /sys/class/gpio/export
echo 3 > /sys/class/gpio/export

# 设置方向
echo out > /sys/class/gpio/gpio2/direction
echo out > /sys/class/gpio/gpio3/direction
```

控制输出高低电平，只需要先初始化，之后指定方向（输入是 `in` 输出是 `out`）

然后就可以 `echo 1 > /sys/class/gpio/gpio2/value` 这样来控制了

不用的时候 `echo 2 > /sys/class/gpio/unexport` 就可以释放了

看，gpio 操纵根本不需要库（

### 这不仅仅是一个项目，其实是一个最小的工程项目代码

使用 `TDD` 方式开发，其实我比较懒，只写了几个核心的 `class` 的测试，bottle 没提供单元测试方案，工程化还是要用 `Flask` （逃

这东西我一行 `javascript` 都没写。手撸 `html` 和 `css`。用 css 手撸的壁纸

![argus_login](/assets/img/hey_siri_open_door/argus_login.png)

然后自己给argus做个logo:

<p align="center">
  <img src="/assets/img/hey_siri_open_door/argus_logo.jpg" alt="argus_logo" width="200">
</p>

#### 我写了三个class

1. 用户
支持多用户，支持多种密码模式，精简的实现了 `salt + sha1` 密码存储

2. 执行器
支持 hook。程序启动时，执行命令之前，执行命令之后，程序结束时
可以自定义 hook，开门这个动作就属于用这个 hook 的实现

3. 过滤器
考虑到暴露公网的情况，对连续输入帐号密码错误的，ban 掉 ip 。


### 部署，别和我说什么 `gunicorn`, `uwsgi`
我就是个单线程的程序，没并发。。。多 worker 启动时 hook 当然会执行很多次

如果用 gunicorn 之类的请设置 `workers=1`

直接 `systemctl start argus.service` 就可以启动


### 也打了 debian 的 deb 包 和 archlinux 的 AUR
说到 deb 打包。。。。debian 打个包真费劲。我比较懒，就直接封装的 `checkinstall`。这不是标准的 deb 打包方案

当然要用 systemd 来管理。。（嗯，systemd 真香

## 这本身就是一个很简单的东西，祝玩的愉快

项目地址：[https://github.com/JRT-FOREVER/argus/](https://github.com/JRT-FOREVER/argus/)

**最后要吐槽一下，siri 就他 TM 是个智障！！！**

