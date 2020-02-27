title: 'FM,FFM,DeepFM '
author: Yuan
mathjax: true
tags:
  - 推荐系统
categories: []
date: 2020-01-29 20:35:00
---
最近过年在家因为疫情不能外出，随手抓了本推荐系统开始看。模型部分从传统的邻域（协同过滤）到隐语义模型（LFM）到矩阵分解模型（SVD，SVD++），FM和FFM等遇到颇多问题，在此梳理一下。

# FM
FM的paper地址如下：https://www.csie.ntu.edu.tw/~b97053/paper/Rendle2010FM.pdf
FM主要目标是：解决数据稀疏的情况下，特征怎样组合的问题
根据paper的描述，FM有一下三个优点：
1. 处理稀疏数据
2. FM模型的时间复杂度是线性的
3. FM是一个通用模型，它可以用于任何特征为实值的情况

- 一般的线性模型：
$y=w_{0}+\sum_{i=1}^{n} w_{i} x_{i}$

从上面的式子中看出，一般的线性模型没有考虑特征之间的关联。

- 为了简化，采用最简单的**二阶组合+多项式相乘**作为关联特征的例子。
$y=w_{0}+\sum_{i=1}^{n} w_{i} x_{i}+\sum_{i=1}^{n} \sum_{j=i+1}^{n} w_{i j} x_{i} x_{j}$

该多项是模型与线性模型相比，多了特征组合的部分，特征组合部分的参数有$\frac{n(n-1)}{2}$个($w_{i j}$是对称的)。如果特征非常稀疏且维度很高的话，时间复杂度O(N^2)。
所以，通过引入辅助向量lantent vector $V_{i}=\left[v_{i 1}, v_{i 2}, \dots, v_{i k}\right]^{T}$来表示$\frac{n(n-1)}{2}$个参数。（这里借用了FunkSVD(LFM，Latent Factor Model)的思想）	

- FM
$y=w_{0}+\sum_{i=1}^{n} w_{i} x_{i}+\sum_{i=1}^{n} \sum_{j=i+1}^{n}<V_{i}, V_{j}>x_{i} x_{j}$

这里，辅助向量V的长度K一般是远远小于n的，所以参数量从$\frac{n(n-1)}{2}$个变成了$nk$，参数量降低，而且每一个向量V也表示了x的一个维度，有更好的解释性，**本质上是在对特征进行embedding**。且时间复杂度降为O(kN).

时间复杂度化简后方可看出：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200129213611.png)

# FFM(Field-aware Factorization Machines)
FFM是FM的升级版模型，引入了field的概念。FFM把相同性质的特征归于同一个field。在FFM中，每一维特征$x_i$，针对每一种field $f_j$，都会学习到一个隐向量$V_{i,f_j}$，因此，隐向量不仅与特征相关，也与field相关。

设样本一共有n个特征, f 个field，那么FFM的二次项有nf个隐向量。而在FM模型中，每一维特征的隐向量只有一个。FM可以看做FFM的特例，即把所有特征都归属到同一个field中。

$y = w_0 + \Sigma_{i=1}^{n}w_{i} x_{i} + \Sigma_{i=1}^{n}\Sigma_{j=i+1}^{n}<V_{i,f_{j}}, V_{j,f_{i}}>x_{i}x_{j}$

如果隐向量的长度为k，那么FFM的二次项参数数量为nfk，远多于FM模型。此外由于隐向量与field相关，FFM二次项并不能够化简，时间复杂度为$O(kn^2)$。需要注意的是由于FFM中的latent vector只需要学习特定的field，所以通常$K_{FFM} << K_{FM}$。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200130123459.png)

# DeepFM

当理解了FM，deepfm的思路也就很好懂了。

fm是低阶特征，dnn是高阶特征，把低阶和高阶特征并行就是deepFM
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200130132900.png)
我们先来看一下DeepFM的模型结构：

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200130135729.png)
FM部分是一个因子分解机。关于因子分解机可以参阅文章[Rendle, 2010] Steffen Rendle. Factorization machines. In ICDM, 2010.。因为引入了隐变量的原因，对于几乎不出现或者很少出现的隐变量，FM也可以很好的学习。
**深度部分**
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200130135817.png)

深度部分是一个前馈神经网络。与图像或者语音这类输入不同，图像语音的输入一般是连续而且密集的，然而用于CTR的输入一般是及其稀疏的。因此需要重新设计网络结构。具体实现中为，在第一层隐含层之前，引入一个嵌入层来完成将输入向量压缩到低维稠密向量。

  ![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200130135833.png)
  嵌入层(embedding layer)的结构如上图所示。当前网络结构有两个有趣的特性，1）尽管不同field的输入长度不同，但是embedding之后向量的长度均为K。2)在FM里得到的隐变量Vik现在作为了嵌入层网络的权重。

这里的第二点如何理解呢，假设我们的k=5，首先，对于输入的一条记录，同一个field 只有一个位置是1，那么在由输入得到dense vector的过程中，输入层只有一个神经元起作用，得到的dense vector其实就是输入层到embedding层该神经元相连的五条线的权重，即vi1，vi2，vi3，vi4，vi5。这五个值组合起来就是我们在FM中所提到的Vi。在FM部分和DNN部分，这一块是共享权重的，对同一个特征来说，得到的Vi是相同的。

代码地址：[https://github.com/ChenglongChen/tensorflow-DeepFM](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FChenglongChen%2Ftensorflow-DeepFM)

梳理FM发展历史：[https://zhuanlan.zhihu.com/p/52877868](https://zhuanlan.zhihu.com/p/52877868)
参考FM：[https://blog.csdn.net/John_xyz/article/details/78933253](https://blog.csdn.net/John_xyz/article/details/78933253)
带举例的解释：[https://blog.csdn.net/baymax_007/article/details/83931698](https://blog.csdn.net/baymax_007/article/details/83931698)
推荐系统遇上深度学习系列1-3：[https://www.jianshu.com/p/6f1c2643d31b](https://www.jianshu.com/p/6f1c2643d31b)