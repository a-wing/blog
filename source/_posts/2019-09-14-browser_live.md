---
layout: post
title:  "浅谈浏览器实时流媒体"
author: metal A-wing
date:   2019-09-14 20:00:00 +0800
comments: true
categories: web
---

我觉得应改把浏览器实时流媒体分成三层（传输，容器，编解码），这样更容易理解，不过他们并不能任意组合

## 分层结构
#### 数据传输层（底层传输层，浏览器原生支持）
- http
- websocket
- webrtc
- rtmp (这个浏览器本身不支持，要靠外置插件)

#### 实时流传输层（中间传输层）
- rtp
- rtsp

#### 容器层
- 浏览器原生支持
- Media Source Extensions
  - flv
  - ts

#### 编/解 码
- vp8
- vp9
- h264
- h265

#### 编解码 信息交换
- sdp
- m3u8
- mpd
- webrtc sdp


我这里分了四层（`编解码 信息交换` 和 `编/解 码` 不会同时运行，先信息交换再编解码）。。因为浏览器容器层是由原生支持的，只有播放原本浏览器不支持的容器是才需要 MSE

`实时流传输层（中间传输层）` 这个其实是可有可无的，大部分情况都是没有的

由于浏览器实现的编解码都不同，一般都要交换一下支持的`编解码`的信息 一般都用 sdp


## 实时流方案
### HLS
> HTTP Live Streaming（缩写是HLS）是一个由苹果公司提出的基于HTTP的流媒体网络传输协议。是苹果公司QuickTime X和iPhone软件系统的一部分。它的工作原理是把整个流分成一个个小的基于HTTP的文件来下载，每次只下载一些。当媒体流正在播放时，客户端可以选择从许多不同的备用源中以不同的速率下载同样的资源，允许流媒体会话适应不同的数据速率。在开始一个流媒体会话时，客户端会下载一个包含元数据的extended M3U (m3u8) playlist文件，用于寻找可用的媒体流。


将视频分成5-10秒的视频小分片，然后用m3u8索引表进行管理，由于客户端下载到的视频都是5-10秒的完整数据，故视频的流畅性很好，但也同样引入了很大的延迟(HLS的一般延迟在10-30s左右)。实际上还是纯“文本协议”相比于FLV，HLS在iPhone和大部分android手机浏览器上的支持非常给力。HLS协议客户端支持简单, 只需要支持 HTTP 请求即可, HTTP 协议无状态, 只需要按顺序下载媒体片段即可，而且网络兼容性好, HTTP 数据包也可以方便地通过防火墙或者代理服务器。但是相比RTMP 这类长连接协议, 用到互动直播场景延时较高。 对于点播服务来说, 由于 TS 切片通常较小, 海量碎片在文件分发, 一致性缓存, 存储等方面都有较大挑战，小文件碎片化严重

这东西是苹果设备上独有的。但浏览器的兼容可以用 hls.js

### MPEG-DASH
> MEPG 推出 MEPG-DASH 标准，旨在为动态自适应流媒体技术创造一种同一的协议标准。DASH 也得到了许多公司的支持，Apple、Adobe、Microsoft、Netflix、Qualcomm 表示只要 DASH 完成，就会支持这个标准。

这个和 HLS 类似。只是把 m3u8 换成了 mpd，加了动态自适应


### Flash
这东西用的是 rtmp 。浏览器本身不支持。要靠外置插件来实现（chrome 有一段很长的时间内置了 flash 插件）

### HTTP-FLV && WebSocket-FLV
只是把 flv 容器用 http 或 webSocket 形式传输过来。但要播放 flv 容器的数据还是要用 flash ，或者用基于 MSE 的方案。典型就是使用 `flv.js`


### rtsp
rtsp 底层是 rtp 或 tcp 。rtp 底层是 udp

是可以把 rtsp 以 websocket 的形式传输过来。再使用 MSE 扩展

https://github.com/Streamedian/html5_rtsp_player

**注：这个方案我没试过，rtsp 实现也很复杂**

### webrtc
webrtc 里有一堆黑科技。原理很复杂，展开来说实在东西太多，其实只记在几件事就可以了

1. webrtc 是 p2p 传的是 udp
2. stun 和 turn 只是为了实现 p2p 连接，直连模式和中继模式
3. webrtc 是使用 rtp 来传流媒体的，也有 rtcp 的数据，这点和 rtsp 类似。可以当成一种特殊的 rtsp 实现

一般用于视频会议，占资源很高，可以一对多，但不适合一对很多用户来直播


## 一个简单对比

方案 | 传输方式 | 视频封装格式 | 延时 | 浏览器支持 |  应用场景
---- | -------- | ------------ | ---- | -------- | -------
HLS  | http     | ts           |10~30s| apple 原生支持，其他的要用 MSE 扩展 | 直播
DASH | http     | mp4 ts       |10~30s| 未来的标准，MSE dash.js | 直播
Flash| tcp流    | flv          |2s~5s | Flash插件 | 直播
http-flv | HTTP |  flv         |2s~5s | 通过 flv.js | 直播
websocket-flv |websocket|  flv |1s~3s | 通过 flv.js | 直播
rtsp | websocket | mp4 flv     |500ms | 不支持，通过 MSE| 低延时直播，视频会议
webrtc| rtp     | mp4          |200ms | 支持，未来浏览器标准| 视频会议



### 参考文章
直播协议对比：
https://www.jianshu.com/p/cf02eb8080ec

HLS，RTSP，RTMP的区别：
https://www.jianshu.com/p/70c9a2fd918b

HLS与DASH流媒体协议对比：
https://wiki.zohead.com/%E6%8A%80%E6%9C%AF/%E9%9F%B3%E8%A7%86%E9%A2%91/HLS%E4%B8%8EDASH%E6%B5%81%E5%AA%92%E4%BD%93%E5%8D%8F%E8%AE%AE%E5%AF%B9%E6%AF%94.md

使用flv.js做直播：
https://wuhaolin.cn/2017/05/17/%E4%BD%BF%E7%94%A8flv.js%E5%81%9A%E7%9B%B4%E6%92%AD/



