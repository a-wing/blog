---
layout: page
title:  "硬件设备"
author: metal A-wing
date:   2019-10-18 16:00:00 +0800
permalink: /equipment/
---
- router
  - ASUS RT-ac68u
  - Netgear wndr 4300
  - Youku l1c
  - Newifi 2
- PC
  - Dell xps 13 9360
  - MacBook Pro MF839
  - Lenovo yoga 13
- ARM
  - Raspberry pi 3B
  - Raspberry pi zero W
  - Rock pi 4 rk3399
  - Phicomm N1
- Phone
  - iphone se
  - pixel 2
- Home
  - 米家投影仪 青春版（咸鱼已出）
  - 小米米家智能摄像机 1080P
  - 小米米家床头灯2
  - TPLINK360度全景网络摄像头
  - 长帝 CRTF32K搪瓷烤箱
  - Kindle
  - iPad
  - ikbc DC87
  - Apple Watch Series 3
  - airpods 2
  - synology 218j
  - 暴风播库云
  - YubiKey 4
  - U 盘 Chipfancier 16g SLC
  - SWISS+TECH utili key
- UAV
  - 风火轮 F450
  - 天地飞 7

## Router
路由器我真的折腾不动了。。。还是 `openwrt` 最好用

[koolshare](https://firmware.koolshare.cn/) 的固件最省心，尤其是配合国内的上网环境

[padavan](https://opt.cn2qq.com/) 老毛子固件，我一直都觉得这个固件稳定性有问题，尤其是 DNS 解析上

[PandoraBox](https://downloads.pangubox.com/) 潘多拉固件，这个我用的比较少。。。感觉不出和 `openwrt` 的区别（据说用了些闭源驱动，性能更好）

首推 `ASUS RT-ac68u` 一代神机。目前我的主路由就是这个。其实我想换 `ASUS RT-ax88u` 。。可惜没钱（留下了贫穷的泪水

Netgear wndr 4300 也是很好用的。主要是 [openwrt](https://openwrt.org/toh/start) 好用

Youku l1c 这个一开始我用 padavan 固件。。后来用 PandoraBox 了

Newifi 2 这个和 Youku l1c 差不多。没啥值得说的地方 Youku l1c 是 MTK6120a 的方案，Newifi 2 是 MTK6121a

## PC
我从来都不玩游戏，也不需要什么高的配置

[xps 目前是我的主力机](/linux/2018/09/21/xps13_9360.html)

[Macbook pro 使用](/linux/2019/10/01/macbookpro.html)

Lenovo yoga 13 这个好像是联想第一代 pc 平板二合一的超级本。。。这款机器很蛋疼，首先原厂系统是 Win8。。嗯嗯大概只有在 Win8 下体验才是最好的吧，在 win10 下那个触摸屏驱动好像是有问题的，并不能每次都响应 PC 和平板之间的切换。还有我严重怀疑那个机器键盘设计的有问题，我已经换到了两个键盘了。。感觉应该是散热不合理，长期运行导致键盘过热寿命减短

## ARM
那一堆 ARM 机都是吃灰用的。没什么用也不建议买

## iphone se
超喜欢这个尺寸，拿在手里刚刚好

## pixel 2
备用机，吃灰用的

### 米家投影仪 青春版（咸鱼已出）
![mihome_projector.jpg](/assets/img/equipment/mihome_projector.jpg)

这东西投影出来的效果还是很不错的，自动对焦也很不错。这款不支持侧面投影，镜头焦距是固定的。（图上那个软件是我自己写的[弹幕播放器](https://github.com/a-wing/endplayer)

只可惜里面的系统是 MIUI TV 。。。tv 版的系统版权和其他播放平台是分开的。比如，b 站的大会员，然后 tv 版还要开一个 tv 大会员。然而 tv 版还看不了弹幕，里面的资源也不一样。。。

还有这东西发热量很大，开机风扇很吵。

airplay 来投屏还掉帧，抱歉，airplay 投屏视频真的没法看。

当蓝牙音箱？风扇转起来的噪音已经不想再那他听音乐了。。。小爱同学就是一个智障，和没有一样

### 小米米家智能摄像机 1080P
![mihome_monitor_1080p.jpg](/assets/img/equipment/mihome_monitor_1080p.jpg)

米家封闭生态智障摄像头，原生固件不支持任何开放接口，只能小米自己那个垃圾 App 控制，查看监控

这个硬件还是不错。固件 Github 上有破解的，可以 rtsp 推流，连接群晖

### 小米米家床头灯2

这个灯不错，支持 homekit， 还便宜，强力推荐

![mijia_bedside_lamp](/assets/img/equipment/mijia_bedside_lamp.jpg)


### TPLINK360度全景网络摄像头
![tplink-ipc53a.jpg](/assets/img/equipment/tplink-ipc53a.jpg)

这款产品的垃圾程度已远超出我的想像

这个东西很大，要比想像中的大好多。尺寸：`90mm×90mm×30mm` ，外壳的做工我就不吐嘈了

那个 WEB 端要看监控视频还要用 flash 。。。（嗯嗯，总比隔几秒刷新一个图片强）

那个手机的 app 。。。还能再做到烂一点吗？我原来一直都觉得米家的摄像头是垃圾。。。和这个一比：小米米家智能摄像机 1080P 那个摄像头原来这么好，又好又便宜

这个是有接口的，可以直接用 rtsp 。支持onvif协议

### 长帝 CRTF32K 搪瓷烤箱
![changdi_crtf32k.jpg](/assets/img/equipment/changdi_crtf32k.jpg)

我觉得这个不错，一二百的烤箱就不要考虑了，我买完又退了。最有用的功能是搪瓷和接渣盘。容易清理烤箱才应该放在首位的（

自从有了烤箱，我经常在家自己烤蛋挞

### Kindle
泡面神器。。。。畅销书资源很全，技术类的书好多都没有。水墨屏还是很不错的，这东西最大的优点就是除了看书之外什么都干不了

### iPad
这是我最喜欢的设备，也是我使用频率最高的一个设备，前几天我 iPad 的屏幕下方再闪。本来是个无关紧要的问题，去天才吧修。然后二话没说直接给我换了一个全新的。我现在吹爆苹果

### Apple Watch Series 3
这个很爽，我在深圳，可以使用 esim 。。。一号双终端，一号双终端使用费 10 元/月，首年免费用一年。 iphone 必须要和 apple watch 用同一个手机号。。。然后就是 apple pay 。。可以直接刷手表做地铁。

然后配合这个充电器创意底座，放在床头，来电话直接用手表接电话。我吹爆

![apple_watch.jpg](/assets/img/equipment/apple_watch.jpg)

### airpods 2
还不错，除了有点小贵，我一般一周充两次电

### synology 218j
群晖很好用。所谓 nas 就是放在一个角落，然后几年不去动他

### 暴风播库云
那个机箱的FLEX电源太吵了。。。晚上已经影响我休息了。。那个尺寸的电源基本没有声音小的

### YubiKey 4
这个感觉无所谓，实际价值不大。就是看起来很帅，没事玩玩还行

### U 盘 Chipfancier 16g SLC
![chipfancier_slc-usb_flash_drives](/assets/img/equipment/chipfancier_slc-usb_flash_drives.png)

强烈推荐这个 SLC U 盘。除了太贵之外就没有其他缺点了。装系统神器。。。这东西读写寿命超长（反复读写的那种）可以理解为 ssd 装了个 U 盘的主控芯片。除了碎片文件读写，其他的地方和 ssd 基本一样

### SWISS+TECH utili key
![utili-key](/assets/img/equipment/utili-key.png)

这个不是电子产品。不过我已经带了这个东西有五年了。非常好用的小工具

### UAV
**DIY 无人机这堆东西不想介绍了。心累**

