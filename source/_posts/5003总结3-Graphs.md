---
title: 5003总结3 Graphs
date: 2020-01-04 23:44:44
tags:
- 复习 
- spark
- 并行计算
- 5003
---

graphframes是处理图的一个API [graphframes官方文档](https://graphframes.github.io/graphframes/docs/_site/index.html)
可以和RDD结合，和pyspark结合使用。
在Python环境使用需要以下步骤：
```
**GraphFrames:**
-   For pre-installed Spark version ubuntu, to use GraphFrames:
    1.  get the jar file:  
        wget http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/0.7.0-spark2.4-s_2.11/graphframes-0.7.0-spark2.4-s_2.11.jar
    2.  Load the jar file in the Jupyter notebook  
        sc.addPyFile('path_to_the_jar_file')
    You can also refer to "~/Untitled.ipynb".
-   Using the pyspark shell directly with GraphFrames:
    -   ./bin/pyspark --packages graphframes:graphframes:0.7.0-spark2.4-s_2.11
-   Using Jupyter locally:
    1.  Set the environment variable:  
        export SPARK_OPTS="--packages graphframes:graphframes:0.7.0-spark2.4-s_2.11"
    2.  get the jar file:  
        wget http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/0.7.0-spark2.4-s_2.11/graphframes-0.7.0-spark2.4-s_2.11.jar
    3.  Load the jar file in the Jupyter notebook  
        sc.addPyFile('path_to_the_jar_file')
-   In Azure Databricks Service:
    1.  Start the cluster
    2.  Search for "graphframes' and install the library
```

在jupyter里面使用需要引用压缩包，例如：
`sc.addPyFile("/usr/local/Cellar/apache-spark/2.4.4/libexec/jars/graphframes-0.7.0-spark2.4-s_2.11.jar")`


---
# 生成图
```py
v = spark.createDataFrame([
  ("a", "Alice", 34),
  ("b", "Bob", 36),
  ("c", "Charlie", 37),
  ("d", "David", 29),
  ("e", "Esther", 32),
  ("f", "Fanny", 38),
  ("g", "Gabby", 60)
], ["id", "name", "age"])
# Edges DataFrame
e = spark.createDataFrame([
  ("a", "b", "friend"),
  ("b", "c", "follow"),
  ("c", "b", "follow"),
  ("f", "c", "follow"),
  ("e", "f", "follow"),
  ("e", "d", "friend"),
  ("d", "a", "friend"),
  ("a", "e", "friend"),
  ("g", "e", "follow")
], ["src", "dst", "relationship"])
# Create a GraphFrame
g = GraphFrame(v, e)

g.vertices.show()
g.edges.show()
```
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123161350.png)
建立两个dataframe：
- 一个储存节点vertices的id+[data]
- 另一个储存关系edges的["src", "dst", "relationship"]

这个图就建立好了。
# 图的基本属性
g.vertices和g.edges是输入的两个v，e 可以使用dataframe的方法筛选过滤统计。

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123140805.png)

g.outDegrees或者g.inDegrees可以返回一个dataframe-[id,degree]，自动计算每个节点的出度和入度。
- cache也可用到图上
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123141021.png)
整个图cache 运用：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123144609.png)
# Motif finding

Motif finding refers to searching for structural patterns in a graph.
例如：寻找互相关注，寻找三角形关注
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123145700.png)
寻找单向关注，寻找无人关注
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123145801.png)

另一种方法寻找无人关注的点：
- 左连接or求差集（先求id的差集，再直接join整张表）
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123150855.png)
> 如果不是左连接，那一行会被删掉

- 例子：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123151645.png)

先找单向的四人关系，map 相互为friend=1，筛选有2个friend以上的关系链。

# Subgraphs 生成子图
- 选择子节点和子边
- 生成新图
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123152823.png)

- 过滤掉多余的部分
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123153344.png)
这里的leftsemi的join方式：[leftsemi讲解](https://blog.csdn.net/zhaoxz128/article/details/80784188)
> Hive 当前**没有**实现 IN/EXISTS 子查询，所以你可以用 **LEFT SEMI JOIN 重写你的子查询语句**。LEFT SEMI JOIN 的限制是， JOIN 子句中右边的表只能在  ON 子句中设置过滤条件，在 WHERE 子句、SELECT 子句或其他地方过滤都不行。
# 例子：找到最少被两个人关注的人
```py
g.find("( )-[e]->(b)").filter("e.relationship='follow'").
groupby('b').count().filter("count>=2").select('b.name').show()

```


# 应用：BFS广度有限搜索

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123161040.png)
API自带的接口：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123161117.png)

# 例子 list rank
对于一个链表排序（按照距离尾部节点的距离排序）：
暴力算法：遍历n次，每次找到尾部节点，记录并删除 O(n)
方法2：
```
Initialize u.d = 0 if u.next = null, else u.d = 1
Run the following for each node u until all next pointers are null:
	if u.next is not null: 
		u.d += u.next.d 
		u.next = u.next.next
```
算法原理如图：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123170545.png)
复杂度O(logn)，每一轮遍历非尾节点都会参与，减少循环次数
 实现：
 ![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123170704.png)
 ![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191123170718.png)





# 总结
本文总结了pyspark的graph模块基本语法和操作，关于5003的三篇总结到此结束。