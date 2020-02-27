---
title: '5003总结1 RDD, Spark Internals'
date: 2019-12-21 01:37:50
tags: 
- 复习 
- spark
- 5003
---
# 5003总结1 RDD, Spark Internals
学习了5003之后，对于RDD和spark两章总结复习，梳理出有关函数的作用。

## RDD

resilient Distributed Datasets: 弹性分布式数据库，rdd是spark的基本运行单位
使用者作用于RDD，RDD自动进行分区，在不同partitions进行操作
![RDD的操作](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030092656.png)

* rdd是“懒惰的”Lazy，如果只进行Transfomations ，RDD不会进行实际运算，会等待actions操作才会实际运算。（理解起来就是，如果每Transfomations一次就要运算，就需要操作一下等一次；而且Transfomations之间可能有优化的空间；所以如果没有Actions就意味着不需要输出，就先记住步骤不执行）
---

[引用博文 https://haofly.net/spark/](https://haofly.net/spark/)
-   **RDD(Resilient Distributed Dataset弹性分布式数据集)**：这是spark的主要数据概念。有多种来源，容错机制，并且能缓存、并行计算。RDD在整个计算流程中会经过不同方式的变换，这种变换关系就是一个有向无环图。
-   需要注意的是，所有的方法在定义执行之前都是异步的，所以不能简单地在下面的方法外部添加`try...catch...`进行异常捕获，最好是在传入的函数里面进行异常的捕获(如果是lambda，请确认lambda不会报错，否则如果lambda报错整个程序都会报错并终止允许)
-   Spark应用程序可以使用大多数主流语言编写，这里使用的是python，只`pip install pyspark`即可
-   **Stage(调度阶段)**: 每个Job会根据RDD大小切分城多个Stage，每个Stage包含一个TaskSet
-   **TaskSet(任务集)**: 一组关联的Task集合，不过是没有依赖的
-   **Task(任务)**: RDD中的一个分区对应一个Task。
-   **Narrow Dependency(窄依赖)**: 比较简单的一对一依赖和多对一依赖(如union)
-   **Shuffle Dependency(宽依赖)**: 父RDD的分区被多个子RDD分区所使用，这时父RDD的数据会被再次分割发送给子RDD
-   **Spark 内存分配**: 分为这三块:
    -   **execution**: 执行内存，基本的算子都是在这里面执行的，这块内存满了就写入磁盘。
    -   **storage**: 用于存储broadcast, cache, persist
    -   **other**: 程序预留给自己的内存，这个可以不用考虑
-   **Duration**
    -   **batchDuration**: 批次时间
    -   **windowDuration**: 窗口时间，要统计多长时间内的数据，必须是`batchDuration`的整数倍
    -   **slideDuration**: 滑动时间，窗口多长时间滑动一次，必须是`batchDuration`的整数倍，一般是跟`batchDuration`时间相同
### 生成RDD
sc.parallelize(xrange(10))
sc.textFile('../data/fruits.txt')

### [](https://haofly.net/spark/#%E5%9F%BA%E6%9C%AC%E8%BF%90%E7%AE%97 "基本运算")基本运算

-   下面是所有运算方法的集合，其中有些方法仅用于键值对，有些方法仅用于数据流

#### [](https://haofly.net/spark/#Transformation-%E8%BD%AC%E6%8D%A2 "Transformation(转换)")Transformation(转换)

这类方法仅仅是定义逻辑，并不会立即执行，即lazy特性。目的是将一个RDD转为新的RDD。

-   map(func): 返回一个新的RDD，func会作用于每个map的key，func的返回值即是新的数据。为了便于后面的计算，这一步一般在数据处理的最前面将数据转换为(K, V)的形式，例如计数的过程中首先要`datas.map(lambda a, (a, 1))`将数据转换成(a, 1)的形式以便后面累加
-  flatmap： 提取出每个list的所有元素，压成一层

-   mappartitions(func, partition): 和map不同的地方在于map的func应用于每个元素，而这里的**func会应用于每个分区**，能够有效减少调用开销，减少func初始化次数。减少了初始化的内存开销。但是map如果数据量过大，计算后面的时候可以将已经计算过的内存销毁掉，但是mappartitions中如果一个分区太大，一次计算的话可能直接导致内存溢出。
-   filter(func): 返回一个新的RDD，func会作用于每个map的key，返回的仅仅是返回True的数据组成的集合，返回None或者False或者不返回都表示被过滤掉
-   filtMap(func): 返回一个新的RDD，func可以一次返回多个元素，最后形成的是所有返回的元素组成的新的数据集
-   mapValues(func): 返回一个新的RDD，对RDD中的每一个value应用函数func。
-   distinct(): 去除重复的元素
-   subtractByKey(other): 删除在RDD1中的RDD2中key相同的值
-   groupByKey(numPartitions=None): 将(K, V)数据集上所有Key相同的数据聚合到一起，得到的结果是(K, (V1, V2…))
-   reduceByKey(func, numPartitions=None): 将(K, V)数据集上所有Key相同的数据聚合到一起，func的参数即是每两个K-V中的V。可以使用这个函数来进行计数，例如reduceByKey(lambda a,b:a+b)就是将key相同数据的Value进行相加。
-   reduceByKeyAndWindow(func, invFunc, windowdurartion, slideDuration=None, numPartitions=None, filterFunc=None): 与reduceByKey类似，不过它是在一个时间窗口上进行计算，由于时间窗口的移动，有增加也有减少，所以必须提供一个逻辑和func相反的函数invFunc，例如func为(lambda a, b: a+b)，那么invFunc一般为(lambda a, b: a-b)，其中a和b都是key相同的元素的value。另外需要注意的是，程序默认会缓存一个时间窗口内所有的数据以便后续能进行inv操作，所以如果窗口太长，内存占用可能会非常高
-   join(other, numPartitions=None): 将(K, V)和(K, W)类型的数据进行类似于SQL的JOIN操作，得到的结果是这样(K, (V, W))
-   union(other): 并集运算，简单合并两个RDD
-   intersection(other): 交集运算，保留在两个RDD中都有的元素
-   leftOuterJoin(other): 左外连接
-   rightOuterJoin(other): 右外连接

#### [](https://haofly.net/spark/#Action-%E6%89%A7%E8%A1%8C "Action(执行)")Action(执行)

不会产生新的RDD，而是直接运行，得到我们想要的结果。

-   collect(): 以数组的形式，返回数据集中所有的元素
-   count(): 返回数据集中元素的个数
-   take(n): 返回数据集的前N个元素
-   takeOrdered(n): 升序排列，取出前N个元素
-   takeOrdered(n, lambda x: -x): 降序排列，取出前N个元素
-   first(): 返回数据集的第一个元素
-   min(): 取出最小值
-   max(): 取出最大值
-   stdev(): 计算标准差
-   sum(): 求和
-   mean(): 平均值
-   countByKey(): 统计各个key值对应的数据的条数
-   lookup(key): 根据传入的key值来查找对应的Value值
-   foreach(func): 对集合中每个元素应用func

#### [](https://haofly.net/spark/#Persistence-%E6%8C%81%E4%B9%85%E5%8C%96 "Persistence(持久化)")Persistence(持久化)
-  cache()：保存，固定
-   persist(): 将数据按默认的方式进行持久化
-   unpersist(): 取消持久化
-   saveAsTextFile(path): 将数据集保存至文件
- ---
## RDD的操作 pyspark

```py
fruits = sc.textFile('../data/fruits.txt') 
fruits.collect()
#读文本，全部显示
```
累加器的使用：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030104539.png)



```py
rdd = sc.parallelize(xrange(10))
accum = sc.accumulator(0)

def g(x):
    global accum
    accum += x
    return x * x

a = rdd.map(g)
print "---------"
print accum.value
print rdd.reduce(lambda x, y: x+y)
print "---------"
#a.cache()
tmp = a.count()
print accum.value
print rdd.reduce(lambda x, y: x+y)
print "---------"
tmp = a.count()
print accum.value
print rdd.reduce(lambda x, y: x+y)
#reduce 始终不变，但是如果没有cache accumulator就会反复累加
```

```py
---------
0
45
---------
45
45
---------
90
45
```
展示分区glom（）
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030105120.png)
mapParttitions 在分区内部执行函数f
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030110438.png)

这里的index就是为了改变每次生成的随机数不一样，否则每个分区算出来是一样的
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030110351.png)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030111556.png)
对key相同的值进行操作
#### kmeans
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030113309.png)


#### pagerank
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191031205443.png)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191030113538.png)



# Internal of Spark
## web端监控Spark运行情况
查看Spark 可视化进程： localhost:4040 4041 4042 ...
##  partitions 分区
RDD是储存在不同的partition里的，生成时每个partition平衡的（数量差不多），用于并行计算，但是有可能操作之后，就不平衡了。

这时候，需要 .repartition(n)


# Hash  vs Range partitioning
* Hash partitioning  
 通过%N，这样的将相同**余数**放到一个分区。
 缺点：可能由于原数据余数不平衡，可能分区不平衡
* Range partitioning
计算每个分区大小，将连续的数放到一个分区
缺点：数值大小不平衡

例子如下：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191031200235.png)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191031201853.png)
RDD本来没有partitions，当有了shuffle 或者主动生成一个partitions才会有。
(这样的好处是，shuffle本身是需要多个partitions一起参与的，如果是线性图（key没有变化），那就只需要在自己的分区内计算，实现并行)
 
会继承partitions的3个Operations(key不会改变):
 * mapValues  （但是map就不行）
* flatMapValues 
* filter  

其他的Operations都会改变key？ （这里需要考察一下）
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191031202823.png)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191031211821.png)

Spark 的 各级目录
> application 一个内核>job一次运行 >stage指令下的一个状态>task一个状态的任务


Spark的内存管理
-   Two types of memory usages for applications:  
    – Execution memory: for computation in shuffles, joins, sorts and aggregations
    – Storage memory: for caching and propagating internal data across the cluster







