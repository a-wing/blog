---
title:  "DIY 无人机——遥控器篇"
date:   2018-02-20 16:00:35 +0800
updated:   2018-02-20 16:00:35 +0800
categories: uav
tags:
- uav
- diy
---

常见的遥控器接收机输出信号的有PWM、PPM、SBUS

最常用的PWM，不过近几年的发展PPM和SBUS开始增多（PWM由于体积原因一般只能有9个通道以下）

### 对码
遥控器和接收机是匹配的，不同品牌的接收机和遥控器不能混用

一个遥控器可匹配多个接收机。

> 遥控器可以有多个控制模型。每个控制模型可以有一个接收器

### 通道
什么是通道？我觉得这个概念解释起来有点麻烦。。。

在遥控航模系统中可以这么理解：同一时刻值为1000~2000之间的数（这句是我自己编的）

想让多旋翼飞起来至少要有5个通道，当然4个也可以。只不过要自己写飞控了～～

* Channel 1: Roll （横滚，理解成左右方向）
* Channel 2: Pitch  （俯仰，理解成前后方向）
* Channel 3: Throttle （油门，原本是电机输出的动力，近年来双回中遥控器出现，油门也可以变成上下方向）

> 注：油门输出大小属于手动控制油门，比较难以操控。油门控制上下属于自动控制油门，好操作

> 油门这种叫法其实很不准确，最早出现在内燃机上，汽车上基本上都叫油门，标准说法叫加速踏板
> 汽车上的加速踏板是控制节气门开度的，从而控制燃油的空燃比，造成发动机转速增快，来消耗更多的油

> Throttle 标准说法是节流阀，这个词应该是从固定翼上延续过来的

* Channel 4: Yaw （偏航，就像汽车的车头一样）
* Channel 5: Flight modes（飞行模式，飞控里都有这个，控制飞行模式的切换）

常见的基本上都是6~18个通道的遥控器

### 映射通道
大多数遥控器都支持自定义开关和通道的关系还有通道输出值的范围

一个开关可以控制同时多个通道

### 混控
用两个以上开关来控制一个通道，比较常见的混控是：两档开关+三挡开关 当六档开关来用

> 支持六种飞行模式的飞控很常见

### 失控保护
当接收机无法接收到遥控器信号时。将某一通道设为指定值

失控保护一般都设置在5通道的特殊取值上，让正常开关不会触发失控保护

失控保护也可以单独用一个通道

### 日本手 && 美国手
这方面的文章很多，不想啰嗦，因为这和原理无关，只是位置不同


## 市面的常见品牌和型号

#### FUTABA
日本的品牌，行业的标杆产品，一些油动无人机，都是用这种遥控器

14/16/18 多通道的遥控器首选，贵的要死，品质在哪放着那，小日本东西是不错（不服不行）

#### FrSKY （福睿斯）
极客必备，可以搭载开源操作系统 opentx，我司主要就用这款

可玩性极高，中文语言包啊，改音频素材啊，想怎么改就怎么改

X9D 16个通道，据说可以改到32个通道

#### WFLY （天地飞）
我最早接触的就是天地飞，国产的，深圳天地飞

天地飞7 曾经的经典型号

天地飞9 经典型号，遍地都是

天地飞T18 未来的型号，据说里面搭载了定制化android 系统，不过有几年没动静了。可能已经流产了

#### RadioLink（乐迪）
国产的，深圳乐迪，最早做玩具起家

AT9S 性价比高，功能强大，不过稳定性不足，当玩具不错，专业领域用的少（听一些植保队的人说，经常有因为遥控器失控导致炸机的）


#### FlySky （富斯）
国产的，深圳富斯，我不太了解这个品牌

以前有定制的航模，为了节约成本有配富斯遥控器的。

FS-i10 不了解，欢迎补充


### 还有好多我不知到的品牌，欢迎补充

