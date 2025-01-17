---
title: conky 配置文件详解
date: 2016-01-05 03:13:46+00:00
updated: 2016-01-05 03:13:46+00:00
categories: linux
tags:
- linux
---

一个不错的conky配置文件

https://github.com/zenzire/conkyrc


在网上搜集的


Conky 是一个应用于桌面环境的系统监视软件，可以在桌面上监控系统运行状态、网络状态等一系列参数，而且可自由定制，但对于新手来说可能会比较难于上手。[2]
Conky是一种自由软件，用于X视窗系统的系统监视，可以在FreeBSD、OpenBSD和各种Linux发布上使用的自由软件。Conky具有很高的可配置性，可以监视许多系统参数，如：CPU、内存、交换内存、硬盘使用情况等状态；各种硬件的温度；系统的进程（top）；网络状态；电池电量；系统信息和邮件收发；各种音乐播放器MPD、XMMS2、BMPx、Audacious）的控制。不像其他系统监视器那样需要高级别的部件工具箱（widget toolkits）来渲染他们的信息，Conky可以直接在X视窗下渲染，这意味着在相同配置下Conky可以消耗更少的资源。用户可以自行创建和分发 Conky的自定义脚本，通常以.conkyrc命名，放在用户目录下，用户通过改变功能模块和界面来配置不同的Conky显示界面


～/.conkyrc
大家想要实现什么功能就修改这份文件就可以了。如果没有就自己创建一个
当然，默认的配置文件也不适合每个人，所以还需要进行个性化配置。不过它的配置文件初看起来非常乱，给人一种无所适从的感觉。其实Conky的配置参数并不多，只要掌握了规律还是非常容易入手的，下面分析一下：

首先，Conky的配置文件分为两个部分，第一部分对Conky的全局属性做设定，比如字体、嵌入桌面等等；第二部分是定义Conky的输出格式，也就是Conky呈现在桌面上的样式。

在全局属性的部分，重要的参数有：

1、background no：是否嵌入桌面，“no”表示不嵌入；“yes”表示嵌入。

2、out_to_console no：是否输出结果到终端，主要在判断Conky在哪里出错时使用，一般情况下为“no”即可。

3、use_xft yes：是否使用xft字体，一般为“yes”。

4、xftfont sans-serif:size=10：设置一个默认字体，在下面的样式定义段可以特别定义使用别的字体，如不特别指定，则使用默认字体；这里最好选则一个等宽中文字体，比如我这里选的就是“sans-serif”，字体大小为“10”。

5、update_interval 1：刷新时间。Conky需要每隔一段时间读取一次要监视的系统状态并把结果输出到屏幕上，设定的时间间隔越短，监控的实时性越好，但系统负担也越重；间隔时间越长则系统负担越轻，但是监控的实时性越差。我这里设定为1秒。

6、minimum_size 280 5：设定Conky的边界范围，最小宽度为280像素，最小高度为5像素，一般没有用，我这里没有使用，前面插入“#”号表示注释掉。

7、maximum_width 308：Conky边界范围最大宽度308像素，很多时候用这个参数来限制Conky的边界。

8、default_color white：设定Conky默认颜色，在样式定义中可以设定使用任何一种颜色，如果没有设置则采用缺省的颜色。这里设定缺省颜色为“white”，也可以用16位值表示的颜色值，如“#0A0F00”。

9、gap_x 10
gap_y 10：以上两条设定Conky输出范围距离屏幕边界的像素数量，最小为10像素。
alignment top_right：设定Conky输出范围在屏幕上的位置，“top_right”表示右上方，依此类推，“bottom_left”是左下角。

10、uppercase no：如果值设为“yes”则所有输出的文字都变成大写字母。

下面介绍一下输出样式定义区：

Conky样式定义的语法和编写网页有点相似，首先，以字符“TEXT”标志样式定义的开始。Conky样式的定义以行为单位，每一行对应Conky输出到屏幕时的一行。

每一行可以分为样式属性、文字和元素。其中样式属性和元素都以“$”开头，并包含在“{}”里面，“${}”应该放在应用目标的前面。

样式属性如颜色、字体大小、停靠位置等，其中，颜色的定义格式为：

${color #5000a0}

其中的16位值色可以用X中定义的颜色名称代替，如：

${color snow}

你可以在/etc/X11/rgb.txt中找到全部颜色的列表。

字体属性的定义格式如下：

${font Monospace:style=Bold:size=10}

上面三个字体属性中任何一个不设定则使用上面定义的默认值。

${alignr}表示以该参数定义的元素向右对齐，${alignl}表示左对齐，${alignc}表示居中对齐。

需要注意的是，${}中定义的颜色和字体属性将一直影响到Conky配置文件的最后，即如果你在前面定义了第一行的颜色为“white”，那么以后各行的颜色都是白色。所以原则上你需要为每一行甚至每一行的各个元素设定颜色或者字体属性。




文字即Conky显示在屏幕上的文字，它不需要特别的定义，你希望Conky显示什么文字就添加什么文字即可。

元素即呈现在屏幕上的那些进度条、你要监视的系统状态等等，格式为：

${监视目标 参数}

如果没有参数，也可以直接使用

$监视目标

的格式。

下面介绍一些常用的元素和其参数的格式：

1、time：采用strftime的参数格式，其参数有好几个，可以到这里查找适合自己的参数并布置其格式。如我这里设置为：

${color lightgrey}${font sans-serif:style=Bold:size=8}${time %b%d日 星期%a}${alignr}${time %p%l:%M:%S}

即输出字体为sans-serif、字体大小为8像素、粗体、颜色为lightgrey，依次输出月、日、星期几，后面以12小时格式输出时间并向右对齐。

2、nodename：本机在网络上的名称。
sysname：如Linux。
kernel：内核版本。
machine：硬件系统类型，如i686。

3、stippled_hr：在本行余下的空间输出虚线，多用于分隔区块。

4、uptime：系统持续运行时间。

5、cpu：CPU实时占用百分比。
cpubar：CPU占用的进度条样式。
cpugraph：CPU占用的频谱图样式。该元素可以加两个颜色值作参数，实现颜色渐变：

${cpugraph 000000 5000a0}

6、mem：内存实时占用大小。
memmax：内存总量。
memperc：内存实时占用百分比。
swap、swapmax、swapperc是虚拟内存的相应参数。

7、processes：正在运行的进程数。
running_processes：活跃的进程数。

8、addr ppp0：显示ADSL拨号建立的连接的IP地址，“addr eth0”表示显示第一块网卡的IP地址。一般的有线网卡：eth0，无线网卡：wlan0

9、offset 70：表示相对于当前位置向右偏移70像素。

10、downspeed eth0：第一块网卡下载数据的实时速度。
upspeed eth0：第一块网卡上传数据的实时速度。
downspeedgraph eth0 32,150 ff0000 0000ff：以频谱图的样式显示第一块网卡下载速度，高度为32像素，宽度为150像素，后面是两种颜色，用于渐变色。
upspeedgraph eth0 …：用法同上。

11、fs_used /home：显示挂载到/home文件夹下的硬盘分区的使用量。
fs_size /home：显示挂载到/home文件夹下的硬盘分区的总量。
fs_bar /home：以进度条样式显示挂载到/home文件夹下的硬盘分区的占用量。

12、top name 1：按CPU占用从大到小排序当前进程并显示第一个的名字。
top mem 2：按CPU占用从大到小排序当前进程并显示第二个的内存占用量。
top pid 3：按CPU占用从大到小排序当前进程并显示第三个的pid号。
top cpu 4：按CPU占用从大到小排序当前进程并显示第四个的CPU占用量。
top_mem按内存占用从大到小排序当前进程。

13、mpd_status：监视mpd的状态。
mpd_elapsed：歌曲的已播放时间。
mpd_length：当前播放歌曲的长度。
mpd_bar：当前播放歌曲的进度条。
mpd_smart：智能判断当前歌曲的输出信息，如果id3可用，则输出”歌手-歌名“的格式，如果id3不可用，则输出当前歌曲的文件名。

除mpd外，Conky支持对audacious、bmp、xmms的监视。

14、rss：订阅一个feed并显示其最新的几个条目的标题等信息。

即每隔五分钟获取该源的最新条目，并输出最新的十个条目的标题。

15、tcp_portmon：监视当前使用的端口，目前只支持IPv4。使用格式为：

tcp_portmon port_begin port_end item (index)

16、电子邮件监视：通过设置fechmail并在配置文件中加入相关参数，Conky可以实现对电子邮箱的监视，每隔一段时间fechmail会收取服务器上的邮件，Conky会监视系统中的mail管道并显示未阅读的邮件的数量。
考虑到安全性，我没有设置邮件监视，不过可以在这里找到Conky监视邮件的设置方法。

17、exec：执行一个shell命令并把结果输出到屏幕上。如，我这里使用：

${exec whoami}

输出当前用户名。

18、acpitemp：监视并输出CPU温度，摄氏温标。Conky支持很多种CPU温度监视方案。

19、diskio：监视当前硬盘读写速度。
diskiograph：以频谱形式输出硬盘读写频度，用法如cpugraph。

使Vim支持Conky配置文件的语法高亮

默认情况下，Vim不认识Conky的配置文件，使用Vim打开“.conkyrc”文件无法实现语法高亮。

首先，到这里下载Vim的Conky配置文件语法高亮插件。然后将其复制到用户主目录下的“.vim/syntax”文件夹（如果没有则新建）里。最后在 “.vim/ftdetect”文件夹里建立一个新文件，命名为“conkyrc.vim”，在里面添加如下内容：

au BufNewFile,BufRead *conkyrc set filetype=conkyrc
再打开Conky的配置文件就可以实现语法高亮了。










我的配置文件



```
e_spacer right
use_xft yes
font Microsoft YaHei:size=8
xftfont Microsoft YaHei:size=8
override_utf8_locale yes
update_interval 1
own_window yes
own_window_type desktop
own_window_transparent yes
#own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
own_window_argb_visual yes
own_window_argb_value 120
double_buffer yes
minimum_size 206 5
maximum_width 400
draw_shades yes
draw_outline no
draw_borders no
draw_graph_borders no
default_color ffffff
default_shade_color 000000
default_outline_color 000000
alignment top_right
gap_x 5
gap_y 35
cpu_avg_samples 2
uppercase no # set to yes if you want all text to be in uppercase

TEXT
${font Microsoft YaHei:style=Bold:pixelsize=22}${alignc}${time %H:%M:%S}
${font Microsoft YaHei:pixelsize=16}${alignc}${time %b%d日星期%a}${alignc}
${color #ffa200}${hr 2}
${font Microsoft YaHei:pixelsize=12}
${color #00ffcf}主机名:${color #00ffcf} $alignr$nodename
${color #00ffcf}内核: ${color #00ffcf}$alignr$kernel
${color #00ffcf}已运行时间: ${color #00ffcf}$alignr$uptime
${color #ffd700}${stippled_hr 1}
${font Microsoft YaHei:pixelsize=12}
${color #00ff1e}CPU 0: ${cpu cpu0}% $alignr$acpitemp°C(T)
${color #dcff82}${cpubar 8 cpu0}
${color #00ff1e}CPU 1: ${cpu cpu0}%
${color #dcff82}${cpubar 8 cpu0}
${color #00ff1e}CPU 2: ${cpu cpu2}%
${color #dcff82}${cpubar 8 cpu2}
${color #00ff1e}CPU 3: ${cpu cpu3}%
${color #dcff82}${cpubar 8 cpu3}
${color #00ff1e}CPU 4: ${cpu cpu4}%
${color #dcff82}${cpubar 8 cpu4}
${color #00ff1e}CPU 5: ${cpu cpu5}%
${color #dcff82}${cpubar 8 cpu5}
${color #00ff1e}CPU 6: ${cpu cpu6}%
${color #dcff82}${cpubar 8 cpu6}
${color #00ff1e}CPU 7: ${cpu cpu7}%
${color #dcff82}${cpubar 8 cpu7}

${color #00ff1e}CPU占用:$alignr CPU%


${color #ddaa00} ${top name 1}$alignr${top cpu 1}
${color lightgrey} ${top name 2}$alignr${top cpu 2}
${color lightgrey} ${top name 3}$alignr${top cpu 3}
${color #ffd700}${stippled_hr 1}$color
${font Microsoft YaHei:pixelsize=12}
${color #00ff1e}SAM: $mem $alignr${color #db7093}$memperc%
${color #78af78}${membar 8}
${color #00ff1e}SWAP: $swap $alignr ${color #db7093}$swapperc%
${color #78af78}${swapbar 8}
${color #00ff1e}内存占用: $alignr MEM%
${color #ddaa00} ${top_mem name 1}$alignr ${top_mem mem 1}
${color lightgrey} ${top_mem name 2}$alignr ${top_mem mem 2}
${color lightgrey} ${top_mem name 3}$alignr ${top_mem mem 3}
${color #ffd700}${stippled_hr 1}$color
${font Microsoft YaHei:pixelsize=12}
${color #00ff1e}硬盘读取速度:${alignr}${diskio_read}
${color #00ff1e}硬盘写入速度:${alignr}${diskio_write}
${font Microsoft YaHei:pixelsize=12}
${color #00ff1e}/ 分区: ${color}${alignr}${fs_used /}/ ${fs_size /}
${color #78af78}${fs_bar 8 /}
${color #00ff1e}/boot 分区: ${color}${alignr}${fs_used /boot}/ ${fs_size /boot}
${color #78af78}${fs_bar 8 /boot}
${color #00ff1e}/home 分区: ${color}${alignr}${fs_used /home}/ ${fs_size /home}
${color #78af78}${fs_bar 8 /home}
${color #ffd700}${stippled_hr 1}$color
${font Microsoft YaHei:pixelsize=12}
${color #00ff1e}网络 $alignr ${color #00ff1e}IP地址: ${color DDAA00}${addr eth0}
${voffset 1}${color #98c2c7} 上传: ${color #db7093}${upspeed eth0}/s ${alignr}${color #98c2c7}总共: ${color #db7093}${totalup eth0}
${voffset 1}${color #98c2c7} 下载: ${color #ddaa00}${downspeed eth0}/s ${alignr}${color #98c2c7}总共: ${color #ddaa00}${totaldown eth0}
${font Microsoft YaHei:pixelsize=12}
${color #ffa200}${hr 2}
```
