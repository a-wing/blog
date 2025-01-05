---
layout: post
title:  "自制气象站"
author: metal A-wing
date:   2018-06-12 17:00:00 +0800
comments: true
categories: diy
---

最近来了个需求，要记录测量天气状况，来观测对无人机的影响


一路踩了一堆坑

> 先来看看树莓官网的气象站
>
> https://projects.raspberrypi.org/en/projects/build-your-own-weather-station/

### 这个最大的坑是买模块时不知道树莓官方有这个。。。。

我也仔细看了一下这个，简单说明一下

树莓官方的气象站是通过GPIO直接与传感器相连的，使用树莓来计算传感器读数，然后记录到数据库中

树莓有个叫 HAT (hardware attached on top) 板子，这个板子不参与任何运算。唯一的芯片 MCP3008 是数模转换芯片。汗。(⊙﹏⊙)b

用 Linux 本身读传感器有个潜在问题，Linux 是非实时操作系统，有个进程一直100%了就悲催了（误差也可能可以忽略不计）


### 然后看看我司淘宝给我买的板子：

> https://item.taobao.com/item.htm?id=21348003785

里面有 STC 的mcu ，直接串口发数据，是读完并且计算完之后的。爽到～

然后就又踩了大坑，因为考虑到数据量大，读写频繁，数据结构简单，然后我阴差阳错的选用了nodejs。express.js 和 MongoDB。。。。（express.js 读写MongoDB 有很好用的orm。本来想用postgresql的说）

第一次用 nodejs 写后端，感觉还不错

* * *
<br/>


### 介绍一下程序架构：
```
传感器 -> 天气模块-> serial -> socket -> http -> database
```
记录传上传到天气信息使用 get 请求，嗯把字符串加到url里。这样很轻量

然后读串口使用一个ser2sock 的中间件。把串口转成socket。这样只读socket就行了。2333333 （并且支持好多程序同时度）

记录日志就可以直接用 `nc localhost port > weather.log` 来保持日志了

为了图简单socket -> http 就用shell 来写吧。嗯，上代码：
```bash
#!/bin/sh

SOURCE_PATH=weather.log

while /usr/bin/inotifywait -e modify ${SOURCE_PATH};
do
  tail -1 ${SOURCE_PATH}
	#wget -qO- http://localhost:1207/put/$(tail -1 ${SOURCE_PATH} ) >> /dev/null
done

```

其实读到的数据是这个样子滴

```
weather.log MODIFY
A0066B09Setting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E000Setting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E0006F0017G0000H0000Setting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E0006F0017G0000H0000I0000J000Setting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E0006F0017G0000H0000I0000J0000K0000L0271M835NSetting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E0006F0017G0000H0000I0000J0000K0000L0271M835N09958Setting up watches.
Watches established.
weather.log MODIFY
A0066B090C0001D0003E0006F0017G0000H0000I0000J0000K0000L0271M835N09958*2B
```

因为串口每0.5s 发一次数据，写入速度有点快。。。

然后直接用nodejs来读socket。。。。。这里有坑。。（nodejs 读串口的库相当的难用）然后用ruby来写这段，嗯 ruby 大法好

这样有个问题 ruby 可没有那么好的异步能力。。。体会到nodejs的强大了，我只能把 socket -> http 这段和 http -> database 放在一起

考虑http协议的延时，和无状态。。后面信息跑到前面去也说不定。。所以数据库放在云端中间就走socket通信

嗯。好像没问题了。该上线了。。。。不。该去楼顶安装设备了


* * *
<br/>

树莓派就用上次USB口烧调的那个。。。废物利用。2333
![raspberryPI](/assets/img/weather_station/photo_2018-06-12_22-03-20.jpg)

都放到防水的盒子里。下面用热熔胶固定
![mcu](/assets/img/weather_station/photo_2018-06-12_22-03-21.jpg)

合个影
![mcu](/assets/img/weather_station/photo_2018-06-12_22-03-30.jpg)

把电源弄到楼顶上，大概要5M 长的USB 线。。。本来自己做了个usb线，实际用的时候有1V 的压降，就算电源给6V 仍然启动不了树莓。。。好迷。

最后用绿联的数据线，一个超长的MicoUSB线再加一个usb延长线，信号放大器还清晰可见
![usb](/assets/img/weather_station/photo_2018-06-12_22-03-42.jpg)

包一下延长线接口
![usb](/assets/img/weather_station/photo_2018-06-12_22-03-43.jpg)

安装完了
![weather_station](/assets/img/weather_station/photo_2018-06-12_22-03-45.jpg)

感觉不错
![weather_station](/assets/img/weather_station/photo_2018-06-12_22-03-46.jpg)

和前几天安装好的RTK基站合个影
![weather_station](/assets/img/weather_station/photo_2018-06-12_22-03-48.jpg)

* * *
<br/>

记录信息的后端程序放到github上了

[https://github.com/SB-IM/weatherS](https://github.com/SB-IM/weatherS)

> 这个坑可能还要接着填


