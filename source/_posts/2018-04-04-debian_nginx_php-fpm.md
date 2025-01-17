---
title:  "约定大于规则：优雅的在debian 上配置nginx 和 php-fpm"
date:   2018-04-04 15:00:00 +0800
updated:   2018-04-04 15:00:00 +0800
categories: linux
tags:
- linux
- debian
- nginx
- php
---

本文只给对技术有追求的人看：少配置多用默认值。为什么要写这个，那天要查文档的时候看到文档都是一律编译安装的。。感觉好气愤。你们懂Linux吗？

ngnix php-fpm 之间可以通过Unix socket 来通信。所以php-fpm 可以不用监听端口

php-fpm 是 php 进程管理器，属于运行环境，可以直接对外，一般都在前面放nginx

使用版本：
- debian 9
- nginx 1.10.3
- php 7.0


```sh
apt install ngnix php-fpm
```

软件源里的php-fpm 默认不用配置

默认用`/run/php/php7.0-fpm.sock`

配置文件在

```sh
/etc/php/7.0/fpm/php-fpm.conf
```

不过可能要手动启动
```sh
sudo systemctl start php7.0-fpm.service
```


然后nginx 的站点配置文件
```sh
sudo sh -c 'cat > /etc/nginx/sites-available/test << "EOF"
server {
    listen 80;

    # 你的域名
    server_name a-wing.top;

    # 站点路径
    root /var/www/html/;

    # 入口文件
    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri =404;

        include fastcgi.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF'
```

建立软链接
```sh
sudo ln -s /etc/nginx/sites-available/test /etc/nginx/sites-enabled/
```
> 默认站点配置文件放在 sites-available/
>
> 启用的站点请建立软连接到 sites-enabled/


检查并重新载入nginx 配置
```sh
# 检查配置文件
nginx -t

# 重新载入配置文件（这个可以不用重启nginx）
nginx -s reload
```

