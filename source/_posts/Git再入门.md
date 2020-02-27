title: Git再入门
author: Yuan
tags:
  - git
categories:
  - 工程
date: 2020-01-11 20:57:00
---
# 认识多年，但我还是不懂你--GIT
虽然用github已经很多年了，但是git的各种命令没怎么接触过，能用的也只是简单的clone和pull，也没用真正的理解git的内涵。作为多人合作和版本控制的工具，git强大的一面我还没有接触到。

最近实习的时候需要编写cpp服务，写好了就需要git push 到新的分支去，等待导师code review，然后merge到master，中间遇到很多坑，在此就一篇文章整理完所有git方面的知识。

刚开始接触git会遇到很多命令，记不住没关系，先花两个小时理解git的概念，之后遇到问题再查。
详细教程可以看：[https://www.runoob.com/git/git-tutorial.html](https://www.runoob.com/git/git-tutorial.html)


# 版本控制
版本控制（Revision control）是一种在开发的过程中用于管理我们对文件、目录或工程等内容的修改历史，方便查看更改历史记录，备份以便恢复以前的版本的软件工程技术。

-   实现跨区域多人协同开发
-   追踪和记载一个或者多个文件的历史记录
-   组织和保护你的源代码和文档
-   统计工作量
-   并行开发、提高开发效率
-   跟踪记录整个软件的开发过程
-   减轻开发人员的负担，节省时间，同时降低人为错误

**简单说就是用于管理多人协同开发项目的技术。**

# git的基本概念
## 工作区

Git本地有四个工作区域：工作目录（Working Directory）、暂存区(Stage/Index)、资源库(Repository或Git Directory)、git仓库(Remote Directory)。文件在这四个区域之间的转换关系如下：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200111202138.png)
**Workspace**： 工作区，就是你平时存放项目代码的地方
**Index / Stage**： 暂存区，用于临时存放你的改动，事实上它只是一个文件，保存即将提交到文件列表信息
**Repository**： 仓库区（或版本库），就是安全存放数据的位置，这里面有你提交到所有版本的数据。其中HEAD指向最新放入仓库的版本
**Remote**： 远程仓库，托管代码的服务器，可以简单的认为是你项目组中的一台电脑用于远程数据交换

# 工作流程
1. clone项目或者创建项目Repository
2. 写代码
3. git add 修改了的有价值的代码到index
4. index commit提交到本地的项目Repository
5. 本地改好了就上传到服务器上remote

# 文件的四种状态
版本控制就是对文件的版本控制，要对文件进行修改、提交等操作，首先要知道文件当前在什么状态，不然可能会提交了现在还不想提交的文件，或者要提交的文件没提交上。

GIT不关心文件两个版本之间的具体差别，而是关心文件的整体是否有改变，若文件被改变，在添加提交时就生成文件新版本的快照，而判断文件整体是否改变的方法就是用SHA-1算法计算文件的校验和。

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200111202617.png)
**Untracked:** 未跟踪, 此文件在文件夹中, 但并没有加入到git库, 不参与版本控制. 通过git add 状态变为Staged.

**Unmodify:** 文件已经入库, 未修改, 即版本库中的文件快照内容与文件夹中完全一致. 这种类型的文件有两种去处, 如果它被修改, 而变为Modified. 如果使用git rm移出版本库, 则成为Untracked文件

**Modified:**  文件已修改, 仅仅是修改, 并没有进行其他的操作. 这个文件也有两个去处, 通过git add可进入暂存staged状态, 使用git checkout 则丢弃修改过,返回到unmodify状态, 这个git checkout即从库中取出文件, 覆盖当前修改

**Staged:** 暂存状态. 执行git commit则将修改同步到库中, 这时库中的文件和本地文件又变为一致, 文件为Unmodify状态. 执行git reset HEAD filename取消暂存,文件状态为Modified

下面的图很好的解释了这四种状态的转变：

![](https://img2018.cnblogs.com/blog/1090617/201810/1090617-20181008212245877-52530897.png)

# 四个区域之间的命令

#### 1、新建代码库
```
# 在当前目录新建一个Git代码库
git init # 新建一个目录，将其初始化为Git代码库
git init [project-name] # 下载一个项目和它的整个代码历史
git clone [url]
```

#### 2、查看文件状态
```
#查看指定文件状态
git status [filename] #查看所有文件状态
git status
```
#### 3、工作区<-->暂存区
```
# 添加指定文件到暂存区
git add [file1] [file2] ... # 添加指定目录到暂存区，包括子目录
git add [dir] # 添加当前目录的所有文件到暂存区
git add . #当我们需要删除暂存区或分支上的文件, 同时工作区也不需要这个文件了, 可以使用（⚠️）
git rm file_path #当我们需要删除暂存区或分支上的文件, 但本地又需要使用, 这个时候直接push那边这个文件就没有，如果push之前重新add那么还是会有。
git rm --cached file_path #直接加文件名   从暂存区将文件恢复到工作区，如果工作区已经有该文件，则会选择覆盖 #加了【分支名】 +文件名  则表示从分支名为所写的分支名中拉取文件 并覆盖工作区里的文件
git checkout
```

#### 4、工作区<-->资源库（版本库）
```
#将暂存区-->资源库（版本库）
git commit -m '该次提交说明'
#如果出现:将不必要的文件commit 或者 上次提交觉得是错的  或者 不想改变暂存区内容，只是想调整提交的信息
#移除不必要的添加到暂存区的文件
git reset HEAD 文件名 #去掉上一次的提交（会直接变成add之前状态） 
git reset HEAD^ 
#去掉上一次的提交（变成add之后，commit之前状态） 
git reset --soft  HEAD^ 
```

#### 5、远程操作
```
# 取回远程仓库的变化，并与本地分支合并
git pull # 上传本地指定分支到远程仓库
git push
```
#### 6、其它常用命令

```
# 显示当前的Git配置
git config --list # 编辑Git配置文件
git config -e [--global] #初次commit之前，需要配置用户邮箱及用户名，使用以下命令：
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
#调出Git的帮助文档
git --help #查看某个具体命令的帮助文档
git +命令 --help #查看git的版本
git --version
```















参考：[https://www.cnblogs.com/qdhxhz/p/9757390.html](https://www.cnblogs.com/qdhxhz/p/9757390.html)