title: 通过ssh免密部署github
author: Yuan
tags:
  - ssh
  - github
  - hexo
  - linux
categories:
  - 工程
date: 2020-02-26 18:10:00
---
之前在部署博客到github page的时候每当遇到hexo deploy，遇到了
```
git@github.com: Permission denied (publickey).
fatal: 无法读取远程仓库。
请确认您有正确的访问权限并且仓库存在。
```
搞的我百思不得其解，ssh和github的连接明明是搞好的。最后定位到问题是系统ssh-key代理被误删了。具体是什么操作误删我就没定位到，可能是因为用了zsh的shell之后，和之前bash的路径不对？算了，这篇就总结搭载ssh的过程。

具体怎么搞ssh参考这篇[GitHub如何配置SSH Key](https://blog.csdn.net/u013778905/article/details/83501204)。



# 设置git的user name和email
如果你是第一次使用，或者还没有配置过的话需要操作一下命令，自行替换相应字段。
```
git config --global user.name "xxxxxx"
git config --global user.email  "xxxxx@gmail.com"
```
说明：git config --list 查看当前Git环境所有配置，还可以配置一些命令别名之类的

# 检查/生成ssh key

ssh key 由一个公钥(id_rsa.pub)和私钥(id_rsa)组成，构成ssh通道的安全。
可以通过cd ~/.ssh   然后ls  查看。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200226175214.png)
上图中，我有两组ssh key。
如果没有，就生成一下。
> ssh-keygen -t rsa -C "xxxxxxx@qq.com"


# 获取公钥添加到github里

> cat id_rsa.pub
然后复制到github -> settting -> ssh and GPG keys -> new SSHkey

然后拷贝进去。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200226175610.png)

# 测试
{% note primary %}  
> $ ssh -T git@github.com 
> Hi ! You've successfully authenticated, but GitHub does not provide shell access.
{% endnote %}
说明运行成功，恭喜你拜托了https步入SSH时代。


# 解决多个秘钥ssh权限问题

通常一台电脑生成一个ssh不会有这个问题，当一台电脑生成多个ssh的时候，就可能遇到这个问题，解决步骤如下：
## 查看系统ssh-key代理,执行如下命令
`$ ssh-add -l`

　　以上命令如果输出 The agent has no identities. 则表示没有代理。如果系统有代理，可以执行下面的命令清除代理:
`$ ssh-add -D`

## 然后依次将不同的ssh添加代理，执行命令如下：
`$ ssh-add ~/.ssh/id_rsa`
`$ ssh-add ~/.ssh/aysee`

　你会分别得到如下提示：
```
2048 8e:71:ad:88:78:80:b2:d9:e1:2d:1d:e4:be:6b:db:8e /Users/aysee/.ssh/id_rsa (RSA)
2048 8e:71:ad:88:78:80:b2:d9:e1:2d:1d:e4:be:6b:db:8e /Users/aysee/.ssh/id_rsa (RSA)
```
　　如果使用 ssh-add ~/.ssh/id_rsa的时候报如下错误，则需要先运行一下 ssh-agent bash 命令后再执行 ssh-add ...等命令
`Could not open a connection to your authentication agent.`

## 配置 ~/.ssh/config 文件

　　如果没有就在~/.ssh目录创建config文件，该文件用于配置私钥对应的服务器
```
# Default github user(first@mail.com)
Host github.com
HostName github.com
User git
IdentityFile C:/Users/username/.ssh/id_rsa
# aysee (company_email@mail.com)
Host github-aysee
`HostName github.com
User git
IdentityFile C:/Users/username/.ssh/aysee
```
Host随意即可，方便自己记忆，后续在添加remote是还需要用到。 配置完成后，在连接非默认帐号的github仓库时，远程库的地址要对应地做一些修改，比如现在添加second帐号下的一个仓库test，则需要这样添加：

`git remote add test git@github-aysee:ay-seeing/test.git`
`#并非原来的git@github.com:ay-seeing/test.git`
ay-seeing 是github的用户名

## 测试 ssh
`ssh -T git@github.com`
你会得到如下提示，表示这个ssh公钥已经获得了权限
`Hi USERNAME! You've successfully authenticated, but github does not provide shell access.`



参考：https://www.cnblogs.com/ayseeing/p/4445194.html