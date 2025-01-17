---
title: "如何使用 shell（3/3）—— 配置 zsh"
series: "如何使用 shell"
date: 2021-05-10 20:00:00 +0800
updated: 2021-05-10 20:00:00 +0800
cover: "/assets/img/zsh-config/power.png"
categories: shell
tags:
- linux
- shell
---

轻量，简洁，简单。这个我对 zsh 配置的追求

1. [如何使用 shell（1/3）—— shell 兼容和历史](/shell/2021/05/01/sh-compatibles-history.html)
2. [如何使用 shell（2/3）—— 新时代的 shell](/shell/2021/05/05/new-shell.html)
3. 如何使用 shell（3/3）—— 配置 zsh

## 启动 shell

先来复习一下 shell 的登录和交互

### 交互（Interactive）

shell 有交互，或者没有交互。正常启动输入命令等待返回是需要交互的， 直接运行脚本的情况是不需要交互的

`echo $-` 判断是否交互，每个字母代表一个属性。 `i` 代表交互（interactive）

交互 shell 会有 PROMPT ，所以会有 `PS1` 变量，也可以通过 `PS1` 变量来判断是否交互

### 登录（Login）

login shell ，bash 通过 `shopt` 来判断，zsh 通过 `setopt` 判断。（zsh 的 `echo $-` 也可以判断是否登录）。
请记住 `setopt` 这条命令， zsh 的好多功能都是通过 `setopt` 来设置的，取消用 `setopt noxxx`  或者 `unsetopt`

打开终端和 ssh 默认都是登录 shell。直接执行 `bash` / `zsh` 是非登录的 （non-login shell），要指定 `--login` 参数。
`su` 命令默认也是非登录的，要指定参数：`su -` 或 `su -l` 。 `-` 和 `-l` 是完全等同的

交互和登录排列组合可以分成四种情况：

- 非交互非登录
- 非交互登录
- 交互非登录
- 交互登录

他们加载的配置文件也不同。为了简化处理，直接忽略其他的文件，只用 `bashrc` 或 `zshrc` 。
把其他的都删掉（ `.bash_profile` , `.bash_login` , `.zprofile` , `.zlogin` 这些都删掉），这样一定会读 `.bashrc` 或 `.zshrc` 文件

### motd

熟悉 Linux 的同学想必对 motd 全称 Message Of The Day 并不陌生

把内容放到 `/etc/motd` 里面然后每次登录显示里面的内容

motd 本身是纯文本，传统的 motd 只能是纯文本。当然，我们可以在 shell 启动执行命令时显示一些东西，达到类似 motd 功能的效果

比如使用 `cowsay` 显示欢迎信息（把这条命令放到 shell 的配置文件里）

```bash
$ echo "Hello! ${USERNAME}" | cowsay -f tux
 ______________
< Hello! metal >
 --------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
```

## 主题和配置框架

如果不使用任何主题，就要自己和 `$PS1` 变量打交道， `PS` 一共四个变量。考虑自己设置的复杂性。首选当然是使用大佬们的配置

zsh 由于历史问题，默认设置基本上和几十年前一样，现在的 zsh 有很多非常强大的功能。只不过默认是并不开启

### oh-my-zsh

作为 zsh 最出名的配置框架。配置 zsh 甚至可以说 oh-my-zsh 和 非 oh-my-zsh

自动设置颜色部分，只要启用就可以覆盖掉难看的要死的默认配色。默认配置很完美

集成了大量实用的函数和主题（个人推荐 `ys` 主题），比较极端的用户甚至会使用 ramdom 主题，每次开启随机选择一个，保证新鲜感

oh-my-zsh 管的东西太多了。oh-my-zsh 的各种插件里面基本上全是 aliases。建议一个都不要用

### prezto

oh-my-zsh 之外的另一个选择，或者说是他的的替代品。比 oh-my-zsh 轻量一点。

### zimfw

用 ruby 的 `erb` 模版引擎，编译产生最终配置文件。

在 `zimrc` 里面配置启用的插件，然后编译产生 `~/.zshrc` 文件。每次修改更新都要重新编译，不过问题不大，**每天都在修改配置文件才是最大的问题**

默认会开启 git 插件，注意把 git 插件禁用（我推荐把这个禁用），这个插件全是 git aliases。请仔细阅读代码再决定是否要使用这个插件

### grml-zsh-config

一个及其轻量化的配置，也没有管理插件的功能。Grml OS 的默认 zsh 配置，Grml 是基于 Debian 的 Linux 发行版。主要是为了 live CD 设计的

我很喜欢 grml 的配置，简单轻量。这才是新时代的默认设置。grml 不包括管理插件的功能。是一个纯粹的 `zshrc` 文件

grml 内置了几个主题：

```bash
# 列出主题
prompt -l

# 预览主题
prompt -p adam2

# 设置主题
prompt -s adam2

# 关闭主题，使用其他的主题
prompt off
```

grml 的 zsh 配置拥有非常灵活的配置，默认的 grml 主题支持 vsc （git 显示当前分支）可以自定义显示的各种项。比如像这样来让 prompt 显示两行：

```bash
# Set Theme
# http://bewatermyfriend.org/p/2013/001/
zstyle ':prompt:grml:left:setup' items rc change-root user at host path vcs newline percent

prompt grml
```

### powerlevel 系列

powerline 系列的 zsh 版主题

![power.png](/assets/img/zsh-config/power.png)

powerlevel9k 是一个极其复杂的主题，他绝对会令你眼前一亮，或者应该称为地表最强 zsh 主题。这个主题最与众不同的地方大概就是和各种编程环境的整合，甚至可以识别一些 Web 框架，编程语言的 VM 环境

后来针对性能，有人开发 powerlevel10k，就如同 powerlevel9k 一样，同时又有的不错的性能

![power.png](/assets/img/zsh-config/powerlevel.png)

### pure

这是一个非常不错的主题。虽然自称是 prompt ，不过应该把他归类为主题。因为对于 shell 来说，主题就是 prompt

## 分离式 prompt

在 shell 里实现复杂的 prompt 这太复杂了，干脆在外面套一层吧。后来就又了新的思路。在旧的 shell 上套一个进行交互外壳。
我就自作主张起个新名字叫 “分离式 prompt” 吧。分离式 prompt 虽然功能强大。不过，我们真的需要这么强大的提示符吗？

### Liquid Prompt

这个大概 Liquid Prompt 是最早这么干的，把 prompt 单独做成一个组件。配置管理都是独立于其他的功能，支持 bash 和 zsh

### spaceship-prompt

这个一个专门为 zsh 优化的 prompt，仍然时纯 shell 的实现，可以说 spaceship 直接把 prompt 的复杂程度拉高了一个等级。逐步走向前后端分离的 prompt

### starship

只是一个 prompt ，使用 rust 的实现，速度和效率异常之高。这个作为一个交互的前端，具体使用的 shell 作为后端。可以支持绝大部分的 shell。已经彻底走向了前后端分离的 prompt。

![https://raw.githubusercontent.com/starship/starship/master/media/demo.gif](https://raw.githubusercontent.com/starship/starship/master/media/demo.gif)

### oh-my-posh

最开始是专门给 powershell 写的，后来用 golang 重写了之后，也变成了前后端分离的 prompt。也可以指定不同的后端

## 插件管理器

我个人是不用这个插件管理器的，插件管理器只是方便了你来回折腾，但每天折腾 shell 配置这就不对了

### antigen

这个是 zsh 官方的插件管理工具，绝对清真。是一个存粹的包管理。哦不，他对 oh-my-zsh 和 prezto 做了特殊的适配

### antibody

使用 golang 写的包管理器。看名字就知道，对标 antigen

### zplug

类似 vim-plug 的插件管理器

![https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)

### zgen

一个轻量化的插件管理器，只有 500 行代码

### zinit

是用 C 实现的插件管理器，有极高的性能，可能是速度最快的。zplugin 和 zinit 的是一个项目，zplugin 是之前的名字。

和 zimfw 一样，可以编译插件来运行的更快。和 zimfw 不同，不提供配置，这个只是插件管理器和编译器。

## zsh 插件

fish 有不少实用的特性，代码高亮、自动建议。fish 的很多交互特性已经在 zsh 都实现了

### zsh-users 系列

zsh-users 是一个 zsh 官方的仓库，有几个很棒的插件，基本上所有的 zsh 配置框架都集成这几个插件：

- zsh-syntax-highlighting（代码高亮）
- zsh-autosuggestions（自动建议）
- zsh-history-substring-search（前缀搜索）

还有比如：[zsh-users/zsh-apple-touchbar](https://github.com/zsh-users/zsh-apple-touchbar) 我的 MBP 没有 touchbar 所以不做评论

### zinit 系列

- fast-syntax-highlighting（高性能代码高亮）
- history-search-multi-word（增强版的 `Crtl-R`）

zinit 的作者写的插件，可以用这里的插件去替代 zsh-users 系列的插件

### thefuck

纠正拼写错误。用个插件的人好像还不少，我不用这个，也不推荐用这个插件。

我倒是很想知道用这个插件的人是什么心态 fuck，fuck，fuuuu...

### autojump

根据使用习惯来自动跳转目录，他会维护一个数据库，记录平时都使用哪些目录

## 自定义功能

MacOS 需要设置一下默认快捷键，`Crtl + left/right arrow` 被 Mission Control 功能占用了

`System Preferences > Keyboard > Shortcuts` 的 `Crtl + left/right arrow` 的快捷键改掉，不然跳一个词的功能就没有了。
我是改成了 `Crtl + Command + left/right arrow` 。我记得 Deepin Linux 的切换虚拟桌面默认就是这个键位

### 关闭流控功能

shell 和终端（iTerm2 是忽略这个功能的）要同时支持才能看到效果，大部分终端都是支持的。shell 默认都是启用这个功能的

这个是一个古老的功能，在历史上（现在某些终端中仍然如此），`Ctrl-S` 暂停输出，而 `Ctrl-Q` 继续输出。站在今天的角度来看，这个功能基本上没用。还要占用两个快捷键

很多框架的设置默认是不禁用 `flowcontrol` 。配置框架里只有 oh-my-zsh 是设置禁用了

我们来把他关掉： `setopt noflowcontrol`

```bash
# 关掉 flowcontrol
unsetopt flowcontrol

# 上面的设置在 Tmux 里面无效
stty -ixon
```

### push-line

这个功能不知道该怎么描述。oh-my-zsh 有个 `Ctrl-Q` 的快捷键，可以把当前的输入保存起来，然后去执行一条新的命令，执行完之后在保存的内容放出来。这个功能非常的实用

很多设置和框架会设置把 `Ctrl-Q` 设置成 `push-line`

```bash
bindkey "\eq" push-line
```

但 `push-line` 是没法处理 here doc 的情况的

可以设置成 `push-line-or-edit` 就可以处理 here doc

```bash
bindkey "\eq" push-line-or-edit
```

`push-line` 和 `push-line-or-edit` 很实用，是 zsh 内置的功能。默认是不启用的，zsh 还有好多这样默认不启用的功能。
写新功能之前最好先去 `man zshzle` 里看看有没有现成的

### 快速 sudo

或许你会经常 `sudo !!` 来使用 `sudo` 执行前一条命令

`sudo` 用的比较多，所以我们来定制一个快捷键。

```bash
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  local cmd="sudo "
  if [[ ${BUFFER} == ${cmd}* ]]; then
    CURSOR=$(( CURSOR-${#cmd} ))
    BUFFER="${BUFFER#$cmd}"
  else
    BUFFER="${cmd}${BUFFER}"
    CURSOR=$(( CURSOR+${#cmd} ))
  fi
  zle reset-prompt
}

zle     -N   sudo-command-line
# Ctrl-S
bindkey '^S' sudo-command-line
```

这样直接使用 `Ctrl-S` 就可以快速在前面添加 `sudo` ，如果前面有 `sudo` 就自动去掉 `sudo`

~~grml 里也带了类似的配置，不过只支持添加 `sudo` ，我这种改法和 grml 是有区别的。~~

现在 grml zsh 的配置和我这个用的是同样的配置了 [grml/zshrc#119](https://github.com/grml/grml-etc-core/pull/119)

### 命令补全加载优化

`kubectl` 这个命令是个典型，这个补全文件非常大，有上万行

```bash
kubectl completion zsh | wc -l
13090
```

官方文档这个放在 `.zshrc` 里是一种性能很差的写法

```bash
source <(kubectl completion zsh)
```

生成一个文件，然后放到 `$FPATH` 是个更好的选择

```bash
kubectl completion zsh > ~/.zsh-completions/_kubectl.zsh
```

把这个放到 zsh 的配置文件里

```bash
if [[ -d "${HOME}/.zsh-completions" ]]; then
  FPATH=${HOME}/.zsh-completions:$FPATH
fi
```

或者使用 Lazyload 方式，先定义一个占位函数，然后输入时加载。
不过 `$FPATH` 已经是懒加载。我一直都觉得把 Lazyload 用在 completion 上是个误区（看到过有人这样用，欢迎来把我辩倒）

### fzf 和 shell

fzf 是提供了给 shell 用的快捷键的，需要自己去开启这个功能

![fzf-history.png](/assets/img/zsh-config/fzf-history.png)

```bash
# brew --prefix fzf
# source $(brew --prefix fzf)/shell/completion.zsh
# source $(brew --prefix fzf)/shell/key-bindings.zsh
source /usr/local/opt/fzf/shell/completion.zsh
source /usr/local/opt/fzf/shell/key-bindings.zsh
```

提供三个绑定的快捷键

- `Ctrl-R` 增强历史查找
- `Crtl-T` 模糊路径选择
- `Alt-C` 模糊路径跳转

补全功能提供 `**` 的然后按下 `<TAB>` 语法，使用 fzf 来选择补全

`Crtl-T` 其实是个 zsh 默认的快捷键，fzf 提供的模糊路径选择的功能使用的频率太低，这里再设置回默认的快捷键

```bash
bindkey '^T' transpose-chars
```

对于苹果的电脑 `Alt-C` 的快捷键要处理一下

```bash
# Default ALT-C, For Mac OS: Option-C
if [[ `uname` == "Darwin" ]]; then
  bindkey 'ç' fzf-cd-widget
fi
```

### 最近目录

还记得 Elvish `Crtl-L` 的列表选择跳转最近目录的功能吗？

配合 fzf 来实现一个，由于 `Crtl-L` 快捷键已经被占用，所以使用 `ALT-X`

```bash
fzf-dirs-widget() {
  # eval cd $(dirs -v | fzf --height 40% --reverse | cut -b3-)
  local dir=$(dirs -v | fzf --height ${FZF_TMUX_HEIGHT:-40%} --reverse | cut -b3-)
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  eval cd ${dir}
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N    fzf-dirs-widget

# Default ALT-X, For Mac OS: Option-X
if [[ `uname` == "Darwin" ]]; then
  bindkey '≈' fzf-dirs-widget
else
  bindkey '\ex' fzf-dirs-widget
fi
```

### 导航模式（Navigation mode）

Elvish `Crtl-N`  的快捷键，来启动导航模式。类似 ranger 或 nnn 的 tui 里面选择目录

这个功能，可以用 ranger 或 nnn 来改造。这两个项目都提供了例子，我还是更偏爱 ranger 一些，nnn 的运行速度更快。
还有一个纯 shell 的非常精简的实现 [vifon/deer](https://github.com/vifon/deer)

- ranger

![ranger.png](/assets/img/zsh-config/ranger.png)

```bash
# Fork from: https://github.com/ranger/ranger/blob/master/examples/shell_automatic_cd.sh
ranger_cd() {
  local temp_file="$(mktemp -t "ranger_cd.${USERNAME}")"
  ranger --choosedir="$temp_file" -- "${@:-$PWD}"
  if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
    cd -- "$chosen_dir"
  fi
  rm -f -- "$temp_file"
}

# This binds Ctrl-N to ranger_cd:
bindkey -s '^N' 'ranger_cd\n'
```

- nnn

有的包把这个脚本也包括了进来，比如 Archlinux。可以直接 `source`

```bash
source /usr/share/nnn/quitcd/quitcd.bash_zsh
bindkey -s '^N' 'n\n'
```

在 MacOS 的 homebrew 并没有提供 `quitcd` 脚本，需要自己设置一下

```bash
# Frok from: https://github.com/jarun/nnn/blob/master/misc/quitcd/quitcd.bash_zsh
nnn_cd () {
  # Block nesting of nnn in subshells
  if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
  fi

  # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
  # To cd on quit only on ^G, remove the "export" as in:
  #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  # NOTE: NNN_TMPFILE is fixed, should not be modified
  export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

  # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
  # stty start undef
  # stty stop undef
  # stty lwrap undef
  # stty lnext undef

  nnn "$@"

  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE" > /dev/null
  fi
}

bindkey -s '^N' 'nnn_cd\n'
```

- lf

如果觉得 `ranger` 是 python 写的比较慢，也不喜欢 `nnn` 。那可以试试 golang 写的 `lf`

```bash
Frok from: https://github.com/gokcehan/lf/blob/master/etc/lfcd.sh

lfcd () {
  tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    if [ -d "$dir" ]; then
      if [ "$dir" != "$(pwd)" ]; then
        cd "$dir"
      fi
    fi
  fi
}

bindkey -s '^N' 'lfcd\n'
```

- hunter

这是一个 Rust 写的命令行文件管理器。目前还没有办法和 shell 联动，未来也许会有这个功能

### 变量

我们肯定都见过这种写法

```bash
if [ -d "$HOME/go/bin" ]; then
  PATH="$HOME/go/bin:$PATH"
fi
```

路径比较多，统一一下

```bash
# Load path
_enabled_paths=(
  'go/bin'
  '.bin'
  '.local/bin'
  '.cargo/bin'
)

for _enabled_path in $_enabled_paths[@]; do
  [[ -d "$HOME/${_enabled_path}" ]] && PATH="$HOME/${_enabled_path}:$PATH"
done

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export EDITOR='vi'
export VISUAL='nvim'
```

`VISUAL` 和 `EDITOR` ，会优先使用 `VISUAL` ，当无法使用时才会使用 `EDITOR`

### 性能

比起慢点要死的 oh-my-zsh。这已经快了几个量级了

```bash
for i in $(seq 1 5); do time /bin/zsh -i -c exit; done
/bin/zsh -i -c exit  0.11s user 0.07s system 86% cpu 0.211 total
/bin/zsh -i -c exit  0.12s user 0.05s system 93% cpu 0.188 total
/bin/zsh -i -c exit  0.11s user 0.06s system 91% cpu 0.187 total
/bin/zsh -i -c exit  0.12s user 0.06s system 89% cpu 0.199 total
/bin/zsh -i -c exit  0.12s user 0.06s system 84% cpu 0.219 total
```

## 我用什么配置

本文的配图说明不了什么，我选了一些视觉冲击力强的插件的配图，实际上，我个人的配置十分的精简。最实用的配置图片上看不出来任何高端的地方。**真正干活的实用配置看起来和默认的差不多**

好的提示符：

- 当前路径
- git branch（应该是可以选的，作为软件开发者，这个很有必要）
- 上一条命令的执行结果 `$?`
- 如果是服务器，最好要显示主机名和用户
- 个人的喜好，偏好两行
- 尽量不要有特殊字体和特殊字符（ascii 的字符）

我的主力机 MPB 上用  zimfw 的默认配置，再加上一点自己定义的函数，其他的机器上都是 grml 的默认配置

如果对我的配置感兴趣可以来这里看：[a-wing/dotfiles#zsh](https://github.com/a-wing/dotfiles/tree/master/zsh)

## Reference

[你不需要花哨的命令提示符](https://zhuanlan.zhihu.com/p/51008087)

[千万别混淆 Bash/Zsh 的四种运行模式](https://zhuanlan.zhihu.com/p/47819029)

[Untitled Spot_未命名小站 - 浅谈motd的历史，并在Linux下使用多种方法实现动态motd消息显示](https://untitled.pw/software/linux/2337.html)

[Prompt themes for grml](http://bewatermyfriend.org/p/2013/001/)

[lilydjwg/dotzsh](https://github.com/lilydjwg/dotzsh)

[spf13/cobra](https://github.com/spf13/cobra/blob/master/shell_completions.md)

[VISUAL vs. EDITOR - what's the difference?](https://unix.stackexchange.com/questions/4859/visual-vs-editor-what-s-the-difference)

[Powerlevel9k: personalise your terminal prompt for any programming language](https://blog.hassler.ec/wp/2018/11/23/powerlevel9k-personalise-your-terminal-prompt-for-any-programming-language/)

