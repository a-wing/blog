---
layout: post
title:  "Linux 下的一些骚操作"
author: metal A-wing
date:   2018-02-18 15:11:35 +0800
categories: linux
---

简单的东西觉得水，难的东西不会写。作为一个 ~~资深~~ linux用户，讲点使用linux的骚操作。没啥实际用途。。。不过可以拿来装逼，也可以提高linux使用效率


### 关于ssh:

#### 把文件打包拷贝到远程
```bash
# 通常做法
scp -r dir/ user@remote-server:/

# 骚操作
tar -cJvf - dir/ | ssh user@remote-server "tar -xJvf -"
```

#### 拷贝公钥到远程服务器
```bash
# 通常做法
scp ~/.ssh/id_rsa.pub user@remote-server:~
ssh user@remote-server
mkdir .ssh && cat id_rsa.pub >> .ssh/authorized_keys

# 骚操作
ssh-copy-id user@remote-server
```

#### 追加写入文件？没权限？
```sh
# 例：
echo 233 >> /etc/ssh/sshd_config

# 这样会没权限理所应当会想到：
sudo echo 233 >> /etc/ssh/sshd_config

# 还是没权限？什么鬼？试试这样写：
sudo sh -c "echo 233 >> /etc/ssh/sshd_config"
```

### 批量搜索文件内容
```bash
find 目录名 -type f | xargs cat | grep 要搜索的内容
```

### vim 批量注释
1. `crtl + v` 进入超级块模式
2. 选中要插入行的行首
3. 用 `I` 命令
4. 输入注释字符`#` 或 `//`
5. `esc`


### 如果你用的是deb 系的包管理
在执行`make install`时会安装。但卸载会有问题

有些软件不提供 `make uninstall`

可以用 `checkinstall` 来代替`make install`来安装软件

checkinstall 会产生一个虚拟环境来执行make install 然后打包成 deb 包

这样卸载时就可以通过`dpkg`来移除软件包

可以先搜索一下这个软件属于哪个包

```sh
dpkg -S <软件名>
```
