---
layout: post
title: "如何使用 shell（1/3）—— shell 兼容和历史"
author: "Metal A-wing"
date: 2021-05-01 20:00:00 +0800
toc: true
image: "/assets/img/sh-compatibles-history/unix-shells-large.png"
banner: "/assets/img/sh-compatibles-history/unix-shells-large.png"
categories: shell
---

`shell` 的名字和概念是从 Unix 的前身 Multics 发展过来的。应用程序通过 shell 来进行调用并被系统执行。

一般的 sh 指的是 bsh （Bourne shell），但 Bourne shell 并不是 bash。bash 是 Bourne Again Shell

![unix-shells-large.png](/assets/img/sh-compatibles-history/unix-shells-large.png)

1. 如何使用 shell（1/3）—— shell 兼容和历史
2. [如何使用 shell（2/3）—— 新时代的 shell](/shell/2021/05/05/new-shell.html)
3. [如何使用 shell（3/3）—— 配置 zsh](/shell/2021/05/10/zsh-config.html)

## Thompson shell

Thompson shell（即 V6 Shell）是历史上第一个 Unix shell，1971 年由 Ken Thompson 写作出第一版并加入 UNIX 之中。
它是一个简单的命令行解释器，但不能被用来运行 Shell script 。
它的许多特征影响了以后命令行界面的发展。至 Unix V7 之后，被 Bourne shell 取代。

当时关键字还只有 `if` and `goto` 两种

管道和重定向就是那个时候做出来的

```bash
# 管道
command1 | command2
# 输出重定向
command1 > file1
```

## PWB shell

PWB shell 是 Thompson shell 的一个改进版本，完全兼容 Thompson shell

为了解决硬编码的问题引入来这两个变量： `$HOME` , `$PATH`

加入双引号 `""` 里面放变量的做法

```bash
VAR=World
echo "Hello $VAR"
# hello world

# 或者使用这样消除歧义的写法
echo "Hello ${VAR}"
```

PHP 也是参照这一设计

```php
<?php
$VAR="World";
echo "Hello $VAR";
// hello world
```

Perl 也是这样

```perl
$VAR = "World";
print "Hello $VAR";
```

这时的语法还是 `if-then-else-endif` 语法

## Bourne shell

Bourne shell 于 1979 年作为 Unix V7 的一部分首次公开发布。（几乎所有的 Unix 和 类Unix 系统都是 Unix V7 的后代）

Bourne shell 并没有去兼容 Thompson shell 。然后 `case ~ in ~ esac` 这个诡异的语法就诞生了

Here Documents 也是这个时候诞生的 `cat <<-EOF`

```bash
cat > file1 << EOF
233
EOF
```

还有就是增加了 ``command`` 子命令

```bash
echo "两数之和为 : `expr 2 + 2`"

echo "Hello `echo World`"

go run `ls *.go | grep -v _test.go`
```

---

Bourne shell 取代了早期的 Thompson shell，发生在 Unix 历史的早期，现在几乎被遗忘。不过，为什么 Bourne shell 替代了 Thompson shell？

Ken Thompson 不想继续维护 shell。还有一个问题是 Thompson shell 不足以适应 unix 的发展，PWB shell 难以解决 Thompson shell 自己的问题。或者说当时的 shell 只是一个用户的接口。就像我们今天看到的 web 界面一样的微不足道的地方。当时大概没有人想到 shell 会变成一门语言，或是一个标准

## Csh

1978 年，Bill Joy 还在加州大学伯克利分校读书的时候，就为 BSD UNIX（Berkeley Software Distribution UNIX）开发了 C Shell。

C shell 的 C 是来自于 c 语言，语法更接近 c 语言， 但并不和 Bourne shell 兼容

csh 对交互使用做出了巨大的改进

- 命令历史
- `~` 出现了作为 `$HOME` 的另一种写法
- `alias` 命令

```bash
alias gc='git commit'

# Overriding aliases
alias ls='ls -la'
```

- 最近访问目录栈
    - `dirs` 显示当前目录栈 `dirs -v`
    - `pushd` 入栈，切换当然目录（等同 `cd && dirs` ）
        - `pushd` 没有参数时和 `cd -` 一样效果
        - `pushd` 和 `cd` 参数完全一样 `cd -1` , `cd +2` , `cd -0`, `pushd +0`, `pushd -2`
    - `popd` 出栈，并切换到栈顶部的目录

```bash
[user@server /etc] $ dirs
/usr/bin
[user@server /usr/bin] $ pushd /etc
/etc /usr/bin
[user@server /etc] $ popd
/usr/bin
```

- 任务控制
    - `Ctrl-z` 将信号 `SIGTSTP` 发送到当前任务，该任务将挂起，并放到后台
    - `bg` 把挂起的任务继续执行（在后台执行）
    - `fg` 把后台任务放到前台执行，如果是挂起状态也恢复执行
    - `&` 放到后台运行

```bash
sheep 10
# Ctrl-z 暂停这个任务

# bg 命令把他放到后台运行
bg

# 也可以直接放到后台运行
sleep 10 &
# fg 把后台最上面的放到前台运行
fg
```

## Tcsh

Csh 出现的五年之后 卡内基-梅隆大学 的 Ken Greer 引入了 Tenex 系统中的一些功能，如命令行编辑功能和文件名和命令自动补全功能。开发了 Tenex C shell（tcsh）

在 csh 的基础上增加了

- 行编辑
- 命令补全

`!!` 执行之前的命令

`!n` 执行之前执行的 n 条命令

Mac OS X 在 10.1 puma 的时候默认 shell 是 tcsh

tcsh 直到今天还在维护，我们可以在 Github 看到代码：[tcsh-org/tcsh](https://github.com/tcsh-org/tcsh)

## KornShell

KornShell（ksh）是由 David Korn 在 1980 年代初期由贝尔实验室（Bell Labs）开发，并于 1983 年 7 月 14 日在 USENIX 上发布（差不多跟 Tenex C Shell 同时发布）。

最初的开发基于 Bourne shell 源代码。早期贝尔实验室的贡献者 Mike Veach 和 Pat Sullivan，他们分别开发了 `emacs` 和 `vi` 风格的行编辑模式。

KornShell 与 Bourne Shell 向后兼容，并受贝尔实验室用户的要求和启发，包括 C Shell 的许多功能。 最引人瞩目的特性就是支持脚本编程。

现在的 zsh/bash 也有这两种行编辑模式：默认是 `emacs` 风格

- `Ctrl-b` 左移光标
- `Ctrl-f` 右移光标
- `Ctrl-p` 查看上一条命令（或上移光标）
- `Ctrl-n` 查看下一条命令（或下移光标）
- `Ctrl-a` 移动光标至行首
- `Ctrl-e` 移动光标至行尾
- `Ctrl-w` 删除前一个词
- `Ctrl-u` 删除从光标至行首的内容
- `Ctrl-k` 删除从光标至行尾的内容
- `Ctrl-y` 粘贴已删除的文本（例如粘贴 `Ctrl-u` 所删除的内容）
- `Alt-right`, `Alt-f`, `Ctrl-right` 向右移动一个词
- `Alt-lift`, `Alt-b`, `Ctrl-lift` 向左移动一个词

不过在 Apple 的设备里移动一个词只有 `Alt-right`, `Alt-lift` 是可以使用的

我认为这里面用的最多的就是移动到 `Ctrl-a` （移动到行首，顺便加个 `sudo`）和 `Ctrl-e` （移动到行尾）

也可以使用 `set -o vi` 切换成 `vi` 风格的操作，我个人是基本不使用这个，因为绝大部分情况只有一行，需要仔细编辑的长命令太少了。最蛋疼的地方在于 `vi` 风格的操作是有模式的，而且看不到模式状态，只能靠盲打

---

甚至还支持关联数组（Associative Array）。关联数组是个啥？在现代化的脚本语言（Ruby 和 Python 之类）里面很常见，又称映射（Map）、字典（Dictionary）。或者说是哈希表（Hashmap）（严格的来说哈希表只是实现关联数组的一个实现）

```bash
declare -A filetypes=([txt]=text [sh]=shell [mk]=makefile)
filetypes[c]="c source file"

# 获取关联数组的长度
echo ${#filetypes[*]}

# 输出键为 txt 的值
echo ${filetypes[txt]}
```

## POSIX shell

POSIX shell 是基于 1988 年版本的 KornShell（`ksh88`），而 KornShell 又是为了取代 AT&T Unix 上的 Bourne shell，在功能上超过了 BSD 的 C shell。
就 ksh 是 POSIX shell 的祖先而言，大多数 Unix 和类似 Unix 的系统今天都包括 Korn shell 的一些变体。
例外的情况一般是微小的嵌入式系统，它们无法承受一个完整的 POSIX shell 所需要的空间。

我们今天说的 POSIX shell 兼容就是这个时候衍生出的标准

## Ash

Almquist shell (也称为 A shell、ash 和 sh) 是一种轻量级 Unix shell（最大的特点就是轻量化）。
最初由 Kenneth Almquist 在20 世纪 80 年代末编写。它在 BSD 版本的 Unix 取代了 Bourne shell

BSD 世界之外有两个重要的分支：

1. `dash` (Debian Almquist shell) 在 2006 年被 Debian 和 Ubuntu 作为默认的 `/bin/sh` 实现。（Bash 仍然是 Debian 衍生产品中的默认交互式命令 shell。）
2. BusyBox 中的 `ash` 命令，在嵌入式 Linux 中经常使用，可用于实现 `/bin/sh`。由于它是在 `dash` 之前发布的，并且它是从 Debian 的旧 `ash` 软件包衍生而来的，所以我选择将其视为 `dash` 的派生形式，而不是 `ash`，尽管它在 BusyBox 中是命令名称也是 `ash`

    （BusyBox 还包括一个叫 `hush` 的 `ash` 替代品，功能较弱。通常，在给定的 BusyBox 二进制文件中将仅内置这两者之一：默认情况下为 `ash`，但当空间非常狭窄时则采用 `hush`。因此，基于 BusyBox 的 `/bin/sh` 系统并不总是像 `dash` 一样。）

嵌入式 Linux 系统，或以 Linux 为基础的路由系统：OpenWRT 之类的都 BusyBox `ash`

## Rc shell

rc（Run Commond）是 Bell Labs 操作系统的 Unix V10 和 Plan 9 的命令行解释器。
它类似于Bourne shell，但是其语法稍微简单一些。 由 Tom Duff 开发，这个并不是 POSIX shell 兼容

## Bash (Bourne Again Shell)

Bash（Bourne Again Shell）是 Brian Fox 为 GNU 项目编写的 Unix Shell 和命令语言，是 Bourne Shell 的免费软件替代品。
它于 1989 年首次发布，被用作大多数 Linux 发行版的默认登录 shell。

Bash 也是个双关词。也有 “Born Again（重生）shell” 的意思

Korn Shell 原本是专有软件，直到 2000 年，它才（遵照通用公共许可协议）作为开源软件发布

BSD Unix 避开了它，而选择了 C shell，而且在 Linux 起步时，它的源代码也不能免费提供给 Linux 使用。
因此，当早期的 Linux 发行版去寻找一个 shell 来搭配他们的 Linux 内核时，他们通常会选择 GNU Bash

自 2002 年发布 Mac OS X 10.2 Jaguar 以来，Mac OS X 也换成了 Bash

Linux 与 Bash 之间的这种早期联系几乎决定了许多其他 shell 的命运，包括 ksh、csh 和 tcsh。今天仍有一些死忠粉在使用这些 shell。

signal 处理 (使用 `trap`)

```bash
# 捕获 INT 信号来实现安全的退出
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
  echo "** Trapped CTRL-C"
  exit
}
```

有 Debug 模式

- `bash -x script.sh` 来运行脚本也可以 `-v` 输出更详细的信息
- `set -x` 来启用 debug 模式
- `set +x` 来禁用 debug 模式

或者可以这样说：Here String 是 Here Document 的一个变种

Bash 可以使用 `<<<` 操作符从 "here string" 重定向标准输入(stdin)。

```bash
cat <<< 233
```

## Zsh

Paul Falstad 于 1990 年在普林斯顿大学读书时编写了 Zsh 的第一版。 zsh 的名称源自耶鲁大学教授 Zhong Shao（邵中，没错是华人，当时是普林斯顿大学的助教）的名字 Paul Falstad 认为 Shao 的登录 ID“ zsh” 是 shell 的好名字。

还有一种网上流传的说法是：z 是字母表的最后一个字母。zsh 的意思就是最后的 shell。或者从现在来看，zsh 大概是 POSIX shell 里最后一代的 shell 了

MacOS X 15 Catalina 将默认 shell 程序更改为 Zsh。在 2009 年 2 月，Bash 4.0 将其许可证切换到 GPLv3。
一些用户怀疑这种许可变更是 MacOS 继续使用旧版本的原因随着 2019 年 MacOS Catalina 的发布，苹果改变了默认 shell

---

Zsh 的模拟模式（emulation mode）`emulate sh`

Zsh 是与 Bash 兼容的。这种说法既对，也不对，由于 Zsh 自己做为一种脚本语言，是与 Bash 不兼容的。
符合 Bash 规范的脚本没法保证被 Zsh 解释器正确执行。因此，Zsh 实现中包含了一个模拟模式（emulation mode），支持对两种主流的 Bourne 衍生版 shell（bash、ksh）和 C shell 的模拟 （csh 的支持并不完整）。

在 Bash 的 emulation mode 下，可使用与 Bash 相同的语法和命令集合，从而达到近乎彻底兼容的目的。使用对 Bash 的模拟，需要显式执行：

```bash
emulate bash
```

## 默认的系统 shell 和兼容

在许多系统中，默认的交互式命令 shell 程序和 `/bin/sh` 是不同的东西。 `/bin/sh` 可能是：

- 原始的 Bourne shell。这在较早的 UNIX 系统中很常见，例如 Solaris 10（于 2005 年发行）及其前身。
- Korn Shell（ksh93），例如 OpenBSD，Solaris 11（2010）。
- 各种 Ash，前几年各大 Linux 发行版还是 Ash（执行脚本用 ash ，交互控制用 Bash） 。现在很多都是 Bash。
- GNU Bash，在称为 sh 时会禁用其大多数非 POSIX 扩展。

所有这些历史解释了为什么像 bash、zsh 和 [yash（yet another shell）](https://github.com/magicant/yash) 这样的后起之秀的创造者会选择使它们与 sh 兼容。
Bourne/POSIX 兼容性是类 Unix 系统的 shell 必须提供的最低限度，以获得广泛的采用。这就是 `sh-compatibles`

## Reference

[Debian Reference 第 1 章 GNU/Linux 教程](https://www.debian.org/doc/manuals/debian-reference/ch01.zh-cn.html#list-of-shell-programs)

[Archlinux Zsh](https://wiki.archlinux.org/index.php/zsh)

[What does it mean to be "sh compatible"?](https://unix.stackexchange.com/questions/145522/what-does-it-mean-to-be-sh-compatible)

[Why did the Bourne shell replace the Thompson shell?](https://www.quora.com/Why-did-the-Bourne-shell-replace-the-Thompson-shell)

[Transitioning From Oracle Solaris 10 to Oracle Solaris 11](https://docs.oracle.com/cd/E23824_01/html/E24456/userenv-1.html)

[Debugging Bash scripts](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_03.html)

[tangentsoft.com/misc/unix-shells-large.png](https://tangentsoft.com/misc/unix-shells-large.png)
