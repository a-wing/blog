---
layout: post
title:  "在 Python 里使用 method_missing 方法"
author: metal A-wing
date:   2018-10-04 17:00:00 +0800
comments: true
categories: python
---
我不喜欢 python ，但又不得不写 python 。
在 ruby 里 method_missing 我几乎天天用（

首先，要知道动态派发：

简单的说就是通过字符串来调用函数


```python
# python 有两种写法

eval(func_name)()

getattr(obj, func_name)()
```
反正尽量不要用 `eval` 方法


因为是通过字符串来调用方法，会有一直非常常见的问题，当调用的方法不存在（比如写错了，读字符串是发生错误）。。。enen 就挂掉了

python 提供了一种叫 `__getattr__` 的 钩子函数。（访问一个不存在的属性时调用）

不过 python 有个问题

> There is no difference in Python between properties and methods. A method is just a property, whose type is just instancemethod, that happens to be callable (supports __call__).
>
> If you want to implement this, your __getattr__ method should return a function (a lambda or a regular def, whatever suite your needs) and maybe check something after the call.

`properties` 和 `methods` 其实是不同的。。。`__getattr__` 本来是属性不存在是调用，方法写可以当作属性。

getattr 是返回属性的值

getattr 方法也可以返回一个 lambda ， （那个属性可以等于 lambda ）

`getattr(obj, func_name)()` 可以分成两部，`getattr(obj, func_name)` 是获取了那个属性。 `()` 是调用这个 lambda

python 的函数名都是变量，储存函数的地址，`()` 是调用这个函数的
```python
def aa():
  print("233")

print(aa)
# => <function aa at 0x7f668c4160d0>

bb = lambda :print("456")

print(bb)
# => <function <lambda> at 0x7f668c387b70>
```

原理是这样。。。然后上段代码

```python
from functools import partial

class MethodMissing:
  def method_missing(self, name, *args, **kwargs):
    '''please implement'''
    raise NotImplementedError('please implement a "method_missing" method')

  def __getattr__(self, name):
    return partial(self.method_missing, name)

class Command(MethodMissing):
  def aaa(self):
    print("23333333333")
    return { 'code': 0, 'status': 'done' }

  def method_missing(self, name, *args, **kwargs):
    return { 'code': 1, 'msg': "No " + name + " method" }
```

我觉得不用解释了（

本人水平有限。。python 写的少。。如有更好的办法请指出（


参考资料：

http://caiknife.github.io/blog/2013/08/15/dynamic-method/

https://pycoders-weekly-chinese.readthedocs.io/en/latest/issue6/a-guide-to-pythons-magic-methods.html

https://stackoverflow.com/questions/6704151/python-equivalent-of-rubys-method-missing

https://gist.github.com/gterzian/6400170

