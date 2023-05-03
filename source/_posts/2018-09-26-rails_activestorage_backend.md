---
layout: post
title:  "一篇超水的 Rails ActiveStorage 源码解读（后端部分）"
author: metal A-wing
date:   2018-09-26 17:00:00 +0800
comments: true
categories: ruby
---

ActiveStorage 是 Rails 5.2 的一个新特性 ，建议你先去读完官方的文档再回看来这个

[https://guides.rubyonrails.org/active_storage_overview.html](https://guides.rubyonrails.org/active_storage_overview.html)


```
▾ activestorage-5.2.1/
  ▾ app/
    ▸ assets/javascripts/
    ▾ controllers/
      ▸ active_storage/
      ▸ concerns/active_storage/
    ▸ javascript/activestorage/
    ▾ jobs/active_storage/
        analyze_job.rb
        base_job.rb
        purge_job.rb
    ▾ models/active_storage/
      ▾ blob/
          analyzable.rb
          identifiable.rb
          representable.rb
      ▸ filename/
        attachment.rb
        blob.rb
        current.rb
        filename.rb
        preview.rb
        variant.rb
        variation.rb
  ▾ config/
      routes.rb
  ▾ db/migrate/
      20170806125915_create_active_storage_tables.rb
  ▾ lib/
    ▾ active_storage/
      ▾ analyzer/
          image_analyzer.rb
          null_analyzer.rb
          video_analyzer.rb
      ▾ attached/
          macros.rb
          many.rb
          one.rb
      ▾ previewer/
          mupdf_previewer.rb
          poppler_pdf_previewer.rb
          video_previewer.rb
      ▾ service/
          azure_storage_service.rb
          configurator.rb
          disk_service.rb
          gcs_service.rb
          mirror_service.rb
          s3_service.rb
        analyzer.rb
        attached.rb
        downloading.rb
        engine.rb
        errors.rb
        gem_version.rb
        log_subscriber.rb
        previewer.rb
        service.rb
        version.rb
    ▾ tasks/
        activestorage.rake
      active_storage.rb
    CHANGELOG.md
    MIT-LICENSE
    README.md
```

## 数据结构

先看 `db/migrate/20170806125915_create_active_storage_tables.rb`

我们能看到两张表，其中一张表储存的是文件信息。。en，en 文件的基本信息

另一张表是储存文件的对象信息

#### active_storage_blobs
这个表储存了所有文件的基本信息，我们可以看到这个表只有 `created_at` ，因为这张表被设计成只能添加和删除。

`key` 是文件唯一的索引。 `Disk service` 默认把文件放在 storage 目录下，然后建立了以`key`值开头两位命名的两个目录。。。。有点绕）

就像这样，来解决大量文件的查找问题：`storage/qS/gY/qSgYgMNvwQNzpvBsx91QHQwW`

```sql
rsd_development=# SELECT * FROM active_storage_blobs;                                                                                                                                                                                         
 id |           key            |  filename  |       content_type       |              metadata               | byte_size |         checksum         |         created_at                                                                      
----+--------------------------+------------+--------------------------+-------------------------------------+-----------+--------------------------+----------------------------                                                             
  4 | mjqZCsJTxwiaiPGzNUraGJ1o | a2         | application/octet-stream | {"identified":true,"analyzed":true} |         5 | vM3NT8ob8+i6vRUFujxB1g== | 2018-09-18 06:27:57.738182                                                           
 10 | gx855a8F8TqQgk53tPGAdyN1 | 1536642794 | application/octet-stream | {"identified":true,"analyzed":true} |      1412 | 7JRyTuP0rvD28H0ydVwfWg== | 2018-09-20 07:08:49.485237                                                              
 11 | qSgYgMNvwQNzpvBsx91QHQwW | a2         | application/octet-stream | {"identified":true,"analyzed":true} |         5 | vM3NT8ob8+i6vRUFujxB1g== | 2018-09-20 10:08:36.673785                                                              
 13 | gEVVuvBmrYE6CKCYePMATUv9 | version    | application/octet-stream | {"identified":true,"analyzed":true} |         6 | 7nv1yrmgG0DBXNusnpSfWA== | 2018-09-25 07:52:44.81699
```

#### active_storage_attachments

```sql
rsd_development=# SELECT * FROM active_storage_attachments;
 id | name | record_type | record_id | blob_id |         created_at
----+------+-------------+-----------+---------+----------------------------
  4 | file | Plan        |         3 |       4 | 2018-09-18 06:27:57.742653
 11 | file | Plan        |         2 |      10 | 2018-09-20 07:08:49.489101
 12 | file | Plan        |         1 |      11 | 2018-09-20 10:08:36.677669
 14 | map  | MissionLog  |         1 |      13 | 2018-09-25 07:52:44.820024
```
这张表是通过`对象名`和`属性名`和`对象id`来绑定文件的。。。如果你改了。类名。。那就呵呵了

不同的`attachments`是可以指定同一个`blobs`的，但是更新`blobs`只有一个会更新（应该是删了重建）。。。

**这里应该算个坑** `blobs`在删除时并不会检测`attachments`里是否有包含这个`blobs`(我不知道他为什么这么实现啊。喵) 咱觉得这应该算 bug。。。或者每次检查开销太大？留给开发者自己解决？

## 云存储 `lib/active_storage/service/`
这里面除了 `local` 和 `mirrors` 默认还集成了 Amazon S3 Service， Microsoft Azure Storage Service，Google Cloud Storage Service 服务，当然还要引入对应的SDK

active_storage 和 active_job 一样，只是提供一个中间层。具体还要引入对应云服务的sdk

大概是这样：
active_storage -> active_storage_<XXX>云服务 ->  <XXX>云服务SDK

国内的可以用 upyun， qiniu, aliyun 都有 gem 可以直接用

## attached 附件
这里面有三个文件，有个叫`macros` 值得一看，在注释里说了关于 `has_one_attached` 和 `has_many_attached` 的 N+1 查询问题的解决办法


我来抄段源码：
```ruby
class User < ActiveRecord::Base
  has_one_attached :avatar
end
```
    # There is no column defined on the model side, Active Storage takes
    # care of the mapping between your records and the attachment.
    #
    # To avoid N+1 queries, you can include the attached blobs in your query like so:

```ruby
User.with_attached_avatar
```
-----

```ruby
class Gallery < ActiveRecord::Base
  has_many_attached :photos
end
```
    # There are no columns defined on the model side, Active Storage takes
    # care of the mapping between your records and the attachments.
    #
    # To avoid N+1 queries, you can include the attached blobs in your query like so:

```ruby
Gallery.where(user: Current.user).with_attached_photos
```

## 其他

然后就是一些分析啊，预览啊之类的功能。。。没啥说的。。。

## activestorage 文件存储的理解
`activestorage` 把 `Disk service` 也当作云盘来处理，因此不会有 `.path`之类的获取路径的方法。所有的获取文件都是通过`.download`方法来实现的，如果要传路径，就先存在一个 tmp 的目录中

还有我觉得官方的文档 `.download` 的那个方法的用法太有误导性。只要在 rails 获取文件对象就要用`.download`来获取 （我当时以为是用户给 url, 然后后台下载。。。。）

后端部分可以拿出来单独用。。。前端部分我还没仔细研究。。不清楚。。。但是他的开发者发了 npm 的包。前后端分离项目用 activestorage 好像也不是什么难事。。enen。大概不是很难
