---
layout: page
title: 陈列室
date:   2021-02-02 17:00:00 +0800
toc: true
permalink: /projects/
---

## filegogo [![filegogo](https://img.shields.io/github/stars/a-wing/filegogo.svg?style=social&label=Star)](https://github.com/a-wing/filegogo/)

[![Go Report Card](https://goreportcard.com/badge/github.com/a-wing/filegogo)](https://goreportcard.com/report/github.com/a-wing/filegogo)
[![GitHub release](https://img.shields.io/github/tag/a-wing/filegogo.svg?label=release)](https://github.com/a-wing/filegogo/releases)
[![license](https://img.shields.io/github/license/a-wing/filegogo.svg?maxAge=2592000)](https://github.com/a-wing/filegogo/blob/master/LICENSE)

[send.22333.fun](https://send.22333.fun) | [send.cn.22333.fun](https://send.cn.22333.fun)

[![Demo.gif](https://i.postimg.cc/wTyzyHMc/Peek-2020-10-24-11-29.gif)](https://github.com/a-wing/filegogo/)

一个跑在浏览器上的 P2P 文件传输工具，基于 WebRTC

### lightcable [![lightcable](https://img.shields.io/github/stars/a-wing/lightcable.svg?style=social&label=Star)](https://github.com/a-wing/lightcable)

最初是我写的一个 WebRTC 的 websocket signaling 服务端，后来集成在 filegogo 里面

后来逐渐发现这个模块有其他用途，就把这个模块单独拆出来了

这是一个极为精简的 websocket 的聊天室服务，至于这个东西还可以用在什么地方上，就只能去自己探索了

~~部分使用 socket.io 的场景都可以使用这个来替代**（注意：是部分场景）**~~

* * *

## jsonrpc-lite [![jsonrpc-lite](https://img.shields.io/github/stars/SB-IM/jsonrpc-lite.svg?style=social&label=Star)](https://github.com/SB-IM/jsonrpc-lite/)

[![PkgGoDev](https://pkg.go.dev/badge/github.com/SB-IM/jsonrpc-lite)](https://pkg.go.dev/github.com/SB-IM/jsonrpc-lite)
[![Build Status](https://travis-ci.org/SB-IM/jsonrpc-lite.svg?branch=master)](https://travis-ci.org/SB-IM/jsonrpc-lite)
[![codecov](https://codecov.io/gh/SB-IM/jsonrpc-lite/branch/master/graph/badge.svg)](https://codecov.io/gh/SB-IM/jsonrpc-lite)
[![Documentation](https://godoc.org/github.com/SB-IM/jsonrpc-lite?status.svg)](http://godoc.org/github.com/SB-IM/jsonrpc-lite)
[![Go Report Card](https://goreportcard.com/badge/github.com/SB-IM/jsonrpc-lite)](https://goreportcard.com/report/github.com/SB-IM/jsonrpc-lite)
[![GitHub release](https://img.shields.io/github/tag/SB-IM/jsonrpc-lite.svg?label=release)](https://github.com/SB-IM/jsonrpc-lite/releases)
[![license](https://img.shields.io/github/license/SB-IM/jsonrpc-lite.svg?maxAge=2592000)](https://github.com/SB-IM/jsonrpc-lite/blob/master/LICENSE)

Golang 的 jsonrpc 2.0 序列化和解析库

这大概是我第一次写开源的库，不足之处还请多多指出

灵感来自 [teambition/jsonrpc-lite](https://github.com/teambition/jsonrpc-lite) 项目。
其实就是这个库的 golang 版

Golang 和 jsonrpc 用起来，不管怎么写都不合理。所以只做了序列化和反序列化。
（不能假定使用了 http 传输，也不能假定使用 websocket 传输。假定这个接口一定由某个对象提供也不合理

* * *

## webrtc-book-cn [![webrtc-book-cn](https://img.shields.io/github/stars/a-wing/webrtc-book-cn.svg?style=social&label=Star)](https://github.com/a-wing/webrtc-book-cn/)

中文翻译 《 Real-Time Communication with WebRTC 》

阅读地址： [https://a-wing.github.io/webrtc-book-cn/](https://a-wing.github.io/webrtc-book-cn/)

{% twitter https://twitter.com/_a_wing/status/1246129464070647808 %}

这个三月，在你们都在玩动物深林的时候，我把全部的休息的时间都用来翻译这本书了

其实我很想翻译出版这本书，然后拿着这本书去找当时劝我放弃学英语的那个英语老师，把这本书直接打在她脸上。（我不光英语没落下，我还可以翻译书了

虽然目前的翻译我还是觉得不够好

选定良辰吉日公开这个项目（雾），就决定在 2020.04.04 发布了

为了能在这天发布，这周我基本上都是连续通宵（白天一天工作的代码，晚上一天翻译。

* * *

## endplayer [![endplayer](https://img.shields.io/github/stars/a-wing/endplayer.svg?style=social&label=Star)](https://github.com/a-wing/endplayer/)

![screenshot/endplayer](https://raw.githubusercontent.com/a-wing/endplayer/gh-pages/screenshot/endplayer.png)

这是刚开的新坑。。。一个基于 mpv 和 Electron 的本地弹幕播放器

我弃坑了。。。主要是没有很好的把浏览器和视频结合到一起的方案

* * *

## argus [![argus](https://img.shields.io/github/stars/JRT-FOREVER/argus.svg?style=social&label=Star)](https://github.com/JRT-FOREVER/argus/)

![argus_active](/assets/img/hey_siri_open_door/argus.webp)

这才是我第一个写的项目，由于当时不会用 git 之类的 vcs 。。。也不知道 github 。。。这是后来整理之后上传开源的。之后也重构过好多遍

A.R.G.U.S.

> auxiliary reliable guardian undertaking system
>
> 辅助的可靠的守护者任务系统

这个项目的名字还是我上学时师弟给取的：（当时想取个希腊神话之类的，让人不明觉厉的名字）

这个名字其实是硬凑出来的（

> Argus Panoptes（古希腊语：Ἄργος，来自于形容词ἀργός“闪亮的”），希腊神话中的百眼巨人。

用法在这：[diy/2019/03/15/hey_siri_open_door.html](/diy/2019/03/15/hey_siri_open_door.html)

* * *

## KISS2U / KISS2UI [![KISS2U](https://img.shields.io/github/stars/a-wing/KISS2U.svg?style=social&label=Star)](https://github.com/a-wing/KISS2U/)

这个是 archlinuxcn 社区的的 lilac 的 web 端接口，KISS2U 提供API, KISS2UI 提供界面

这个变成了一个系列了：

- [KISS2U](https://github.com/a-wing/KISS2U) 后端 API 部分（已弃用）
- [kiss2ugo](https://github.com/a-wing/kiss2ugo) 后端 API/v2 部分（新的)
- [KISS2UI](https://github.com/a-wing/KISS2UI) 前端 UI 部分

文档在这： [https://build.archlinuxcn.org/api/v2/docs/](https://build.archlinuxcn.org/api/v2/docs/)

更详细的信息在这里：[archlinux/2018/08/05/kiss2u](/archlinux/2018/08/05/kiss2u.html)
> 你这个 bug 该修了，这个 API 该更新了。。。`_(ˊཀˋ」∠)_`

* * *

## Menhera-chan [![Menhera-chan](https://img.shields.io/github/stars/a-wing/Menhera-chan.svg?style=social&label=Star)](https://github.com/a-wing/Menhera-chan/)

Menhera-chan 超可爱。。。我要把他装进 github

这个仓库被 `Menhera-chan` 的原作者看到时，我表示好方啊（

* * *

## RailsGun [![RailsGun](https://img.shields.io/github/stars/MoePlayer/RailsGun.svg?style=social&label=Star)](https://github.com/MoePlayer/RailsGun/)

这是一个 `Dplayer` 的弹幕后端

这个还在维护吧，应该还在维护吧。。。如果不是这次清点原来写过的项目。我都忘记我还写过弹幕后端

* * *

## Github-dashboard (已弃坑) [![Github-dashboard](https://img.shields.io/github/stars/a-wing/Github-dashboard.svg?style=social&label=Star)](https://github.com/a-wing/Github-dashboard/)

![github.png](https://raw.githubusercontent.com/a-wing/Github-dashboard/master/github.png)

原因是 github 的一次界面改版，我用油猴脚本又还原了回来。。。之后 github 的界面又改版。。这东西就没用了。。。

我也不知道这东西核心代码就一行，怎么就这么多 star

* * *

## linuxdeer (已弃坑) [![linuxdeer](https://img.shields.io/github/stars/a-wing/linuxdeer.svg?style=social&label=Star)](https://github.com/a-wing/linuxdeer/)

本来想写一份关于 Linux 桌面的教程。。。我真的不知道还应该写一些什么。。。

* * *

## cfcart (已弃坑) [![cfcart](https://img.shields.io/github/stars/a-wing/cfcart.svg?style=social&label=Star)](https://github.com/a-wing/cfcart/)

这个是我真正学会编程的第一个项目，我都快忘记了我最开始是学 PHP 的

说起来我原来也是给 opencart 写插件的。不过都没开源（

这个项目基于 mycncart 。。。这个是 opencart 的中文改版，其实就是基于 opencart

opencart 的核心类似 `CodeIgniter` 框架。（非常的像

这个是把购物车系统改造成了众筹系统

全称叫 crowdfunding cart 。。。emmmmm 中文叫 `众筹之车` 哈哈哈哈哈

