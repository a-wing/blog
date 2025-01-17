---
title:  "Ruby 元编程索引"
date:   2018-09-05 17:00:00 +0800
updated:   2018-09-05 17:00:00 +0800
categories: ruby
tags:
- ruby
---

大概会持续更新吧。。。。


- 打开类 Open Class
- 猴子补丁 Monkeypatch
- 接受者（receiver）和祖先链（ancestors chain）eg: 查看String 类的祖先连 String.ancestors
- [一些重要的钩子方法](https://ruby-china.org/topics/25397)
  - included
  - extended
  - prepended
  - inherited
  - method_missing (幽灵方法): 当接受的反方法不存在时会调用这个方法，配合 `*arg`可以接受任意个数的参数
  ```ruby
    def method_missing(method, *args)
      "The method #{method} with you call not exists"
    end
  ```
- [send 方法 （动态派发）](https://ruby-china.org/topics/4313)
  - send (Obj.send(:define_method, 'desc'))
  - public_send
- [动态方法 define_method](https://www.jianshu.com/p/349ecf5c503e)
- instance_eval 方法仅仅会修改 self，而 class_eval 方法会同时修改 self 和当前类
- const_missing
- define_const
- 白板类 BasicObject

- eval, instance_eval, module_eval, class_eval

- [attr_accessor](https://kaochenlong.com/2015/03/21/attr_accessor/)
  - attr_reader (getter)
  - attr_writer (setter)

- [block, proc 和 lambda ](https://ruby-china.org/topics/10414)

- define_method 添加类的实例方法 `A.send(:define_method, :hi, &p1)` 等于 `Class A; define_method, :hi, &p1; end`
- singleton_class 添加类所具有的方法 `A.singleton_class.send(:define_method, :hi, &p1)` 等于 `Class A; self.define_method, :hi, &p1; end`


