title: linux从入门到再入门
author: Yuan
tags:
  - linux
categories:
  - 工程
date: 2020-01-07 22:54:00
---
# Linux-工程必备
一直以来，没有系统的学习过linux，每次遇到工程问题，总是靠着百度和谷歌，效率很低。
最近需要部署C++服务，所以需要LINUX环境，在此立帖，持续更新，直到熟练使用linux。

# 用户管理

- 查看当前用户
```sh
$ cat /etc/passwd
```
- 添加新用户
```
$ adduser 选项 username
·
选项可以有：
-c 		comment 指定一段注释性描述。
-d(常用）  目录 指定用户主目录，如果此目录不存在，则同时使用-m选项，可以创建主目录。
-g(常用）  用户组 指定用户所属的用户组。
-G 		用户组，用户组 指定用户所属的附加组。
-s 		Shell文件 指定用户的登录Shell。
-u 		用户号 指定用户的用户号，如果同时有-o选项，则可以重复使用其他用户的标识号。
```

例1：
```
 useradd –d /usr/sam 
```
此命令创建了一个用户sam，其中-d选项用来为登录名sam产生一个主目录/usr/sam（/usr为默认的用户主目录所在的父目录）。

例2：
代码:
```
useradd -s /bin/sh -g group –G adm,root gem
```
此命令新建了一个用户gem，该用户的登录Shell是/bin/sh，它属于group用户组，同时又属于adm和root用户组，其中group用户组是其主组。


- 给新用户加密码
```
$ passwd 选项(不选最简单) 用户名
·
-l 锁定口令，即禁用账号。
-u 口令解锁。
-d 使账号无口令。
-f 强迫用户下次登录时修改口令。
如果默认用户名，则修改当前用户的口令。
然后输入两次密码就行了。
```


- 删除账号
```
$ userdel 选项(建议-r） 账户名
-r 可以把主目录一起删除
```


# 文件权限与访问控制
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200107231346.png)
Linux文件系统权限：

![](https://img-blog.csdn.net/20180711160810276?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjQ0MjcxMw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)







# 文件操作

**一、Linux系统的结构**

　　1、Linux是一个倒树型结构，最大的目录名称为“/”（根目录）

　　2、Linux系统的二级目录

　　/bin　　 ##binary二进制可执行文件，系统常规命令  
　　/boot 　　 ##启动目录，存放系统自动启动文件，内核，初始化程序  
　　/dev ##系统设备管理文件  
　　/etc　　 ##大多数系统配置文件存放路径  
　　/home 　 ##普通用户家目录（/home/student）  
　　/media 　 ##临时的挂载点  
　　/lib　　 ##函数库  
　　/lib64 　　 ##64位函数库（含有.bll）  
　　/mnt 　　 ##临时挂载点  
　　/run　　 ##自动临时设备挂载点（u盘）  
　　/opt　　 ##第三方软件安装的位置  
　　/sbin 　　 ##系统管理命令，通常只有root可以执行  
　　/proc 　　 ##系统硬件信息和系统进程信息~~~~  
　　/srv 　　 ##系统数据目录  
　　/var 　　 ##系统数据目录  
　　/sys　　 ##内核相关数据  
　　/usr 　　　 ##用户相关信息数据  
　　/tmp 　　 ##临时文件产生目录  
　　/root　　 ##超级用户家目录

　　***使用mount命令来更改临时设备的挂载点***

**二、文件管理命令**

　　1、文件的建立

　　命令：touch　filename　　## 通常用来创建文件，也可以修改文件的时间戳

　　注释：时间戳分为atime、mtime、ctime

　　　　atime　：文件内容被访问的时间标识

　　　　mtime　：文件内容被修改的时间标识

　　　　ctime　 ：文件属性或文件内容被修改的时间标识

　　实例：使用*** touch file *** 建立一个名为file的文件，并使用stat命令进行查看

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716191242211-1069722524.png)

-   　若进行文件的查看后，则访问时间将会被改变，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716191629214-2046658304.png)

-   　若文件进行编辑后，则访问时间、修改时间和文件改变时间三者均会变化，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716192012796-193555712.png)

　　注意：使用*** touch --help ***进行其他参数的查看

　　2、目录的建立

　　命令：mkdir　directory　　　　　　　　## 用来建立名为directory的目录

　　　　 mkdir　-p　test/redcat/linux　　 ## -p 进行多级目录的创建

　　注释：也可使用 mkdir --help命令进行参数的查看

　　实例：使用*** mkdir niu ***创建一个目录名为niu，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716192938835-574407116.png)

-   　多级目录创建结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716193136101-657056986.png)

　　3、文件的删除

　　命令：rm 　file　　　　 ## 进行文件的删除

　　　　 rm 　-f 　test　　## -f 为强行删除文件

　　实例：使用*** ls file ***命令删除文件file，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716193719450-1436996021.png)

　　4、目录的删除

　　命令：rm 　-r 　directory　　## -r表示递归删除所有内容

　　　　 rm　 -r　-f 　dir　　　## 删除目录不再提示

　　　　 rm 　-rf　　dir　　　 ## j结果与上一个相同，且有 -a -b -c= - abc = - cba　

　　实例：使用*** rm -rf test*** 删除test目录以及test目录下的所有内容，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716194551519-1288801399.png)

　　5、文件编辑

-   　gedit 编辑器

　　　　　命令：gedit　　file　　## 必须有图形界面，进行file文件的编辑

-   　vim 编辑器

　　　　　命令：vim　file ------> 按 i 进入insert 模式 ------> 书写内容 ------> esc退出insert模式 - -----> wq退出并保存

　　 实例：gedit使用（使用以下命令即可打开file文件，并进行编辑）

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716195422572-1655897153.png)

-   　使用vim.tiny实例应用如下：（vim 和vim.tiny功能类似）

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716195752419-614443396.png)

　　###### 使用vim 会出现异常情况 ######

　　当vim异常退出时，会生成.file.swp文件（原因是修改文件未保存）

　　当helloc未保存后再次打开时，会出现以下情况：（下面文字接着图的more）  
　 ![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716200340278-2049532639.png)

　　Swap file ".hello.swp" already exists!

　　[O]pen Read-Only, (E)dit anyway, (R)ecover, (D)elete it,　　 (Q)uit, (A)bort:  
　　　　只读打开 　　　 继续编辑 　 恢复数据 　 删除swap文件 退出  
　　分析：无论按【o】【e】【r】【q】【a】任何一个都不会删除.swp文件，再次打开还会

　　　　　有这样的这个问题，直到按【D】后，.swp被删除，vim恢复正常。  
  

　　6、文件的复制（复制目录的时候用- r）

　　命令：cp 　sourcefile　objectfile　　　　　　　　　## 表示把远文件复制到目标文件　

　　　　　cp 　-r　源目录　目的地目录　　

　　　　　cp 　源文件1　源文件2　目的地目录　　 　　## 目的地目录必须存在

　　　　　cp 　-r 　源目录1　源目录2　目的地目录　　 ## 目的地目录必须存在

　　实例：把file文件中的内容复制到file1中，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716202413095-1447577145.png)

-   　使用 *** cp -r test　test1 ***命令把test目录下内容复制到test1目录中，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716203157814-1198844011.png)

-   　使用 *** cp file1 file2 dir ***命令，把file1和file2文件复制到目录dir下，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716203804044-2015492922.png)

-   　使用*** cp -r dir dir1 dir2 ***把目录dir1和dir2复制到目录dir3下，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716204213938-2053126740.png)

　　7、文件的移动

　　命令：mv 　源文件　　目的地文件　　　　## 重命名

　　　　　mv　 源目录　　目的地目录

　　实例：使用*** mv file file1***命令，把file重命名为file1，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716204620780-1893321132.png)

　　使用*** mv niu/file test/ ***把niu目录下的file文件移动到test目录中，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716204956300-1776343291.png)

　　（.代表当前目录）例：把test目录下的file1复制到当前目录下，命令如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716205318027-1553458611.png)

　　注意：相同磁盘的文件移动是重命名的过程，不用磁盘的移动是复制删除的过程。

　　8、文件的查看

　　命令：cat　filename　　　　## 表示查看文件的全部内容

　　　　　cat 　-b 　filename　 ## 查看内容并显示行号

　　　　　less　filename　　　 ## 分页浏览(以下命令在less命令之后的操作)

　　　　　上|下　　　　　　　　## 逐行移动

　　　　　pageu|pagedn　　　 ## 逐页移动

　　　　　/关键字　　　　　　　## 高亮显示关键字，n向下匹配，N向上匹配

　　　　　v　　　　　　　　　　## 进入vim模式，然后按i进行编辑，返回vim模式按esc

　　　　　q　　　　　　　　　　##退出vim模式

　　实例：使用*** cat file1***命令查看file1中的内容，结果入下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716212743634-353476679.png)

-   　查看内容并显示行号，结果如下：

　　![](https://images2018.cnblogs.com/blog/1438668/201807/1438668-20180716212922248-1273385407.png)

-   　less 命令既修改文件中的内容，也可以使用快捷键进行查找，在此就不放截图了。

　　9、文件的寻址

　　相对路径：

　　　　　　相对与当前系统所在的目录的一个文件名称的简写；

　　　　　　此名称省略了系统当前所在目录的名称；

　　　　　　此名称不以“/”开头；

　　　　　　此名称在命令执行时会自动在操作对象前加入"pwd”所显示的值。

　　绝对路径：

　　　　　　绝对路径是文件在系统中的真实位置；

　　　　　　此命令以“/”开头；

　　　　　　此命令在执行时不会考虑现在的位置的信息。

　　注意：当操作对象是　　对象1　空格　对象2 时，这两个对象没有任何关系

　　　　　亲　　　　## 动作时被系统执行，不能作为名称出现

　　　　　“亲”　　　 ## 引号的作用是把动作变成名称字符，这种方法叫引用

　　　　　pwd　　　## 显示当前工作目录

　　10、自动补齐

　　《tab》

　　　　　系统中的《tab》键可以实现命令的自动补齐；

　　　　　可以补齐系统中存在的命令，文件名称，和部分命令的参数；

　　　　　当一次《tab》补齐不了时，代表以此关键字开头的内容不唯一；

　　　　　可以使用《tab》两次来列出所有一次关键字开头的内容散

# 脚本交互-except工具
主要用户自动操作，比如说：自动输入密码(最常见)
在使用expect时，基本上都是和以下四个命令打交道：

```
send	用于向进程发送字符串
expect	从进程接收字符串
spawn	启动新的进程
interact	允许用户交互
```
send命令接收一个字符串参数，并将该参数发送到进程。

expect命令和send命令相反，expect通常用来等待一个进程的反馈，我们根据进程的反馈，再发送对应的交互命令。

spawn命令用来启动新的进程，spawn后的send和expect命令都是和使用spawn打开的进程进行交互。

interact命令用的其实不是很多，一般情况下使用spawn、send和expect命令就可以很好的完成我们的任务；但在一些特殊场合下还是需要使用interact命令的，interact命令主要用于退出自动化，进入人工交互。

- 例子：链接shh

```
#!/usr/tcl/bin/expect

set timeout 30
set host "101.200.241.109"
set username "root"
set password "123456"

spawn ssh $username@$host
expect "*password*" {send "$password\r"}
interact
```

- 例子：自动切换到sudo 并启动hexo
```
#!/usr/bin/expect
set timeout 30
spawn sudo -s
expect "Password:"
send "123456\r"
expect "*#"
send "cd hexoblog\r"
expect "*#"
send "hexo s\r"
interact

```






























参考：[https://blog.csdn.net/weixin_42442713/article/details/81001753](https://blog.csdn.net/weixin_42442713/article/details/81001753)
[https://www.cnblogs.com/uthnb/p/9320582.html](https://www.cnblogs.com/uthnb/p/9320582.html)