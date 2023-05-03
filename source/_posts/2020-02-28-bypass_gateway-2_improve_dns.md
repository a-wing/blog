---
layout: post
title:  "自制旁路网关（二） ——用unbound和smartdns来优化dns服务"
author: metal A-wing
date:   2020-03-01 22:00:00 +0800
comments: true
categories: network
---

今天是三月一日，我应该昨天更新，因为昨天是四年一度的二月二十九日。错过了了个好日子 T_T 。不过没关系，今天还是一年一次的三月一号那（


先来回顾一下 dns 查询会遇到那些问题

1. 运营商 dns 基本上是最快的，但可能有污染
2. 国内公共 dns ，国内地址准确，但未必最快，国外有污染
3. 出口节点运营商 dns ，国外地址准确，速度基本最快
4. 国外公共 dns ，国外地址准确，但未必快
5. 国外网站可能有国内地址的 cdn ，cdn 最快

我们先把国内外分开查询，然后再汇总

使用 smartdns 来查询国内，只用公共 dns ，（smartdns 可以测速并返回你的位置最快的地址）

国内外 dns 该如何进行分流？有一个很重要的问题是国外网站有国内 cdn

基于 geo-ip 来分流查询，查到固定国家或特色网段的地址时，不使用这个结果（大陆白名单就是这种）

基于域名 GFWlist 是把被墙掉的域名收集起来做成一个数据库

### 究极方案 ICPlist:

我还没见过有这么干的，不过这才是一劳永逸的办法，用于大陆法律的问题 ICP 你懂的，不过这个数据库可以反过来利用（只要在 icp 清单可以认为在大陆一定有服务器）

不过最大的问题是这个库过于庞大。。。绝大部分你都是永远都不会用的地址

国外的可以分成两种情况
1. 出口固定（比如你自建的服务）
2. 出口不确定（比如使用机场）

出口固定的情况很好解决，这里不做考虑（你自己在出口节点上建一个 dns 服务，然后加密传回来就行了）

出口不确定，你不知道运营商 dns 只能把查询请求给代理，保佑能给你返回个快的地址


# 目前我用的方案

使用 `unbound` 来做主 dns 服务（其实用什么都无所谓 coredns 也可以）

`smartdns` 来查询国内的 dns （我设成 5351 端口）

`clash` 来查询国外的 dns （我设成 5352 端口）

`dnsmasq-china-list` 的规则来分流国内外

### smartdns
```sh
wget https://github.com/pymumu/smartdns/releases/download/Release28/smartdns.1.2019.12.15-1028.arm-debian-all.deb
dpkg -i smartdns.1.2019.12.15-1028.arm-debian-all.deb

systemctl start smartdns.service
systemctl enable smartdns.service
```

这个没啥说的，按官方文档的说法，就多些几个上游 dns 地址 [从这里挑几个看着顺眼的写上就行](https://dns.iui.im/)

> smartdns有测速机制，在配置上游服务器时，建议配置多个上游DNS服务器，包含多个不同区域的服务器，但总数建议在10个左右


### unbound
这个直接从源里安装就行 `apt install unbound`

不过这个源里的 `unbound`， DD (Debian Developer) 定制了一点东西
```sh
sudo systemctl cat unbound
# /lib/systemd/system/unbound.service
[Unit]
Description=Unbound DNS server
Documentation=man:unbound(8)
After=network.target
Before=nss-lookup.target
Wants=nss-lookup.target

[Service]
Type=notify
Restart=on-failure
EnvironmentFile=-/etc/default/unbound
ExecStartPre=-/usr/lib/unbound/package-helper chroot_setup
ExecStartPre=-/usr/lib/unbound/package-helper root_trust_anchor_update
ExecStart=/usr/sbin/unbound -d $DAEMON_OPTS
ExecReload=/usr/sbin/unbound-control reload
PIDFile=/run/unbound.pid

[Install]
WantedBy=multi-user.target
```

这里有两个 hook 的脚本。Debian Developer 对这个定制了点东西，先把他禁用掉

> **凡是DD (Debian Developer) 打包时自己定制的功能一律禁用掉**

顺着那个 hook 去这个文件里 `/usr/lib/unbound/package-helper`

可以找到这样一段
```sh
# Override these variables by editing or creating /etc/default/unbound.
RESOLVCONF="true"
ROOT_TRUST_ANCHOR_UPDATE="true"
```

之后自己建个 `/etc/default/unbound` 把那个功能关掉
```sh
cat > /etc/default/unbound << EOF
# 这个默认会修改 /etc/resolv.conf 文件，设成 false 禁用掉
RESOLVCONF="false"

# 这个我也不知道具体是干什么的，反正是 DD (Debian Developer) 自己搞出来东西，直接禁用就行 ╮(￣▽￣)╭
ROOT_TRUST_ANCHOR_UPDATE="false"
EOF
```

然后去修改 `/etc/unbound/unbound.conf`
```sh
server:
    verbosity: 1
    num-threads: 2
    interface: 0.0.0.0@53
    do-ip4: yes
    do-udp: yes
    do-tcp: no
    do-not-query-localhost: no # 这句很关键，不把这个关掉上游 dns 不能用本地的 dns 服务
    access-control: 0.0.0.0/0 allow
    local-data: "test.com. A 192.168.1.1"
    include: "/etc/unbound/unbound.conf.d/accelerated-domains.china.unbound.conf"
    include: "/etc/unbound/unbound.conf.d/apple.china.unbound.conf"
    include: "/etc/unbound/unbound.conf.d/google.china.unbound.conf"
    forward-zone:
    	name: "."
    	forward-addr: 127.0.0.1@5352
```
之后把 `include` 的文件放进去

### dnsmasq-china-list
```sh
git clone https://github.com/felixonmars/dnsmasq-china-list.git --depth 1
cd dnsmasq-china-list
make SERVER=127.0.0.1@5351 unbound
cp *unbound.conf /etc/unbound/unbound.conf.d/
```

## 最后
`clash` 的配置去看我前几篇文章

最好别忘了 `systemctl restart unbound`

排查文件直接用 `dig`, `nslookup` 这个软件 debian 是在 `dnsutils` 这个包里


## 参考文章

[使用 Unbound 搭建更好用的 DNS 服务器](https://blog.phoenixlzx.com/2016/04/27/better-dns-with-unbound/)

