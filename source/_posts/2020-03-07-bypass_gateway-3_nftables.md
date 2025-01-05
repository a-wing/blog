---
layout: post
title:  "自制旁路网关（三） ——nftables 来做透明代理"
author: metal A-wing
date:   2020-03-07 12:00:00 +0800
comments: true
categories: network
---

本以为这篇文章会写的很长，因为笔记上还有好多内容。不过博客不能是笔记，把最核心的地方用最简单的话提炼出来，尽可能让所有人能看懂才算是一篇好文章

今天或许是个好日子，[三月七号女生节](https://zh.wikipedia.org/wiki/%E5%A5%B3%E7%94%9F%E8%8A%82)。我决定今天把这个系列的坑填上，就当作给所有女孩子的礼物了（大雾）

为什要使用 nftables 来分流而不用，clash 的分流。如果你了解零拷贝实现，你就会了解为什么这样做。不了解也没关系，记住结论 `nftables` 分流性能更高一些

不过那个`nftables` 性能高只是理论上的。实际上我并没有做过 `benchmarks` 。可能实际情况也刚好相反。（也欢迎那个较真的杠精来做下 `benchmarks` 来证明一下）

```sh
# 挂上socks 代理下的大概快一点
curl --socks5 localhost:7891 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' > raw


# 制作 nftables 的配置文件，先生成个第一行
echo "define chnroute_list = {" > chnroute.nft

# 提取国内的地址追加写入配置
cat raw | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' | sed s/$/,/g >> chnroute.nft

# 写个尾部
echo "}" >> chnroute.nft

# 放到该放的位置
cp chnroute.nft /etc/nftables/chnroute.nft
```

再来修改配置文件 `/etc/nftables.conf`

这个地方接上一篇 [自制旁路网关（一） ——使用clash做代理](/network/2020/02/22/bypass_gateway-1_clash.html) 的 nftables 部分

```sh
#!/usr/sbin/nft -f
flush ruleset

include "/etc/nftables/private.nft"
include "/etc/nftables/chnroute.nft"

table ip nat {
  chain proxy {
    ip daddr $private_list return
    ip daddr $chnroute_list return
    ip protocol tcp redirect to :7892
  }
  chain prerouting {
    type nat hook prerouting priority 0; policy accept;
    goto proxy
  }
}
```

`nft flush ruleset` 可以写在文件里，不用担心语法错误会把规则清空（这个我实际测试过）。nftables 的配置是 “事务型规则更新” （了解关系型数据库的人应该知道我在说什么）

> 细心的朋友可能会发现我在上一篇文章中用的是 `jump`

关于 `goto` 和 `jump` 指令是有区别的。我觉得这里用 `goto` 更好一些 [官方文档讲的很清楚应该不用我再翻译一遍 jump vs goto](https://wiki.nftables.org/wiki-nftables/index.php/Jumping_to_chain)

然后重新载入配置文件 `nft -f /etc/nftables.conf`

#### 做完这些如果你发现国内网站全上不去了
```sh
# 看看这些个显示的是 0 还是 1
# 默认是 0 不启用 ip_forward
cat /proc/sys/net/ipv4/ip_forward

# 手动打开
sysctl -w net.ipv4.ip_forward=1

# 你也可以这样来打开
echo 1 > /proc/sys/net/ipv4/ip_forward
```

不过长期的稳定的办法是修改 `/etc/sysctl.conf` 的 `net.ipv4.ip_forward=1`

然后 `sysctl -p` 载入

### 后记
如果国外走 udp 。也是同理，只是要用 tproxy，或者 tun 设备（虚线一个网卡）

真是没想到，我竟然更完了这个系列


### 本系列文章：
1. 这应该算是第零篇，建议先看这篇 [细说 Debian 的网络管理 network/interfaces](/linux/2019/04/01/debian_network.html)
2. [自制旁路网关（一） ——使用clash做代理](/network/2020/02/22/bypass_gateway-1_clash.html)
3. [自制旁路网关（一点一） ——增加clash订阅功能](/network/2020/02/28/bypass_gateway-1-1_subscription.html)
4. [自制旁路网关（二） ——用unbound和smartdns来优化dns服务](/network/2020/03/01/bypass_gateway-2_improve_dns.html)
5. 自制旁路网关（三） ——nftables 来做透明代理 (本篇)


## 参考文章

[在 ArchLinux 上配置 shadowsocks + iptables + ipset 实现自动分流](https://typeblog.net/10650/archlinux-shadowsocks-iptables-ipset)

[ Linux on m8 第一篇、网络配置](https://64mb.org/2018/12/24/linux-on-m8-01/)

[nftables 上手小记](https://omicron3069.com/post/nftablesfornode/)

