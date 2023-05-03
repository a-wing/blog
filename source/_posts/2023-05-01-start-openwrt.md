---
layout: post
title: "从零开始的 OpenWrt"
author: "Metal A-wing"
date: 2023-05-01 20:00:00 +0800
toc: true
image: "/assets/img/start-openwrt/img_2952.jpg"
banner: "/assets/img/start-openwrt/img_2952.jpg"
categories: linux
---

最近接了一个定制路由器的项目，应该算是彻底把 OpenWrt 给玩明白了

## 一个简单的基础入门

OpenWrt 项目是一个针对嵌入式设备的 Linux 操作系统。OpenWrt 不是一个单一且不可更改的固件，而是提供了具有软件包管理功能的完全可写的文件系统。

### OpenWrt 和其他的 Linux 有什么不同？

1. 目前 OpenWrt 的 mainline libc 目前是 musl，一些旧版本里面是 ulibc。还有几个版本里面是 glibc
2. init 进程是 procd
3. 默认 sh 是 ash
4. 很多常用工具都是精简过的版本
5. OpenWrt 的配置是通过 uci 完成的，关于 uci 不再本文的讨论范围之内

### 路由器和串口

串口接三根线 `TX`, `RX`, `GND`

需要一个硬件来连接电脑：USB-to-TTL

这东西很便宜，常用的型号： `FT232`, `CH340`, `PL2303`, `CP2102` 反正功能都一样随便选

厂家可能会标准串口的位置，也可能不会标。不标的情况只能盲找，俗称「摸串口」，实际上也很简单，把可能的情况都试一遍就能找到

![https://openwrt.org/_media/media/dlink/dir-615/d-link.dir-615c2.serial.header.pinout.jpg](https://openwrt.org/_media/media/dlink/dir-615/d-link.dir-615c2.serial.header.pinout.jpg)

然后需要一个读串口的软件。为了颜值，然后我直接氪了一个付费软件

![screenshot_serial_debug](/assets/img/start-openwrt/screenshot_serial_debug.png)

不过我还是觉得命令行版的 `minicom` 更好用一点。主要是串口 shell 支持更好用。不过值得注意的是 MacOS 下的 Meta 键默认是 `Esc`

![screenshot_minicom](/assets/img/start-openwrt/screenshot_minicom.png)

### 文件系统原理

这张图来自 OpenWrt 的官网，是 TP-Link TL-WR1043ND 型号的分区图，这是一个例子，但都差不多

![screenshot_flash_layer](/assets/img/start-openwrt/screenshot_flash_layer.png)

[The OpenWrt Flash Layout](https://openwrt.org/docs/techref/flash.layout)

上面那张图很重要，不过我们要真正的理解它。官方文档讲的比较抽象，我来重新描述一下

首先 `u-boot` 和 `art` 分区最简单，这两个分区是基本上不需要有改动的，`u-boot` 就是 bootloader。刷固件也要靠它。`art` 是无线的数据，和射频有关的数据。这个不要动，也不能动。改了你的无线可能会出现不稳定的情况

---

接下来就是终点：所谓刷固件，刷的就是 `firmware` 。为什么 `firmware` 要分层？

回答这个问题之前，不如先思考另一个问题：路由器是如何实现 reset 功能的？OpenWRT 的这个设计非常的巧妙

`SqashFS` 是一个经过压缩只读文件系统。可以提高非常高的压缩比，如果要改变里面的文件，需要重写整个分区

`JFFS2` 是一个可以运行在 Flash 上的文件系统，非常适合于断电系统。也可以换成 `UBIFS`。适合用于 Nand Flash

`OverlayFS` 这个相比大家都比较熟悉了，容器化高度依赖这个文件系统。不过我还是要从头说：

```bash
mount -t overlay overlay -o lowerdir=/lower,upperdir=/upper,workdir=/work /merged
```

`OverlayFS` 分成 lower 层和 upper 层。从 lower 层读数据，然后所有的改动都写到 upper 层里。删除就是在 upper 层的建了个特殊的同名文件

**然后把 `SqashFS` 作为 lower 层，`JFFS2` 作为 upper 层。所谓的 Rest 功能就是把 `JFFS2` 格式化**

### OpenWrt 的三种固件

- `factory` 这个是针对一些特定厂家的 OEM，就是 `sysupgrade` 加点东西，情况比较复杂，不做讨论。这个和具体型号有关
- `sysupgrade` 这就是 OpenWRT 本体，就是 `firmware`
- `initramfs` 和 `sysupgrade` 一样，但所有东西都是写在内存了，`ramfs` 不支持持久化，可以跑在没有 Flash 的机器上，也可以用于 debug

所谓刷固件就是把固件 `dd` 到 `firmware` 分区上。不过 Flash 的特殊性，要用 `mtd` 命令

### 如何刷机

首先需要了解路由器的启动过程：上电启动，先启动 bootloader，然后 bootloader 去启动 Linux 内核。然后就和普通的 Linux 的启动过程一样了。重点是要经过一个 bootloader

bootloader 是 `u-boot` 也可以是其他的。`u-boot` 不止可以启动 Linux 还可以刷机。

`u-boot` 可以驱动网卡通过 TFTP 协议去下载固件来刷机

所谓的「不死 boot」，因为用 `u-boot` 和 TFTP 要用串口。不死 boot 就是增加了一个 Web 刷机页面仅此而已。这样就可以不用串口了

`u-boot` 分区一般不会动，因为刷死就变成「砖」了，只能把 Flash 拆下来，放到编程器上，Flash 有两种

nor-Flash 还好引脚比较少，八个引脚飞五根线出来就可以重新烧个 `u-boot`。nand-Flash 引脚很多，只能上热风枪把 Flash 吹下来，烧完了再吹上去

## 移植固件在做什么？

事实上就是要调出一组参数，然后移植一些驱动（通常是无线驱动）

### Kernel

就是编译 Linux 内核需要的参数，控制哪个功能编译到内核里面，那个功能编译成可加载到模块

但是在 OpenWRT 的编译系统里面，会对 Linux 内核打大量的 Patch。内核的参数是一个基本上不需要调的参数

在原本的 Linux 内核里用 `make menuconfig` 这个命令来配置。但是在 OpenWRT 里内核的参数的配置命令被改成了 `make kernel_menuconfig`

不过，更推荐的一种做法是：修改这个文件

```bash
target/linux/<Target System>/<Subtarget>/config-<Kernel Version>
```

### Package

而且 `make menuconfig` 对应的是软件包的参数，来控制哪个软件包需要内置到固件里，哪个软件包需要做成需要安装到包（用 opkg 命令来安装）

```bash
make menuconfig
```

![screenshot_openwrt_makeconfig](/assets/img/start-openwrt/screenshot_openwrt_makeconfig.png)

### **Device Tree**

操作系统要知道硬件的基本信息，但是在我们常用的 x86 的计算机里，硬件信息存储在 BIOS 里面的，然后通过 ACPI（Advanced Configuration and Power Interface）传递给 Linux 内核。内部的设备比如硬盘，pcie 设备都是有固件的。所有可以通过总线协议去拿到设备的基本信息。

在嵌入式 Linux 的硬件里为了节约成本，很多功能硬件只有一个芯片，根本没有地方放基本信息。所以这些信息只能硬编码到内核里面

为了解决这样的问题，Linux 使用了一种叫 DTS（Device Tree Specification）设备树描述的东西来解决这个问题。

当然，DTS 是一个纯文本。需要转换成二进制（或者说叫编译成二进制）的 DTB （Device Tree Blob）交给 Linux 内核

## 逆向固件

如果这个硬件已经支持了 Linux ，这样的话就会有一个捷径，我们可以在不需要知道硬件具体信息的情况下拿到 DTB 给新的内核用。为了做到这一点，我们可以逆向固件来取得 DTB

### binwalk

对于一个固件，可以用 [binwalk](https://github.com/ReFirmLabs/binwalk) 这个工具可以把 linux 内核和 rootfs 提取出来

```bash
binwalk -Me openwrt.bin
```

可以用这个工具看到类似这样的信息

```bash
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0xD6325671, created: 2021-10-20 00:30:33, image size: 3202195 bytes, Data Address: 0x81001000, Entry Point: 0x81001000, data CRC: 0x8A066943, OS: Linux, CPU: MIPS, image type: OS Kernel Image, compression type: lzma, image name: "MIPS OpenWrt Linux-3.10.108"
64            0x40            LZMA compressed data, properties: 0x6D, dictionary size: 8388608 bytes, uncompressed size: 8431488 bytes
3202259       0x30DCD3        Squashfs filesystem, little endian, version 4.0, compression:xz, size: 5333278 bytes, 1410 inodes, blocksize: 262144 bytes, created: 2021-10-20 00:30:29
```

### dtb magic

Linux 内核镜像里面有一段是记录的 dtb 信息的，通过 dtb magic（dtb 魔数）和其他数据分开。所以只要找到 dtb magic，就可以把 dtb 取出来了。这个工具可以找到两个版本的

- [extract_dtb.py](https://github.com/PabloCastellano/extract-dtb/blob/master/extract_dtb/extract_dtb.py#L25)
- [split-appended-dtb](https://github.com/MoetaYuko/split-appended-dtb/blob/master/split-appended-dtb.c#L23-L26)

然后再用 `dtc` 命令进行格式转换，转换成 DTS

```bash
dtc -I dtb -O dts -o out.dts openwrt.dtb
```

最后把 DTS 放到 `target/linux/<Target>/dts/<Target Profile>.dts` 里面就可以了

当然，以上只是理想情况，还有找不到 dtb 的情况，比如路由器厂商直接硬编码参数

## Flash

这个相当于硬盘，或者说叫 ROM。分为有控制器的和无控制器的。路由器上主要用无控制器的 nor-flash 或 nand-flash。注意：nor-flash 和 nand-flash 是存储介质的不同

但由于路由器要用更精简的结构，可没有额外的空间去放类似 x86 BIOS 一类的东西。所以 bootloader（U-Boot） 也是放在 Flash 里的，也就是说如果把 Flash 全清除了就彻底启动不了了

但还是有恢复的办法，一种是用 JTAG 接口直接读写读写 Flash 。把 U-Boot 烧进去。但只仅限于预留 JTAG 接口的情况。没有就只能把芯片拆下来

### MTD 和 FTL

硬盘就属于有控制器的，SD 卡也是有控制器的。说控制器可能有点抽象，但由于闪存特性，需要平衡的写入算法，还有坏块管理一类的功能。这个主控芯片做的事情有个更专业的名称来描述。叫FTL（Flash Translation Layer）

所以 Flash 分成两种情况一种是 rawFlash，另一种是带 FTL 的 Flash

Linux 内核实现有个功能的模块叫：MTD（Memory Technology Devices），可以直接控制 Flash 芯片的读写，但这远远不够，还需要一层逻辑地址的映射，来实现坏块管理一类的功能。MTD 里面还有个内核实现的 FTL。对于闪存，FTL 是必须的，如果 Flash 里面没有。当然这个功能可以由 Linux 内核来实现。

### Nor-Flash 与 CFI 和 SPI

Nor-flash 有实际上有两种接口：CFI（Common Flash Interface） 和 SPI （Serial Peripheral Interface）。虽然 CFI 和 SPI 接口最初是为了与 Nor-Flash 存储器兼容而设计的，但是它们并不仅仅适用于 Nor Flash 存储器，还可以用于其他类型的存储器。

我拿到这个路由器是 SPI-Flash。有 8 个引脚，有四根数据线，四根数据线有三种模式（只是传输速度的区别）：

- Standard SPI （接一根线）
- Dual SPI （接两根线）
- Quad SPI （接四根线）

### Nand-Flash 和 eMMC

Nand-Flash 和 Nor-Flash 都是由日本的富士雄发明的。Nand-Flash 的优点是容量大寿命长

eMMC（embedded Multi-MediaCard）是从 MMC（Multi-MediaCard）的基础上发展起来的然后变成了标准。但如果从内核视角，可以把 eMMC 看成协议

当然可以把无控制器的存储芯片（Raw Nand-Flash）加个控制器，比如  eMMC 就是 Nand-Flash 加个主控芯片

## 移植无线驱动

因为这个驱动已经支持了 Linux 所以只需要把文件放到内核对应的目录下就可以了

比如，我是 mediatek 的 xxx 硬件的驱动。把这个驱动放到这里面

```bash
drivers/net/wireless/mediatek/xxx
```

但实际上我移植完还没测试，就发现我的无线硬件已经有开源的驱动了。~~都给用开源驱动，闭源驱动狗都不用~~

但还不够，还需要修改两个文件：

### Kconfig

`Kconfig` 用于在 `make menuconfig` 时配置编译参数。

要修改这个文件 `drivers/net/wireless/mediatek/Kconfig`

```bash
source "drivers/net/wireless/mediatek/xxx/Kconfig"
```

### Makefile

还需要在 make 时找到代码对应的路径 `drivers/net/wireless/mediatek/Makefile`

```bash
obj-$(CONFIG_MT76_xxx) += xxx/
```

## 不同的 SSID 后缀

作为一个企业级方案，我们需要每个 SSID 的后缀都是不同的。我们要自动生成一个随机的后缀。当然更常见的方法是使用网卡的 mac 地址的后几位来标记后缀

在这个目录里建一个文件 `/etc/uci-defaults/42-ssid`

```bash
uci -q batch << EOI
set wireless.@wifi-device[0].disabled='0'
set wireless.@wifi-iface[0].ssid=OpenWrt_$(cat /dev/urandom | tr -dc A-Z | head -c 4)
set wireless.@wifi-iface[0].mode='ap'
set wireless.@wifi-iface[0].network='lan'
commit wireless
EOI
```

## 蜂窝网络（Cellular Network）

或者叫 LTE 网络或者说 4G 可能更熟悉一点。不过现在都已经是 5G 时代了

### 移远 EC20

这个模块可能很多人看到这个名字都觉得很亲切。这个模块用的实在是太多了

我手上的是一个 mini pcie 接口的模块。但实际上是 pcie 接口下面有个 USB-HUB 。然后连接了几个 USB 的网卡和串口设备。所以：同时需要 pcie, usb, serial 的驱动

串口发送 AT 指令来控制连接状态，或者切换供应商。然后通过 USB 网卡联网

可以使用这样的命令来查看状态

```bash
cat /sys/kernel/debug/usb/devices
```

### 协议

实际上 USB 的网卡有这几种协议 `qmi`, `mbim`, `ncm`, `rndis`

但这似乎是和你用的模块有关，但是我并没都测试过，也说不清楚具体区别。这方面资料也比较少，感觉好像是哪个能跑通，哪个效果好就用哪个。。。

- `luci-proto-3g`
- `luci-proto-qmi`
- `luci-proto-ncm`
- `luci-proto-modemmanager`

## 多 Wan 口切换

我们现在有两个 Wan 口了。但实际工作是两个 Wan 口（有线的和 modem）会互相覆盖掉默认路由

我们有个需求，要在有有线的时候网络流量都要走 Wan 口，在 Wan 口没有插网线的时候要走蜂窝网络通信

需要实现这样一个切换功能，切换有三种实现思路：

### 写个脚本挂在 cron

这是最容易想到的方式，也是最烂的实现方式，写个脚本定时检测网络状态，然后切换默认网关。不过很显然，这是网络路由没学好（

### 使用负载均衡工具接管出口流量

比如 mwan3 来做负载均衡。控制流量出口，这原本是用在多 wan 口来提升网络带宽的方案，可以用它探测网络是否掉线，来控制流量出口

### metric 来控制

多条默认路由。使用 metric 来控制。metric 可看成是路由的费用

比如像这样

```bash
default via 192.168.1.1 dev wan proto dhcp src 192.168.1.2 metric 10
default via 10.10.10.1 dev modem proto dhcp src 10.10.10.2 metric 40
```

让 wan 接口的 metric 小一点，拔掉 wan 口网线，wan 口默认路由会被删除

## 编译的坑

你可能会在文档上见到这样的命令

```bash
make FILES="files" PACKAGES="nano shadow sudo"
```

### `FILES`

可以指定一个自定义的文件夹，来覆盖掉默认位置的文件。比如多网卡切换和默认 SSID 随机的后缀都要用这个功能来实现

### `PACKAGES`

预置软件包，对于要支持蜂窝网络的情况当然要预置一些软件包，或者说对于一款定制的路由器来说，不需要有软件源，所有的用到的包都要预置到固件里

当然还有一个更好的办法比如更改 `DEVICE_PACKAGES`

比如这个例子： `target/linux/ramips/image/mt7621.mk`

```bash
define Device/mediatek_mt7621-xxx
  $(Device/dsa-migration)
  $(Device/uimage-lzma-loader)
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := Mediatek
  DEVICE_MODEL := MT7621 AT XXX
  DEVICE_PACKAGES := kmod-mt7603 kmod-mt7615e usb-modeswitch kmod-usb3 \
                                         kmod-usb-core kmod-usb-net kmod-usb-net-cdc-ether \
                                         kmod-usb-net-rndis kmod-usb-net-qmi-wwan kmod-usb-ohci-pci \
                                         kmod-usb-uhci kmod-usb2-pci \
                                         kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan \
                                         luci luci-proto-3g luci-app-multiwan
endef
TARGET_DEVICES += mediatek_mt7621-xxx
```

在这里更改 `DEVICE_PACKAGES` 只有在第一次生成 `.config` 时才生效。注意：是第一次生成，这里特指之前没有 `.config` 的情况。如果有会生成给 `DEFAULT_` 的选项，实际上这个包也会在固件里。~~我觉得这个设计很有问题。~~

## 总结

这个项目前前后后忙了一个多月，有一半时间都在错误的方向上努力。实际上我并没有通过逆向拿到 dtb，自己编译的固件逆向能拿到 dtb，厂家给的拿不到。所有这个项目的 dtb 参数是自己写的。另一个花费时间很多的地方是 mtd。总是无法写

### 绝望的开局——厂家的 SDK 有多坑

我拿到了三个 G 的 SDK。。。打开 tar 包发现，所有的编译中间产物都在那里。但你不能执行 make clean 。。因为 clean 之后就没法编译了。。。

原因是厂家把驱动放在中间产物里了。。。

很多包的地址过于古老已经没法下载了

基于 openwrt 15 的 sdk。要知道 openwrt 17 有非常大的改动

没有版本管理，不知道是哪个版本。

只能找一相近的版本进行 diff 。但都是有上百的文件个改动。唯一能找到的就是无线驱动的路径

### 最后

我又学会一项新技能

OpenWrt 这个系统特别强，然后再配合 uci。不仅仅是路由器，用来做其他的产品也是个不错的选择

## Reference

[Hello-Embedded-Linux/系统初始化](https://github.com/HeyGoda/Hello-Embedded-Linux/blob/27c2ee700f73b0f63b56a7346694a36bcdef343d/系统初始化.md#openwrt-procd)

[Openwrt 文件系统](https://fjkfwz.github.io/2014/12/04/Openwrt-File-System/)

[Transfer: Simple and reliable TFTP server for macOS - Intuitibits](https://www.intuitibits.com/2019/06/01/transfer-tftp-server/)

[GitHub - devicetree-org/devicetree-specification: Devicetree Specification document source files](https://github.com/devicetree-org/devicetree-specification)

[Device Tree Reference - eLinux.org](https://elinux.org/Device_Tree_Reference)

[从固件里反编译dtb为dts-OPENWRT专版-恩山无线论坛 -  Powered by Discuz!](https://www.right.com.cn/forum/thread-539091-1-1.html)

[杂谈闪存三：FTL](https://zhuanlan.zhihu.com/p/26944064)

[linux ftl原理,Linuxflash文件系统剖析_GOLFING路上的博客-CSDN博客](https://blog.csdn.net/weixin_35473679/article/details/116924669)

[Memory Technology Device (MTD) Subsystem for Linux.](http://www.linux-mtd.infradead.org/doc/ubifs.html#L_raw_vs_ftl)

[搞清楚nand flash和 nor flash 以及 spi flash 和cfi flash 的区别_qspi flash，nor nand_书中倦客的博客-CSDN博客](https://blog.csdn.net/zhejfl/article/details/78544796)

[第十七期 U-Boot norflash 操作原理分析 《路由器就是开发板》_boot on flash_子曰小玖的博客-CSDN博客](https://blog.csdn.net/wxh0000mm/article/details/85610542)

[ICMAX介绍 NOR、 NAND、Raw Flash和 Managed Flash的区别](https://zhuanlan.zhihu.com/p/74163577)

[杂谈闪存二：NOR和NAND Flash](https://zhuanlan.zhihu.com/p/26745577)

[NAND Flash基础知识简介](http://blog.coderhuo.tech/2020/07/18/flash_basics/)

[UCI defaults](https://openwrt.org/docs/guide-developer/uci-defaults#integrating_custom_settings)

[Openwrt 编译进阶](https://fjkfwz.github.io/2014/08/16/Openwrt-Compile-Pro/)

[移远EC20（4G模块）通过openwrt路由器拨号上网 - OpenWrt开发者之家](https://www.openwrt.pro/post-542.html)

[Building image with support for 3g/4g and usb tethering](https://openwrt.org/docs/guide-developer/build-image-with-3g-dongle-support)

[Installing and troubleshooting USB Drivers](https://openwrt.org/docs/guide-user/storage/usb-installing)

[Use 3g/UMTS USB Dongle for WAN connection](https://openwrt.org/docs/guide-user/network/wan/wwan/3gdongle)

[How to use LTE modem in QMI mode for WAN connection](https://openwrt.org/docs/guide-user/network/wan/wwan/ltedongle)

[OpenWRT 使用 qmi 实现 4G 访问 - 二䖝](https://zsien.cn/openwrt-ltedongle/)

[OpenWRT 4G WWAN configuration](https://teklager.se/en/knowledge-base/openwrt-4g-wwan-configuration/)

[基于openwrt的MWAN3实现多运营商负载均衡的一种方法](https://zhuanlan.zhihu.com/p/352098418)

[Using the Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder#examples)

[image/Makefile Details](https://openwrt.org/docs/techref/image.makefile)

