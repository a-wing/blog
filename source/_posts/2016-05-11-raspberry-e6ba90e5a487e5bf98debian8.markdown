---
author: shiyongxin
comments: true
date: 2016-05-11 14:13:46+00:00
layout: post
link: http://a-wing.top/raspberry-%e6%ba%90%e5%a4%87%e5%bf%98debian8/
slug: raspberry-%e6%ba%90%e5%a4%87%e5%bf%98debian8
title: raspberry 源备忘debian8
wordpress_id: 70
categories:
- raspberry
---

USTC 科大原本的源

    
    deb http://mirrors.ustc.edu.cn/raspbian/raspbian/ wheezy main non-free contrib
    deb-src http://mirrors.ustc.edu.cn/raspbian/raspbian/ wheezy main non-free contrib


改成

    
    deb http://mirrors.ustc.edu.cn/raspbian/raspbian/ jessie main non-free contrib
    deb-src http://mirrors.ustc.edu.cn/raspbian/raspbian/ jessie main non-free contrib
