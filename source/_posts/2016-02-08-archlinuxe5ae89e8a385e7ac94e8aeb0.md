---
title: archlinux安装笔记
date: 2016-02-08 14:38:23+00:00
updated: 2016-02-08 14:38:23+00:00
categories: linux
tags:
- linux
- archlinux
---

设置网络

有线DHCP的网会自动设置

无线

systemctl stop dhcpcd #停止有线网，会和无线引起冲突

wifi-menu -o wlpxxxxx #连接wifi

如果ssid为隐藏的

cp /etc/netctl/examples/wireless-wpa /etc/netctl/

vim /etc/netctl/wireless-wpa #修改这个文件，去掉Hidden前面的注释

netctl start ethernet-static　＃然后启用配置

fdisk /dec/sda ＃分区

mount /sda1 /mnt　＃挂载

pacstrap /mnt base # 安装基本系统

genfstab -U -p /mnt > /mnt/etc/fstab # 自动写如fstab

arch-chroot /mnt

vim /etc/locale.gen # 把zh开头的去掉

passwd # 设置密码

pacman -S grub # 安装grub软件包

grub-install /dev/sda #安装grub到硬盘

grub-mkconfig -o /boot/grub/grub.cfg # grub配置文件自动写入

可以重启了，但重启网会有问题

有线

pacman -S dhcpcd

重启之后

systemctl start dhcpcd

dhcpcd

无线

pacman -S networkmanager

重启之后

systemctl start NetworkManager

nmtui # 图形化配置

也可　nmcli dev wifi connect ssid passwork password

reboot


