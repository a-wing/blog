---
title:  "细说 Debian 的网络管理 network/interfaces"
date:   2019-04-01 16:00:00 +0800
updated:   2019-04-01 16:00:00 +0800
categories: linux
tags:
- linux
- debian
- systemd
---

最近在修一个复杂的多网卡问题，产生的玄学问题，趁机把 interfaces 文档都读了一边

> 注：本文内容是在 `raspbian` 系统上验证的

Debian 自带的网络管理的名字叫 `ifupdown`

权威的文档是 `man interfaces`

这个文件可以分成两部分，`INTERFACE SELECTION` 和 `ADDRESS FAMILY`

`INTERFACE SELECTION` 是 这个物理设备（可能是虚拟的）怎么样怎么样，指： 自动启动，允许热拔插啊之类的...

`ADDRESS FAMILY` 是上层的网络，设置 ip 地址啊，子网掩码，网关之类的...

**Lines starting with `#' are ignored. Note that end-of-line comments are NOT supported, comments must be on a line of their own.**
> 注：network/interfaces 这个文件不支持行尾注释


```
# 自动使用 eth0, 相当于自动执行 ifup eth0
auto eth0

# 允许热拔插
allow-hotplug eth0

# ADDRESS FAMILY 配置
iface eth0 inet static
  address 192.168.1.2/24
  gateway 192.168.1.1
```

有四个 hook 函数，根据启动关闭的运行顺序是：
```
pre-up
post-up && up

pre-down && down
post-down
```
调用 hook 时会传递一些变量：
比如 echo $IFACE 之类的


这几个是全局的 hook 配置
```
/etc/network/
if-down.d  if-post-down.d  if-pre-up.d  if-up.d
```

dhcpcd (Dynamic Host Configuration Protocol Clinet Daemon)
- isc-dhcp-client (这个包是默认就有的，也是一个dhcp 的客户端，这个是命令行接口 `ifupdown` 是调用的这个)
- dhcpcd5 (这个只在树莓上才是默认的) 也是默认运行的(至于为什么要叫dhcpcd5，大概是从 v5 之后开始支持 ipv6 的，虽然现在的版本是 6.x)

**只有 raspbian 这个地方很不清真，他同时是有两个网络管理 之后人如果你直接使用 `network/interfaces` 里面改，你就会发现 dhcp 是关不掉的！！！**

> 这个地方仅限于默认的 raspbian 系统，默认的 debian 是没有的

关掉 dhcp 就是 `systemctl disable dhcpcd.service`

```shell
$ dpkg -L dhcpcd5
/.
/etc
/etc/dhcpcd.conf
/etc/init.d
/etc/init.d/dhcpcd
/lib
/lib/arm-linux-gnueabihf
/lib/arm-linux-gnueabihf/dhcpcd
/lib/arm-linux-gnueabihf/dhcpcd/dev
/lib/arm-linux-gnueabihf/dhcpcd/dev/udev.so
/lib/dhcpcd
/lib/dhcpcd/dhcpcd-hooks
/lib/dhcpcd/dhcpcd-hooks/01-test
/lib/dhcpcd/dhcpcd-hooks/02-dump
/lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant
/lib/dhcpcd/dhcpcd-hooks/20-resolv.conf
/lib/dhcpcd/dhcpcd-hooks/30-hostname
/lib/dhcpcd/dhcpcd-hooks/50-ntp.conf
/lib/dhcpcd/dhcpcd-run-hooks
/lib/systemd
/lib/systemd/system
/lib/systemd/system/dhcpcd.service
/sbin
/sbin/dhcpcd5
/usr
/usr/lib
/usr/lib/dhcpcd5
/usr/lib/dhcpcd5/dhcpcd
/usr/share
/usr/share/dhcpcd
/usr/share/dhcpcd/hooks
/usr/share/dhcpcd/hooks/10-wpa_supplicant
/usr/share/dhcpcd/hooks/15-timezone
/usr/share/dhcpcd/hooks/29-lookup-hostname
/usr/share/doc
/usr/share/doc/dhcpcd5
/usr/share/doc/dhcpcd5/changelog.Debian.gz
/usr/share/doc/dhcpcd5/copyright
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/dhcpcd5
/usr/share/man
/usr/share/man/man5
/usr/share/man/man5/dhcpcd.conf.5.gz
/usr/share/man/man8
/usr/share/man/man8/dhcpcd-run-hooks.8.gz
/usr/share/man/man8/dhcpcd5.8.gz
/var
/var/lib
/var/lib/dhcpcd5

```
### 我们熟知的`/etc/wpa_supplicant/wpa_supplicant.conf`是什么时候运行的？

`/lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant` 是这里，只要启动了 dhcpcd 服务就会运行

wpa_supplicant 的用法

```shell
cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOF
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
  ssid="<You SSID>"

  # hide ssid
  scan_ssid=1

  psk="<You Pass>"
}

EOF


# 启动
systemctl start wpa_supplicant.service

# 开机自启动
systemctl enable wpa_supplicant.service
```


`man wpa_supplicant.conf` 其实已经讲的很清楚了


# **现在你们已经看到了那一堆稀奇古怪的shell实现，简直不能再糟糕了**

> 对的，这是两套网络管理器，搅在一起了。然后同时使用。。。

以下内容为 2020.02.13 更新
======

我们来看个好点的实现：`systemd 大法好`。。。聊聊 `systemd-networkd`

本来想新开一篇文章，后来想想还是算了，还是在这片上接着写吧

以下内容在 `Raspbian 10 (buster)` 上验证

最简单的 dhcp eth0 文件放这里 `/etc/systemd/network/eth0.network` 这样写
```
[Match]
Name=eth0

[Network]
DHCP=ipv4
```

静态 IP 的话，这样写
```
[Match]
Name=eth0

[Network]
Address=192.168.123.10/24
Gateway=192.168.123.1
```

## systemd-networkd
```sh
# 禁用掉 `ifupdown`
mv /etc/network/interfaces /etc/network/interfaces.save

# 关闭 dhcpcd 客户端。这个好像只有树莓需要，原版 debian 我没测试
systemctl disable dhcpcd.service

# 启用 systemd-networkd
systemctl enable systemd-networkd
```

### **`wpa_supplicant` 的 debian systemd 这里有个坑**

先来看一下这个：`systemctl cat wpa_supplicant`
```sh
# /lib/systemd/system/wpa_supplicant.service
[Unit]
Description=WPA supplicant
Before=network.target
After=dbus.service
Wants=network.target

[Service]
Type=dbus
BusName=fi.w1.wpa_supplicant1
ExecStart=/sbin/wpa_supplicant -u -s -O /run/wpa_supplicant

[Install]
WantedBy=multi-user.target
Alias=dbus-fi.w1.wpa_supplicant1.service
```

再看一下这个：`systemctl cat wpa_supplicant@`
```sh
# /lib/systemd/system/wpa_supplicant@.service
[Unit]
Description=WPA supplicant daemon (interface-specific version)
Requires=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target

# NetworkManager users will probably want the dbus version instead.

[Service]
Type=simple
ExecStart=/sbin/wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant-%I.conf -Dnl80211,wext -i%I

[Install]
Alias=multi-user.target.wants/wpa_supplicant@%i.service
```

我们看到那两个文件是不一样的，不仅仅是一个加个模版变量

如果你使用 `systemd-networkd`，`wpa_supplicant` 服务请使用带模版变量那个（别问我为什么）

```sh
# 新建个无线连接的配置文件
cat > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf << EOF
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
  ssid="<You SSID>"
  psk="<You Pass>"
}

EOF

# 禁用掉 wpa_supplicant 服务
systemctl disable wpa_supplicant.service

# 用这个服务运行
systemctl enable wpa_supplicant@wlan0.service
```

这个地方 Debian 的官方文档讲的很清楚： [SystemdNetworkd](https://wiki.debian.org/SystemdNetworkd)

详细参数可以用`man systemd.network` 来看，也可以看这里：[man systemd.network](https://manpages.debian.org/buster/systemd/systemd.network.5.en.html)

