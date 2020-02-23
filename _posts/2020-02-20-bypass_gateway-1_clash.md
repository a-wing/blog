---
layout: post
title:  "自制旁路网关 ——使用clash做代理"
author: metal A-wing
date:   2020-02-22 22:00:00 +0800
comments: true
categories: network
---

由于武汉新冠肺炎（[COVID-19](https://zh.wikipedia.org/wiki/2019%E5%86%A0%E7%8A%B6%E7%97%85%E6%AF%92%E7%97%85)）的关系，我被困在老家，自从我买了 ac68u 之后基本上就再也没折腾过网。由于长期在家办公，需要好的网络，还好手里有树莓派，还有 nas。只能使用传统技能（时代变化还真实快，一觉醒来工具链全变了）

这次优化网路的经历我准备写一个系列（预计三篇文章：代理，dns，分流增强）。我也不知道能不能写完，也说不定后面两篇文章会咕掉

代理软件使用 clash ，这个软件的特色就是他的分流功能和自动选择节点

**不可否认，我省略了一些过于基础的细节，但本文的确是从我的笔记上摘录的**

```sh
# 我是树莓 pi3b 请根据cpu架构选择合适的二进制包
wget https://github.com/Dreamacro/clash/releases/download/v0.17.1/clash-linux-armv7-v0.17.1.gz
gzip -d clash-linux-armv7-v0.17.1.gz
install -Dm755 clash-linux-armv7-v0.17.1 /usr/local/bin/clash

# 把 clash 配置目录放在 /etc 目录下
mkdir /etc/clash/
```

创建一个本地的 systemd 配置`/etc/systemd/system/clash.service`

```sh
[Unit]
Description=clash service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/clash -d /etc/clash/
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```sh
systemctl start clash.service
systemctl enable clash.service

# 然后测试下 socks 代理是否可用
curl --socks5 localhost:7891 google.com
```
clash 里面其实内置了 dns 服务器的，这个默认是关闭的（clash 配置文件的官方文档写的够细了，只是藏的比较隐蔽）

```yaml
dns:
  enable: true # set true to enable dns (default is false)
  ipv6: false # default is false
  listen: 0.0.0.0:53
  # default-nameserver: # resolve dns nameserver host, should fill pure IP
  #   - 114.114.114.114
  #   - 8.8.8.8
  enhanced-mode: redir-host # or fake-ip
  # fake-ip-range: 198.18.0.1/16 # if you don't know what it is, don't change it
  fake-ip-filter:
    - '*.lan'
    - localhost.ptlogin2.qq.com
```
关于 fake-ip 功能，请移步去 [苏卡卡的 使用 KoolClash 作为代理网关](https://blog.skk.moe/post/alternate-surge-koolclash-as-gateway/)

然后我们再给 clash 加个 UI，这个 webUI 没有提供预编译版本，要自行编译

其实我觉得这个 UI 没啥用
```sh
wget https://github.com/Dreamacro/clash-dashboard/archive/v0.3.0.tar.gz
tar -xzf v0.3.0.tar.gz
cd clash-dashboard-0.3.0/
npm install
npm run build

# 把编译结果上传到你的 clash 服务端。。。。因为我是在自己电脑上编译的
tar -cJf - dist/ | ssh <username>@<hostname> 'tar -xJf -'
cp -r dist /etc/clash/dashboard
```

然后来修改 clash 配置，webUI 相关的有这几项
```yaml
# RESTful API for clash
external-controller: 127.0.0.1:9090

# 这个地方写编译成静态资源的路径，可以是相对路径或绝对路径 然后用扩展配置的地址 (`external-controller`) + /ui 访问
# 例如：http://127.0.0.1:9090/ui
external-ui: dashboard

# Secret for RESTful API (Optional)
# secret: ""
```

### 我个人是不推荐旁路网关自身流量也走透明代理

使用 iptable 来转发流量
```sh
iptables -t nat -N CLASH

# 私有 ip 流量不转发，完整的在下面
# 设置的 fake-ip 请注意检查这里
iptables -t nat -A CLASH -d 192.168.0.0/16 -j RETURN

iptables -t nat -A CLASH -p tcp -j REDIRECT --to-ports 7892
iptables -t nat -A PREROUTING -p tcp -j CLASH
```

```sh
# 内部流量不转发给 CLASH 直通
iptables -t nat -A CLASH -d 0.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t nat -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t nat -A CLASH -d 240.0.0.0/4 -j RETURN
```

我觉得只写 iptables 版，我会被人耻笑（这和网上随手一搜的垃圾教程有什么两样。对，其实我写的也是垃圾）

来个 `nftables` 版的 （Raspbian buster 要先安装个 nft 的前端 `apt install nftables`）

先创建一个私有地址的定义文件 `/etc/nftables/private.nft`
```sh
define private_list = {
	0.0.0.0/8,
	10.0.0.0/8,
	127.0.0.0/8,
	169.254.0.0/16,
	172.16.0.0/12,
	192.168.0.0/16,
	224.0.0.0/4,
	240.0.0.0/4
}
```

再来修改主配置文件 `/etc/nftables.conf`
```sh
include "/etc/nftables/private.nft"

table ip nat {
	set whitelistset {
		type ipv4_addr
			flags interval
			elements = $private_list
	}
	chain proxy {
		ip daddr @whitelistset return
			ip protocol tcp redirect to :7892
	}
	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
		jump proxy
	}
}
```
然后执行清空设置 `nft flush ruleset`，让新的设置生效 `nft -f /etc/nftables.conf`

或者直接这样 `sudo sh -c "nft flush ruleset && nft -f /etc/nftables.conf"`

然后通过这条命令来看当前 nftables 的状态 `sudo nft list ruleset`

最后再设置一下开机启动
```sh
systemctl enable nftables.service
```

## 参考文章
[使用 KoolClash 作为代理网关](https://blog.skk.moe/post/alternate-surge-koolclash-as-gateway/)

[在 Ubuntu18.04 上使用 clash 部署旁路代理网关（透明代理）](https://breakertt.moe/2019/08/20/clash_gateway/index.html)

[V2Ray 做透明代理](https://toutyrater.github.io/app/transparent_proxy.html)

[debian10 使用 nftables 替换 iptables](https://ghost.qinan.co/debian10_iptables_to_nftables/)

[谈谈使用nftables配置透明代理碰到的那些坑](https://www.dazhuanlan.com/2019/09/26/5d8ca8b9730d5/)

