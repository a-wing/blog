---
title: "博客优化记录"
date: 2021-02-05 15:04:05 +0800
updated: 2021-02-05 15:04:05 +0800
cover: "/assets/img/improve_blog/screenshot_2021-02-05T10-36-07.103Z.png"
categories: log
tags:
- blog
- log
---

我又一次开始优化 Blog，失业之后第一件事就是优化 Blog 。可算是有时间了

仍然没有换框架和主题（缝缝补补还可以再用几年

## 服务器

备案号被撤销，我不得不从 upyun 上爬了出来

> 爬爬爬，我最会爬了

这回我整体都迁移到了 vercel 上。vercel 真好用（vercel 打钱

域名也交给国外的 dns 解析（aliyun 垃圾

## 友链也改了下规则

站点挂了就删除太绝情了。所以决定链接去掉，只留个名字

## 优化

### PageSpeed Insights

![PageSpeed Insights](/assets/img/improve_blog/screenshot_2021-02-05T10-36-07.103Z.png)

可以用这个 [pagespeed/insights](https://developers.google.com/speed/pagespeed/insights)

### Lighthouse

> Lighthouse 是一个开源的自动化工具，用于改进网络应用的质量

vercel 有 Lighthouse 集成

![vercel lighthouse](/assets/img/improve_blog/screenshot_2021-02-05T10-30-00.942Z.png)

## 最上方的图片

把 Banner 的图片去掉了，主要问题是应该固定高度，不然会有 Cumulative Layout Shift (CLS)

是的，加载中会发生页面偏移，首次渲染时并不知道图片尺寸，（先把高和宽当作 `0px` 处理）

等到图片加载完成，会引发重排（Reflow）

**这样产生的视觉效果就是页面发生偏移**，虽然可以在 css 把尺寸固定（我实在是不想这么干。。。）

干脆就别用图片了。用 css 生成个 banner

然后就在这里找了个看起来还不错的 [gradienta.io](https://gradienta.io)

## Twitter

为了和 Twitter 很好的结合，专门做了处理

可以分成两个部分：twitter 看到的你 和 你看到的 twitter （

### twitter 看到的你

你在发 twitter 带着网页的链接时，twitter 会请求这个页面生成摘要，生成一个 Card

这个 Card 是通过 [Open Graph](https://ogp.me/) 协议控制的

就像这样在 `header` 的 `mate` 标签

```html
<meta name="twitter:card" content="summary" />
<meta name="twitter:site" content="@_a_wing" />
<meta name="twitter:creator" content="@_a_wing" />
```

使用 `jekyll-seo-tag` 来生成这个标签，当然其他的社交平台也是同理

之后可以通过 Twitter 提供的开发工具验证生成的 Card

这个工具要登陆之后才能用： [cards-dev.twitter.com/validator](https://cards-dev.twitter.com/validator)

![twitter card validator](/assets/img/improve_blog/screenshot_2021-02-05T10-44-50.611Z.png)

### 在你的自己的页面上引用 Twitter

{% twitter https://twitter.com/_a_wing/status/1357651767689793536 %}

twitter 自己提供了这个工具可以随意使用，引用你想引用的任何内容

[publish.twitter.com](https://publish.twitter.com/)

直接使用他给出的结果每次都要去这个页面上

通过这个插件 `jekyll-twitter-plugin` 提供一个特殊标签，把这个流程自动化

因为模版引擎的限制，我没法在文章了写不被模版引擎解释的标签

## 图片

我都用 [tingpng](https://tinypng.com/) 压缩一遍之后再放进来，没有找到插件，可能要自己造轮子了

试过其他的图片压缩，还是这个效果最好

## 搜索功能

发现很多人都开始使用 algolia 来做站内搜索。emmmmm （我比较懒

我并没有提供站内搜索功能，因为我的全部内容都被搜索引擎索引了

你可以这样：比如要搜 debian

直接在 google 里面搜这一段 `site:a-wing.top debian`

当然可以直接点击这个：[google debian](https://lmstfy.net/?q=c2l0ZTphLXdpbmcudG9wIGRlYmlhbg==) （光速逃

## 什么？暗夜模式

这个主题没有暗夜模式。

为什么不自己写，利用 css 变量。对，你没有听错，css 是有变量的

我觉得原因大概是因为：

![sticker_sleep](/assets/img/improve_blog/sticker_sleep.jpg)

感谢评论 [百合（依云）](https://blog.lilydjwg.me/) 的推荐：[Dark Reader browser extension](https://darkreader.org/)

（可以使用这个浏览器扩展来启用本站的暗夜模式。（雾

![Dark Reader browser extension](https://darkreader.org/images/darkreader-screenshot-v5-preview.png)

## TOC (Table of Contents)

简单的说就是遍历整篇文章，然后生成一个目录

[装备篇](/equipment/) 那个目录原来是我手写的，现在是通过这个插件来自动生成

## projects 页可点击的图标

> 要不是有人说，我还真没注意到要做成可点击的

先来回答一下 [projects](projects.md) 评论提到的
[ghbtns](https://ghbtns.com/) 的问题

ghbtns 用了 `iframe`

1. iframe 会阻塞主页面的 Onload 事件
2. iframe 和主页面共享连接池，而浏览器对相同域的连接有限制，所以会影响页面的并行加载
3. 动态创建 iframe 利用 src 来进行异步加载就可以避免上面的问题

使用 iframe 并不能提高加载速度（主要是我有洁癖，一定要用 Markdown）

所以就用下面嵌套的方式：

```markdown
[![filegogo](https://img.shields.io/github/stars/a-wing/filegogo.svg?style=social&label=Star)](https://github.com/a-wing/filegogo/)
```

## 为什么没有换框架和主题

jekyll 作为静态博客的鼻祖，还是有好多值得学习的地方的。

不过我就是想吐槽新建文章，`hexo` 这点就很好，直接 `hexo new` 一个

动作     | jekyll            | hexo             | hugo
-------- | ----------------- | ---------------- | -------------------
新建站点 | `jekyll new xxx`  | `hexo init xxx`  | `hugo new site xxx`
新建文章 | 没有！！！        | `hexo new post xxx` | `hugo new posts/xxx.md`

是的，jekyll 没有这个命令，所以只能自己动手，写个小脚本去生成

对了，ruby 的 bundle 还有一个问题。`bundle` 原本叫 `bundler`

bundle 这个包 [gems/bundle](https://rubygems.org/gems/bundle)

`bundle` 去调用 `bundler`（这个太令人反感了

`bundler 2.x` 天天给你 `1.x` 错误。（看隔壁 `npm` 这么火不是没有道理的

虽然可以用这样一条命令去解决 `bundle update --bundler && bundle install`

![草](/assets/img/jenkins_and_kubernetes/sticker_cao.jpg)

bundle 还有个自动调用 `sudo` 的毛病，如果你的 `sudo` 没有密码。（会让包管理混乱的

用这条命令在项目目录下建立配置文件 `.bundle/config`

```bash
bundler config --local path vendor/bundle
```

这样之后就和 `npm` 一样了。把包安装到项目目录下

## 我是真的想换 hexo 了

