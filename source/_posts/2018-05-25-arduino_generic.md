---
layout: post
title:  "在 Arduino 里使用泛型"
author: metal A-wing
date:   2018-05-25 17:00:00 +0800
comments: true
categories: mcu
---

首先要知道 Arduino 自己的 `.ino` 的封装是不支持泛型的

然后要知道我 `C++` 写的很少

这个问题折磨了我几天，感谢 `caoxm-me` 大佬的帮助

AVR 的编译器本身是支持的。arduino 本身的封装不支持（屎一样的封装，反正我基本上不会再用arduino 来做东西了）

非常关键的一点：一定要写在两个文件中

`add.cpp`
```c++
template <typename T>
T add(T a,T b)
{
 return a+b;
}
```

`add.ino`
```c++

#include "add.cpp"

void setup() {
}
void loop() {
    int num1, num2, sum;
    sum=add(num1,num2);
}
```

