---
title: Build by Hexo 
date: 2019-10-24 16:00:23
tags:
- blog
---
本次搭建blog，完全学习于：[b站up主codesheep视频](https://www.bilibili.com/video/av44544186?from=search&seid=6748505739751413370)

下面进入流程：
 0. sudo su 进入管理员
 1. 安装Node.js，搜索，下载，安装
 安装之后会有两个工具： node和npm
 也可以用国内的cnpm
 2. 通过npm安装hexo 博客静态框架
 > npm install -g hexo-cli 
 3. 建立一个专有的文件夹，方便管理
 4. 文件夹下运行hexo
 > sudo hexo init

初始化文件，主要的有_config.yml 配置文件，source内容的文件夹，themes主题文件夹。
> hexo s #start 开始
> hexo n "文章名" #生成文章
> hexo clean #清理之前的
5. 部署到github

生成 xxx.github.io（ xxx必须为github的用户名）的项目
> npm install --save hexo-deployer-git

下载插件，连接到git

设置_config.yml最下面
> type: git
> repo: https://github.com/xxxx/xxxx.github.io

推送到远端
> hexo clean && hexo g && hexo d


访问 xxxx.github.io，就可以看到自己的博客啦。

-----
[hexo官网](https://hexo.io/zh-cn/docs/commands.html)
