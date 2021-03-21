---
layout: post
title: "干活向的 vim 配置"
author: "Metal A-wing"
date: 2021-03-21 21:00:00 +0800
image: "/assets/img/work_vim_config/vim-banner.png"
categories: vim
---

2021 年该用什么样的配置

极简，高效。这是实际干活用的，不需要太多插件和功能

这个配置是我用了三年多的 vim 不断改进的，实用主义

常年不用的插件都被我移除了

还有一个问题是我经常在不同的编程语言之间反复横跳，所以不依赖特定语言或框架的配置

我平时工作是就是这样来使用的，我一般都是在 tmux 跑 vim

![tmux vim](/assets/img/work_vim_config/screenshot_2021-03-21_18-10-12.png)

## vim 基础

### 版本

vi 最老的版本。后来有了 Vim。可使用 vi 模式

近几年重写的版本 nvim (NeoVim)。nvim 最重要的功能就是支持了异步。后来 vim8 也支持了异步，已经没有什么区别了

带 GUI 的版本 GVim（GTK 的图形前端）

MacOS 的专属 UI 版本 MacVim

一个配置发布版本 SpaceVim，模仿 SpaceEmacs

### 模式

vim 有很多模式，最常用的就这三个模式：通常模式（Normal mode），插入模式（Insert mode），可视模式（Visual mode）。

EX 模式，可以当做没有，不小心进入了知道如何退出就够了。`Ctrl + v` 进入块选择模式，不知道也无所谓

> `Q` 进入 EX 模式，输入 `visual` 退出 EX 模式

![vim exit](/assets/img/work_vim_config/vim-exit.jpg)

用 vim 先从 `h j k l` 开始学习移动光标的简直是劝退向。我用了好多年 `h j k l` 都用不熟练。建议忘记 `h j k l` 的操作，方向键足够了

什么没有方向键？建议换键盘，或者让编辑器符合自己的习惯，而不是习惯工具（习惯工具建议直接上 IDE）

相比之下移动光标用比较多的是：

- `^` , `$` 跳到行开头，跳到行尾
- `A` 跳到行尾部进入插入模式
- `Crtl-f` , `Crtl-b` 向后，向前翻页
- `w` , `W` 跳一个单词，跳到下一个空格
- `:10` 跳到第 10 行
- `G`, `gg` 分别跳至文件尾部和头部

写代码用的最多的自然是 `Crtl-c` `Crtl-v`

![vim ctrl-cv](/assets/img/work_vim_config/ctrl-cv.jpg)

在 vim 里就是

- `dd` 剪贴
- `yy` 复制
- `p` 粘贴
- `10dd` 剪贴 10 行
- `4yy` 复制 4 行
- `P` 当前行前粘贴

### 插件管理器：Plug

- vundle
- vim-plug
- vim8 packadd

vundle 比较老（这个当年几乎一统江湖）不过一些插件会自带个 lib， vundle 就不太够用了，就有了 NeoBundle 来扩充这部分功能。

vim-plug 我目前用的就是这个。vim8 之后自带了包管理器 packadd（我还从来没有用过）

反正基本上都差不多，随便选就行

## 语法代码补全

你可以使用基于 LSP （Language Server protocol） 的实现。当然，也可以使用传统的补全插件。。。以 LSP 现在火的程度，大概未来都是这种插件吧

### coc.nvim

vim 下的一个 LSP  实现框架。这个稍微有点特殊，它自己带了一套插件体系和包管理。同一个插件甚至可以找到 vim 的包和 coc 的包

### tabnine

一个基于机器学习的自动补全插件。可以配合 coc 一起用 coc-tabnine

这个强力推荐，毕竟真的好用，时间使用效果也可能和使用的语言有关

很多时候我觉得不是我在写代码，而是 tabnine 在写代码。我在 review

### 各种编程语言

去找对应的 coc 的插件。或对应的 vim 插件，这里没什么值得注意的地方

一些很著名软件的配置文件语法甚至也可以找到，比如：`nginx.conf` ，`systemd` 之类的

### markdown

markdown 要预览功能，所以比较特殊一点

```vim
" markdown support
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled = 1
" markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
```

这个分成两个部分，一个是。markdown 语法部分，和 markdown 预览部分

`:MarkdownPreview` 命令就可以一边编辑，一边在浏览器里面预览了

### 风格约束

通过这三行可以把空格缩进和 tab 缩进都显示成一样的风格。嗯，我写 python 也是用两个空格的（去它 PEP8）

```vim
set tabstop=2
set softtabstop=2
set shiftwidth=2
```

但是个人风格可能和团队风格不一致。

原来写的项目都是用 `editorconfig` 来控制团队之间不同的人的代码风格

```vim
" .editorconfig
Plug 'editorconfig/editorconfig-vim'
```

## 显示相关

### Theme

这个是个老生常谈的话题，我还是偏爱 gruvbox 的主题。然后把背景设置成透明的，然后在终端上使用模糊效果

gruvbox 可以支持一些状态，比如 coc 的 `CocFloating`

```vim
Plug 'morhetz/gruvbox'

" === theme gruvbox ===
colorscheme gruvbox
" Setting dark mode
set background=dark

nnoremap <silent> [oh :call gruvbox#hls_show()<CR>
nnoremap <silent> ]oh :call gruvbox#hls_hide()<CR>
nnoremap <silent> coh :call gruvbox#hls_toggle()<CR>

nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?

" === theme gruvbox ===

" transparent background
hi Normal ctermfg=252 ctermbg=none
```

### 底部状态条 airline

![airline](/assets/img/work_vim_config/airline.png)

```vim
Plug 'vim-airline/vim-airline'
```

我觉得这东西最有用的一点就是可以看到光标坐标和文件编码。。。防止不知道哪的人丢过来个 dos 的编码的文件

### 显示行号

```vim
set number
map <silent><F4> :set relativenumber!<CR>
```

这样按 `F4` 来进行相对行号和绝对行号的切换

我是经常在决定行号和相对行好之间切换。多行删除复制是相对行号用的很多，跳转时用绝对行号

### 显示对齐线

![indent guides](/assets/img/work_vim_config/indent-guides.png)

有时写着写着容易乱，使用这个对齐线插件，默认不开启。只在需要时使用 `F7` 来开启或关闭这个功能

```vim
" indent guides
let g:indent_guides_guide_size = 1
Plug 'nathanaelkane/vim-indent-guides'
" indent guides shortcut
map <silent><F7>  <leader>ig
```

## 检索跳转

### NERDTree

显示目录树插件。没错，vim 自己是没有这个功能的，要靠插件来实现

纯粹是习惯了， `F8` 打开目录树 `Crtl-w w` 切过去，按 `m` 打开菜单

```vim
" A tree explorer plugin for vim
Plug 'preservim/nerdtree'
map <silent><F8> :NERDTree<CR>
```

### 快速搜索

先来回顾一下最普通的搜索：`/xx` 命令来搜索

这样要手动输入搜索内容才能使用，或许可以使用 Visual mode 来选择要搜索的内容

```vim
" https://blog.twofei.com/610/
" https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap // y/<c-r>"<cr>
```

在配置里加上这个：

1. 先按 `v` 进入 Visual mode
2. `//` 执行在本文里搜索选中内容

### 模糊搜索 fzf

什么？coc 不是已经有 CocList 了吗？为什么还要一个。。。

我比较懒，这个已经把我最常用的功能也做了。不用自己写了，多一个插件又不会怎么样

```vim
set rtp+=/usr/local/opt/fzf
Plug 'junegunn/fzf.vim'
map <c-o> :Buffers<CR>
map <c-p> :Files<CR>
```

`fzf.vim` 这个插件要依赖外部的 `fzf` 命令，要指定 `fzf` 的路径

在计算机术语有一个 LRU 的名词，大家还记得吗？对的，最近缓冲区列表，每次打开一个新文件就会放到缓冲区，重新打开就会移到最上方

最近文件历史切换，就是 `:Buffers` 命令可以打开这样一个文件列表

这个我用的非常多，设置 `Crtl-o` 快捷键

### 全文搜索

先从命令行工具 `grep` 开始，我们都知道，可以配合 `find` 工具来实现全文检索，但这是一个很低效的实现

一个代替 `grep` 的工具 `ripgrep` 。对就是 R.I.P. （Rest in peace） `grep`

我们可以直接使用 `Rg` 命令来全文搜索。当然，也可以配合 `fzf` 来列表选择，再装到 vim 里选择匹配项目，跳转到文件的行

这一切 `fzf.vim` 都已经帮我们做好了，直接输入 `:Rg xxx` 就可以搜索了

![vim ripgrep](/assets/img/work_vim_config/screenshot_2021-03-21_18-06-13.png)

还记得刚才是如何改造在文件中搜索的吗？把 `Rg` 也改造成快捷键，在下面添加这句

```vim
vnoremap Rg y:Rg <c-r>"<cr>
```

1. 先按 `v` 进入 Visual mode
2. `Rg` 全文搜索选中内容

### vimdiff

大家都知道 `diff` 命令。不过我们也可以使用 `vim` 的 `vimdiff` 来对比两个文件文件

`:diffsplit` 来开启对比窗口，当然我个人偏好是左右对比窗口（垂直分割），需要在配置里加上下面这行

```vim
set diffopt+=vertical
```

### 快速跳转

```vim
Plug 'Lokaltog/vim-easymotion'
```

`:make w` 把某行标记成 `w`

`'w` 跳转到 `w` 这标记的这行

### `Ctrl-6`

这个大概我用的最多的快捷键。很有趣的一点是这个是默认的快捷键。但很少有教程提到这个功能

和 Buffers 里的最上面一个文件切换

## 批量处理

### 文件批量重命名

```vim
" :Renamer
Plug 'vim-scripts/renamer.vim'
```

把文件目录当成文本文件来编辑，直接批量重命名文件

### 批量编辑

比如要一次性注释多行，在每行前面添加 `//`

1. `^` 到行首
2. `Ctrl + v` 进入块选择模式，选择多行
3. `I` 进入批量插入模式
4. 输入添加内容 `//`
5. `esc` 退出块编辑模式

### 查找替换

相信大家对 `sed` 并不陌生，这里直接在 `vim` 里使用类似的命令

`:%s/old/new/g`

当然可以使用其他的作为分隔符

`:%s#old#new#g`

### 批量删除匹配行

有些时候在查看大量日志的时候，可以直接用 vim 来处理

我们使用这个来批量删除一些无关紧要的行 `:g/text/d`

比如日志分级直接删除 debug 级的日志 `:g/[DEBUG]/d`

当然可以反过来操作，保留匹配行，按照 vim 的命名习惯 `g` 命令的相反操作就是 `g!`

`:g!/text/d`

更准确的应该是 `:v/text/d`

`g!` 其实是 `v` 命令的别名

### 自动风格处理

这个也是原本的功能，按 `v` 进入 visual 模式。多选行然后按 `=` 来自动格式化缩进。

当然，如果你是 python ，这个功能当然是残废的。这个只能处理风格，不能理解语义

### 自动移除末尾空白

我习惯在保存文件时  `:w` 来执行这个操作

```vim
" Automatically remove trailing spaces
autocmd BufWritePre * :%s/\s\+$//e
```

## 其他

### vim-leetcode

leetcode 网页那个编辑器简直难用的要死，我们可以在 vim 里面刷题

![vim-leetcode](/assets/img/work_vim_config/screenshot_2021-03-21_18-48-42.png)

### vim-rainbow-fart

还记得那个使用关键词触发语音的彩虹屁插件吗。什么？和干活没关系，这个可是可以让人码力全开的神器啊（

可以装上钉宫的语音包。[钉宫病](https://zh.moegirl.org.cn/%E9%92%89%E5%AE%AB%E7%97%85) 患者的福音。**傲 娇 钉 宫，鞭 写 鞭 骂**

> 巴嘎 变态 无路赛～～～

然后就有可能发生这种事故

{% twitter https://twitter.com/_a_wing/status/1300352161205739522 %}

## 参考文章

[(纯干活) Rails 高效开发工具 vim 指南](https://ruby-china.org/topics/19315)

[[VIM] 搜索可视化选中（Visually Selected）的文本](https://blog.twofei.com/610/)

[Search for visually selected text](https://vim.fandom.com/wiki/Search_for_visually_selected_text)
