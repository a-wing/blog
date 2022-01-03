---
layout: post
title: "[译] Arch Linux 上的完整 Wayland 设置"
author: "Metal A-wing"
date: 2022-01-03 16:00:00 +0800
toc: true
image: "/assets/img/translate_wayland/wofi.jpg"
banner: "/assets/img/2021/changbaishan/img_3151.jpg"
categories: linux
---

本文是一份在 Arch Linux 上实现完整的 Wayland 设置的指南。

原文：[Full Wayland Setup on Arch Linux](https://www.fosskers.ca/en/blog/wayland)

如果你遵循整个指南，到最后你将拥有：

- [Sway](https://swaywm.org/) 一个平铺式窗口管理器。
- [Waybar](https://github.com/Alexays/Waybar) 一个与 [Polybar](https://github.com/polybar/polybar) 非常相似的状态条。
- [Wofi](https://hg.sr.ht/~scoopta/wofi) 一个纯 GTK（也就是 Wayland）的可定制应用程序启动器。
- [Alacritty](https://github.com/alacritty/alacritty) 一个现代化的终端，"又不是不能用"。
- Wayland 中的 Firefox 和 Chromium，可以进行屏幕共享。
- `Emacs` 通过全新的纯 GTK 内部结构在 Wayland 中完全运行。
- 大多数 QT 应用程序在 Wayland 中运行。
- 如果可以的话，将 Steam 游戏设置为考虑 Wayland。
- (可选）通过 Fcitx5 的日语输入。

你还将学习如何确认一个应用程序是否在 `Wayland` 中运行，并了解 `XWayland` 和那些仍然需要它才能正常运行的主要程序。
虽然本指南是以 Arch Linux 为基础编写的，但它应该可以适应你所运行的任何的 Linux 发行版。好好享受吧，祝你好运!

**注意：在继续之前，你可能希望在手机或第二台电脑上打开本指南，因为我们需要在整个过程中多次重启你的窗口管理器。**

## 开始之前：Wayland? XWayland?

Wayland 是 Linux 的下一代显示协议。你可能听说过 `X`（或 `X11` 或 `XOrg`），但你可能不知道它的问题：年龄、性能、安全性和开发友好性。

甚至 Adam Jackson（X 的长期发布和管理者），也 [呼吁采用 Wayland](https://ajaxnwnk.blogspot.com/2020/10/on-abandoning-x-server.html)。
不过，`X` 已经很成熟了，过渡不会在一夜之间发生。Linux 系统中的许多核心应用都与它的生态系统紧密相连。

```bash
> pacman -Qg xorg | wc -l
38
```

你可能会惊讶地发现，你几乎肯定已经安装了 `wayland`

```bash
> pacman -Qi wayland
Name            : wayland
Version         : 1.19.0-1
Description     : A computer display server protocol
Architecture    : x86_64
URL             : https://wayland.freedesktop.org/
Licenses        : MIT
# ... etc.
```

幸运的是，Linux 生态系统向 Wayland 的过渡在这些年里一直在 [稳步向前推进](https://arewewaylandyet.com/)。
主要的 GUI 框架如 GTK 和 QT 完全支持它。
[Ubuntu 21.04 将默认使用 Wayland 运行](https://www.omgubuntu.co.uk/2021/01/ubuntu-21-04-will-use-wayland-by-default)。
但我们可以不需要等待主要发行版的行动：今天就可以直接使用 Wayland。

你应该知道，有一些主要的应用程序并不（或不会 [或不能](https://github.com/xmonad/xmonad/issues/38)）支持 Wayland。
像这样的程序仍然可以通过一个名为 `XWayland` 的独立的 `X` 实例在 Wayland 环境中运行。
这意味着向 Wayland 的过渡可以是渐进的：你不会无法使用旧的应用程序。

> 译者注：
>
> `XWayland` 本质上时 XOrg 的一个 Fork，可以在 Wayland 环境中使用 XOrg

在我们继续之前，还有一个好消息：
在 Wayland 中，你不需要像 [picom](https://github.com/yshui/picom) 或 [compiz](https://github.com/yshui/picom) 这样独立于窗口管理器的合成器程序。

> 解释一下？更少的活动组件，更少的配置管理，就可以实现终端透明化

## 前提条件

### 软件包

在 Arch Linux 上，运行下面的命令来安装本指南主要部分和 Wayland 兼容性所需的环境。

```bash
sudo pacman -S \
  sway alacritty waybar wofi \
  xorg-xwayland xorg-xlsclients qt5-wayland glfw-wayland
```

`qt5-wayland` 和 `glfw-wayland` 分别为 QT5 和 [GLFW](https://www.glfw.org/) 提供 Wayland 兼容 API 。
`xlsclients` 在下文中解释。

### 用 `xlsclients` 检测 XWayland

要获得当前通过 XWayland 运行的所有窗口的列表，请使用 `xlsclients`：

```bash
> xlsclients
archlinux  discord
archlinux  krita
archlinux  steam
```

这样，你就可以用各种应用程序快速测试你的 Wayland 配置。

## Sway

Sway 是一个平铺式窗口管理器，是一个在 Wayland 环境下 [i3](https://i3wm.org/) 的替代品。
和它的 i3 一样，它也是用 C 语言编写的，因此速度非常快，资源开销也很小。
尽管 Sway 可以按原样读取 i3 的配置（即你的 `/home/you/.config/i3/config`），但我建议从一个默认配置开始，然后在你需要时复制特定的绑定。

首先，复制 Sway 的配置模板。

```bash
cd ~/.config
mkdir sway
cd sway
cp /etc/sway/config .
```

现在退出你所处的任何 桌面环境（DE） / 窗口管理器（WM），并回到你的基本登录终端。在这里，运行 `sway`，Sway 就会启动。恭喜你，你正在运行 Wayland!

好了，我们不要庆祝的太早。你可能已经习惯了在 `.xinitrc` 中加入 `exec i3` 这样的行，然后用 `startx` 启动 X。现在不一样了!
从这里开始，一切都发生在我们的 Sway 配置中。说到这，下面是一些重点。

### Sway 配置和附加功能

[这里是我的全部 Sway 配置](https://github.com/fosskers/dotfiles/blob/master/.config/sway/config)。
其他方面，Sway 主要的文档是在它的 man pages 中记录的。如果有疑问，请先查看它们。
如果不行，你也可以参考 [Sway Wiki](https://github.com/swaywm/sway/wiki)。

这里有一些有用的绑定，你马上就会需要，但以后可以自由改变。

- 重新加载 Sway。`Super+Shift+c` (不会关闭正在运行的程序)
- 退出 Sway。`Super+Shift+e`
- 打开一个终端。`Super+Return`
- 打开一个程序。`Super+d`

#### 显示器设置

我有两台显示器：我的笔记本电脑在我的左边，而我主显示器在我的正前方。要让我的鼠标在显示器边界上自然移动，需要做以下工作。

```config
output eDP-1 mode 2560x1440 position 0,0 scale 2
output HDMI-A-2 mode 1920x1080 position 1280,0
```

在确定第二个显示器（第二行中的 `1280`）使用的适当偏移量时，涉及到一些数学问题。更多信息见 `man sway-output`。
你可以使用 `swaymsg -t get_outputs` 来查看你所有显示器的正式名称和可用分辨率。

#### Gaps

i3-gaps 是一个流行的 i3 变种，允许窗口之间有间隙。幸运的是，这个功能已经包含在 Sway 中，可以通过在你的 Sway 配置中添加以下内容来激活。

```bash
# A 10-pixel border around every window.
gaps inner 10

# Removes the title bar of each window.
default_border pixel 3
```

你需要退出 Sway 一次，然后从你的登录终端重新运行它，这样的改变才会生效。

#### 随机壁纸

虽然还没有整合到我自己的配置中，但 [setwall](https://github.com/fosskers/rs-setwall) 可以用来设置一个随机的背景图片。

```config
setwall random ~/Pictures/backgrounds/ -c sway
```

> 译者注：
>
> `setwall` 是这篇文章的原作者自己写的工具

### Alacritty

Alacritty 是一个强大的现代终端模拟器，具有理想的默认值。当用 `Super+Return` 打开一个新的终端时，它也是 Sway 的默认快捷键。
我使用 `urxvt` 多年，但最近切换到 Alacritty 后，我遇到的一些问题就消失了。

我对 Alacritty 的默认配置的唯一改变是背景的不透明度。在 `/home/you/.config/alacritty/alacritty.yml` 中。

```config
background_opacity: 0.8
```

看, 透明的终端!

> 译者注： 新版本的 Alacritty 推荐设置
>
> ```config
> window:
>   opacity: 0.8
> ```

### Waybar

Sway 的默认状态栏很好，但 Waybar 提供了更多的自定义功能。它还能在多个显示器上 "正常工作"，而不像 Polybar 那样需要自定义脚本。

要使用 Waybar 而不是默认 `bar` ，请注释掉你的 Sway 配置中靠近结尾的 `bar` 部分，并在其位置上添加以下内容。

```config
bar {
  swaybar_command waybar
}
```

[Waybar Wiki](https://github.com/Alexays/Waybar/wiki/Examples) 有很多配置的例子，
[这里是我自己的配置](https://github.com/fosskers/dotfiles/blob/master/.config/waybar/config)，
以及 [自定义的 CSS 样式](https://github.com/fosskers/dotfiles/blob/master/.config/waybar/style.css)。
bar 本身是透明的，右上方的小部件和托盘看起来像这样。

![waybar-top-right](/assets/img/translate_wayland/waybar-top-right.png)

在调整了你的 Waybar 配置后，像往常一样通过 `Super+Shift+c` 刷新 Sway，就可以刷新你的 Waybar 了。

### Wofi

默认情况下，Sway 使用 `dmenu` 来打开程序，但令人惊讶的是，它的用户界面在 XWayland 中运行。
有 [许多可用的替代品](https://github.com/swaywm/sway/wiki/i3-Migration-Guide)，我选择了 [Wofi](https://hg.sr.ht/~scoopta/wofi)。

![wofi](/assets/img/translate_wayland/wofi.jpg)

这是 [我设置的外观](https://github.com/fosskers/dotfiles/blob/master/.config/wofi/style.css)，
但由于它都是 CSS，所以你可以 [自由地进行试验!](https://cloudninja.pw/docs/wofi.html)

请注意，你需要在你的 Sway 配置中加入以下内容。

```config
set $menu wofi --show=drun --lines=5 --prompt=""
```

这有几种不同的提示模式。
`drun` 只匹配并显示那些在你的机器上有 `Desktop` 条目的程序（就是有 `.desktop` 文件的程序），而不是你的 `PATH` 上的所有程序。
事实上，不这样做会产生性能问题，是一个已知的问题。

## 主要的应用程序

大多数应用程序，如果在 GTK 或 QT 上运行，都有自动的 Wayland 支持，不需要进一步配置。一些特定的程序需要进行调整，我们将在下面讨论。

目前有一些资源要求你需要设置 GTK 和 QT 的特定环境变量才能使用 Wayland，但 **我发现这不是真的**。

### Firefox

在 Firefox 的 `about:support` 页面上有一个名为 *Window Protocol* 的字段，告诉我们它是通过哪个协议运行的。
如果还在 X11 上，这个字段就会显示 `X11`。如果通过 Sway 而没有下面的调整，你应该看到 `xwayland`。
用 `xlsclients` 进行的快速测试也会发现，Firefox 还没有通过 Wayland 原生运行。让我们来解决这个问题。

将 `MOZ_ENABLE_WAYLAND` 环境变量设为 `1` ，我在我的 Fish 配置中设置了以下内容（其他 shell 的用户也需要类似的内容）。

```fish
set -x MOZ_ENABLE_WAYLAND 1
```

**退出 Sway 并完全注销一次。** 一旦重新登录并重新打开 Sway，这个变量的变化应该已经传播到了所有重要的地方。
现在，如果你通过 Wofi 再次打开 Firefox，并检查 `about:support`，你应该发现。

![firefox-wayland](/assets/img/translate_wayland/firefox-wayland.png)

### Chromium

Chromium 的转换要简单一些。在 `/home/you/.config/chromium-flags.conf` 中，添加以下几行。

```conf
--enable-features=UseOzonePlatform
--ozone-platform=wayland
```

重新启动 Chromium，这样就可以了。你可以用 `xlsclients` 来确认。

### Emacs

是的，Emacs 可以纯粹地在 Wayland 中运行。你们中的一些人可能会说。

> 但是 Emacs 并不是一个真正的 GTK 应用程序!

是的，这曾经是真的。[从 2021 年初开始](https://lwn.net/Articles/843896/)，Emacs 可以用 "纯 GTK" 的内部结构构建，使其完全兼容 Wayland。
这项功能将在 Emacs 28 中实现（截至本文撰写时尚未发布），但幸运的是，
[有一个 AUR 包](https://aur.archlinux.org/packages/emacs-gcc-wayland-devel-bin/) 可以跟踪 Wayland 开发分支，并提供一个预构建的二进制文件。
我们可以用 [AURA](https://github.com/fosskers/aura) 这样的工具来安装它。

> 译者注：
>
> AURA 也是这篇文章的原作者写的，中文社区的用户可能更习惯使用 `yay`

```bash
sudo aura -Axa emacs-gcc-wayland-devel-bin
```

注意，这个软件包 `Provides: emacs`，所以它将取代你所安装的任何其他 Emacs 软件包。

### Steam and Gaming

像 *Among Us* 这样的 [Proton games](https://www.protondb.com/) 可以按原样运行，
因为它们在高度修改的 Wine/dependency 环境中运行，而这种环境对每个游戏都是已知的。
*Among Us* 对 Sway 中的窗口大小调整和重新定位反应良好。

对于像 *Half-life* (old)、 *Trine 2* (graphics heavy) 和 *Tabletop Simulator*（modern toolchain）这样的原生游戏，
我不得不将环境变量 `SDL_VIDEODRIVER` 设为 `x11`。否则它们就不能正常启动。

来自 Arch Wiki：

> 注意: 许多专有游戏都捆绑了旧版本的 SDL，它们不支持 Wayland，如果你设置 `SDL_VIDEODRIVER=wayland`，可能会完全崩溃。

甚至 *Stellaris* 也需要 x11 才能工作。

如果你不想把所有 SDL 的使用强制到 X11，你也不必这样做。Steam 允许我们为每个游戏设置特定的环境变量。
要设置这个，右键单击一个游戏，并访问其 `Properties`。在 `GENERAL > LAUNCH OPTIONS` 中，输入以下内容，你的游戏应该可以运行了。

![steam-sdl-override](/assets/img/translate_wayland/steam-sdl-override.png)

所以重申一下，这里是我在 `Fish` 中设置的环境变量。

```fish
set -x SDL_VIDEODRIVER 'wayland'
```

而我在 Steam 中根据具体情况将其覆盖为 `x11`。

### Signal

在 2021 年 5 月初，Signal 发布了 `5.1.0` 版本，该版本使用与 Wayland 兼容的 Electron。
不幸的是，Arch 软件包 `signal-desktop` 还没有默认在这种模式下运行，所以手动激活是必要的。在命令行中。

```bash
signal-desktop --use-tray-icon --enable-features=UseOzonePlatform --ozon-platform=wayland
```

或者如果你通过启动器运行 Signal，我们可以编辑软件包提供的 `.desktop` 文件来尊重这些选项。
在 `/usr/share/applications/signal-desktop.desktop` 中，修改 `Exec` 一行，使其成为以下内容。

```desktop
Exec=signal-desktop --use-tray-icon --enable-features=UseOzonePlatform --ozone-platform=wayland -- %u
```

类似的策略也适用于其他至少使用 12 版的 Electron 应用程序。

## Other Settings

如果这里的章节对你不适用，请随意跳过。

### Keyboard Layouts

我在打字时使用 Colemak 布局，所以我在我的 Sway 配置里有以下内容。

```config
input * {
  xkb_layout "us"
  xkb_variant "colemak"
}
```

不幸的是，似乎有 [一个奇怪的 Bug](https://github.com/swaywm/sway/issues/4664)，在某些窗口中布局会突然切换回 qwerty。
我注意到以下症状：当一个终端被打开时，最左边的 XWayland 窗口会切换回 qwerty。
我发现有两个办法可以解决这个问题。

- 尽可能多地使用纯 Wayland 应用程序，或者。
- 安装一个IME（Input Method Editor），例如用于输入 non-ASCII 语言（见下文）。

### 日语输入法

Sway 已经非常接近对切换输入法的一流支持（见
[Sway#4740](https://github.com/swaywm/sway/pull/4740#issuecomment-787578644)、
[Sway#5890](https://github.com/swaywm/sway/pull/5890)
和 [Sway#4932](https://github.com/swaywm/sway/pull/4932)）。
目前，这里有一个通过 `dbus` 工作的设置，允许我们在 **除 Alacritty** 之外的所有 Wayland 和 XWayland 窗口中改变方法和输入日文。

首先，安装这些软件包。

```bash
sudo pacman -S fcitx5 fcitx5-configtool \
  fcitx5-gtk fcitx5-mozc fcitx5-qt
```

然后在 `/etc/environment` 中添加以下内容：

```bash
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

然后把这个放到你的 Sway 配置中：

```config
exec_always fcitx5 -d --replace
```

**现在重新启动你的电脑。**

希望你现在能在你的 Waybar 托盘中看到一个键盘图标。要配置 `fcitx5`，请打开 `fcitx5-configtool`。这是我的设置。

![fcitx5](/assets/img/translate_wayland/fcitx5.png)

你会看到，我特别将我的英文键盘设置为 Colemak，并从右边的列表中添加了 `Mozc`。
勾选 `Global Options` 标签，设置你的方法切换键绑定。
之后，点击 `Apply`，你现在应该可以切换输入法并输入日语了。
如果键盘绑定不起作用，你也可以通过点击 Waybar 托盘上的图标来切换方法。

> 译者注：
>
> 对于中文用户，就是把 `Mozc` 换成 `Rime`

### 屏幕共享

在 Firefox 和 Chromium 中，通过 Pipewire 和一些辅助包可以实现屏幕共享，尽管目前我们只能共享整个屏幕，而不是单个窗口。要继续进行，首先安装以下软件包。

```bash
sudo pacman -S xdg-desktop-portal-wlr libpipewire02
```

后者只对 Chromium 是必要的。 **现在重新启动你的电脑。**

让我们先用 Mozilla 的 [gum test page](https://mozilla.github.io/webrtc-landing/gum_test.html) 测试一下 Firefox。
当浏览器提示你选择窗口时，选择 *Use operating system settings:*

![firefox-screen-select](/assets/img/translate_wayland/firefox-screen-select.jpg)

你会注意到你的光标发生了变化；`xdg-desktop-portal-wlr` 正在期待你选择一个显示器来共享。点击一个，屏幕共享应该开始。

对于 Chromium，我们需要激活一个功能标志，让 Chromium 与 Pipewire 对话。
首先访问 `chrome://flags`，然后找到并启用 `WebRTC PipeWire support`。这就是了!

如果你在使用这些浏览器时遇到问题，请查看 [XDPW FAQ](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ)。

## XWayland 和不兼容

您还知道其他不兼容的情况吗？请让我知道。

### Krita

数字艺术程序 [Krita](https://krita.org/) 是一个在 QT5 中运行的很棒的应用程序，但由于某些硬件支持不成熟的原因（对于手写板等），
[它不支持 Wayland](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=955730)，因此总是在 XWayland 中运行。

### Electron Apps

从 2021 年 5 月起，由于 Signal 和 VSCode 升级到 Electron 12，它们现在可以在 Wayland 中运行。

而其他 Electron Apps，如 Discord 和 Slack，则必须在 XWayland 中运行，直到他们能够升级。

## 社区提示

### KWin 用户

感谢 **flying-sheep** 提供的这个提示。

> 对于使用 KWin 的人来说：你可以显示一个窗口，帮助你使用识别 XWayland 窗口。

```bash
qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole
```

### Polkit

感谢 Aaron Wiedemer 提出的以下建议。

> 一些应用程序有时需要权限，例如，软件管理器需要权限来启动更新，但只是搜索软件包不需要额外权限。
> 这些应用程序会弹出一个小盒子，要求输入密码。这需要一个不由 sway 启动的守护程序，所以我们需要用我们的 sway 配置自动启动一个。

[Polkit 客户端有很多选择](https://wiki.archlinux.org/title/Polkit)。
例如，`polkit-gnome` 没有依赖性，可以通过以下方式在 `sway` 中启动：

```config
exec_always /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
```

## Resources

- [Sway: Running GUI Programs under Wayland](https://github.com/swaywm/sway/wiki/Running-programs-natively-under-wayland)
- [Sway: i3 Migration Guide](https://github.com/swaywm/sway/wiki/i3-Migration-Guide)
- [Sway: Waybar](https://github.com/Alexays/Waybar)
- [Sway: Wofi launcher](https://hg.sr.ht/~scoopta/wofi)
- [Arch Wiki: Wayland](https://wiki.archlinux.org/index.php/Wayland)
- [Are We Wayland Yet?](https://arewewaylandyet.com/)
- [Blog: Zoom Screen Sharing](https://hugo.barrera.io/journal/2020/06/14/zoom-screensharing-on-archlinux/)

