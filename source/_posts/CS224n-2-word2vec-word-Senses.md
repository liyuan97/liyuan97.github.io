title: 'CS224n-2 word2vec, word Senses'
author: Yuan
mathjax: true
tags:
  - NLP
categories:
  - CS224n
date: 2020-02-08 23:37:47
---
# CS224n-2 word2vec, word Senses


这节课我不按课堂讲的，引用一篇[博客](https://www.jianshu.com/p/a6bc14323d77)
# word vectors and word2vec 

## 代表技术之一 word2vec

2013年，Google团队发表了word2vec工具 [1]。word2vec工具主要包含两个模型：跳字模型（skip-gram）和连续词袋模型（continuous bag of words，简称CBOW），以及两种近似训练法：负采样（negative sampling）和层序softmax（hierarchical softmax）。值得一提的是，word2vec的词向量可以较好地表达不同词之间的相似和类比关系。

word2vec自提出后被广泛应用在自然语言处理任务中。它的模型和训练方法也启发了很多后续的词嵌入模型。本节将重点介绍word2vec的模型和训练方法。

## Skip-gram模型（跳字模型）：

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208213903.png)
Skip-gram

在跳字模型中，我们用一个词来预测它在文本序列周围的词。

举个例子，假设文本序列是：

> “I love you very much”

跳字模型所关心的是，给定“**you**”生成邻近词“I”、“love”、“very”和“much”的条件概率。

在这个例子中，“you”叫中心词，“I”、“love”、“very”和“much”叫背景词。

由于“you”只生成与它距离不超过2的背景词，该**时间窗口的大小为2**[与N-gram类似]。

我们来描述一下跳字模型[用最大似然估计的思想]：

假设词典索引集V的大小为|V|，且{0,1,…,|V|−1}。给定一个长度为T的文本序列中，文本序列中第t的词为w(t)。当时间窗口大小为m时，跳字模型需要**最大化给定任一中心词生成所有背景词的概率：**

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208213949.png)

上式的**最大似然估计**与**最小化以下损失函数**等价：

![](https://upload-images.jianshu.io/upload_images/1803066-6089ead7ce1ea503.png?imageMogr2/auto-orient/strip|imageView2/2/w/720/format/webp)

我们可以用**v**和**u**分别表示 **中心词** 和 **背景词** 的向量。

换言之，对于词典中索引为i的词，它在作为中心词和背景词时的向量表示分别是vi和ui。而词典中所有词的这两种向量正是跳字模型所要学习的模型参数。为了将模型参数植入损失函数，我们需要使用模型参数表达损失函数中的给定中心词生成背景词的条件概率。给定中心词，假设生成各个背景词是相互独立的。设中心词wc在词典中索引为c，背景词wo在词典中索引为o，损失函数中的给定中心词生成背景词的**条件概率**可以通过softmax函数定义为：

![](https://upload-images.jianshu.io/upload_images/1803066-69d819ac1e385080.png?imageMogr2/auto-orient/strip|imageView2/2/w/662/format/webp)

> 上式：给定任何一个中心词Wc，产生背景词Wo的概率

> 每一个词，在模型中有两个词向量，一个是作为中心词时的词向量，一个是作为背景词时的词向量

**利用随机梯度下降求解：**

当序列长度T较大时，我们通常在每次迭代时随机采样一个较短的子序列来计算有关该子序列的损失。然后，根据该损失计算词向量的梯度并迭代词向量。具体算法可以参考[“梯度下降和随机梯度下降——从零开始”](https://links.jianshu.com/go?to=http%3A%2F%2Fzh.gluon.ai%2Fchapter_optimization%2Fgd-sgd-scratch.html)一节。 作为一个具体的例子，下面我们看看如何计算随机采样的子序列的损失有关中心词向量的梯度。和上面提到的长度为T的文本序列的损失函数类似，随机采样的子序列的损失实际上是对子序列中给定中心词生成背景词的条件概率的对数求平均。通过微分，我们可以得到上式中条件概率的对数有关中心词向量vc的**梯度：**  

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215618.png)

**该式也可改写作：**

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215642.png)

> 上面的迭代更新计算开销太大！！每次都需要遍历整个字典，对应的解决方案在后面（这也是word2vec为啥这么牛逼的原因...厉害的不是这个工具本身，而是一种思想的应用）

随机采样的子序列有关其他词向量的梯度同理可得。训练模型时，每一次迭代实际上是用这些梯度来迭代子序列中出现过的中心词和背景词的向量。训练结束后，对于词典中的任一索引为i的词，我们均得到该词作为中心词和背景词的两组词向量vi和ui。在自然语言处理应用中，我们会使用跳字模型的中心词向量。
#### 求梯度过程

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208220835.png)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208220909.png)
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208220919.png)
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208220926.png)

----------

### CBOW(连续词袋模型)

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215727.png)

CBOW

连续词袋模型与跳字模型类似,与跳字模型最大的不同是：

连续词袋模型用一个中心词在文本序列周围的词来预测该中心词。

举个例子，假设文本序列为：

> “I love you very much”

连续词袋模型所关心的是，邻近词“I”、“love”、“very”和“much”一起生成中心词“you”的概率。

假设词典索引集的大小为V，且V={0,1,…,|V|−1}</nobr>。给定一个长度为T的文本序列中，文本序列中第t个词为wu(t)。当时间窗口大小为m时，连续词袋模型需要最大化由背景词生成任一中心词的概率

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215738.png)

上式的最大似然估计与最小化以下损失函数等价：

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215749.png)

我们可以用**v**和**u**分别表示背景词和中心词的向量（注意符号和跳字模型中的不同）。换言之，对于词典中索引为i的词，它在作为背景词和中心词时的向量表示分别是vi和ui。而词典中所有词的这两种向量正是连续词袋模型所要学习的模型参数。为了将模型参数植入损失函数，我们需要使用模型参数表达损失函数中的给定背景词生成中心词的概率。设中心词wc在词典中索引为c，背景词wo1、wo2、...wo2m在词典中索引为o1、o2、....o2m-1、o2m，损失函数中的给定背景词生成中心词的概率可以通过softmax函数定义为

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208215805.png)

和跳字模型一样，当序列长度T较大时，我们通常在每次迭代时随机采样一个较短的子序列来计算有关该子序列的损失。然后，根据该损失计算词向量的梯度并迭代词向量。 通过微分，我们可以计算出上式中条件概率的对数有关任一背景词向量voi(i=1,2,....2m)的梯度为：  
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208221019.png)


该式也可写作

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208221029.png)

随机采样的子序列有关其他词向量的梯度同理可得。和跳字模型一样，训练结束后，对于词典中的任一索引为i的词，我们均得到该词作为背景词和中心词的两组词向量vi和ui。  
在自然语言处理应用中，我们会使用连续词袋模型的背景词向量。


----------

# 近似训练法

我们可以看到，无论是skip-gram(跳字模型)还是CBOW(连续词袋模型)，每一步梯度计算的开销与词典V的大小相关。

> 因为计算softmax的时考虑了字典上的所有可能性

当词典较大时，例如几十万到上百万，这种训练方法的计算开销会较大。因此，我们将使用近似的方法来计算这些梯度，从而减小计算开销。常用的近似训练法包括负采样和层序softmax。

## (1)负采样（Negative Sample）

我们以跳字模型为例讨论负采样。

实际上，词典V的大小之所以会在损失中出现，是因为给定中心词$w_c$生成背景词wo的条件概率$P(w_0∣w_c)$

> 使用了softmax运算，而softmax运算正是**考虑了背景词可能是词典中的任一词（使用了全部词）**，并体现在分母上。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224459.png)

下面，我们可以使用σ(x)=1/(1+exp(−x))函数来表达中心词wc和背景词wo同时出现在该训练数据窗口的概率。

> σ(x)属于[0,1]
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224516.png)


那么，给定中心词wc生成背景词wo的条件概率的对数可以近似为:  
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224525.png)

[上式的含义：中心词wc与背景词wo同时出(D=1)现概率，且中心词wc与噪音词wk不同时出现(D=0)的概率。]

假设噪声词wk在词典中的索引为ik，上式可改写为:

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224609.png)

因此，有关给定中心词wc生成背景词wo的损失是:


假设词典V很大，每次迭代的计算开销由O(|V|)变为O(|K|)。当我们把K取较小值时，负采样每次迭代的计算开销将较小。

当然，我们也可以对连续词袋模型进行负采样。有关给定背景词  
wt-m、wt-m+1、...、wt+m生成中心词wc的损失:
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224615.png)

在负采样中可以近似为:

  ![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224627.png)

同样，当我们把K取较小值时，负采样每次迭代的计算开销将较小。

## (2)层序softmax[]

层序softmax是另一种常用的近似训练法。它利用了二叉树这一数据结构。树的每个叶子节点代表着词典V中的每个词。  

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224641.png)
  
假设L(w)为从二叉树的根节点到词w<的叶子节点的路径（包括根和叶子节点）上的节点数。设n(w,j)为该路径上第j个节点，并设该节点的向量为un(w,j)。以上图为例：L(w3)=4。设词典中的词wi的词向量为vi。那么，跳字模型和连续词袋模型所需要计算的给定词wi生成词w的条件概率为：![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224651.png)
其中σ(x)=1/(1+exp(−x))，leftChild(n)是节点n的左孩子节点，如果判断x为真，[x]=1；反之[x]=−1。由于σ(x)+σ(−x)=1，给定词wi生成词典V中任一词的条件概率之和为1这一条件也将满足：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224729.png)

让我们计算给定词wi生成词w3的条件概率。我们需要将wi的词向量vi和根节点到w3路径上的非叶子节点向量一一求内积。由于在二叉树中由根节点到叶子节点w3的路径上需要向左、向右、再向左地遍历，我们得到:  
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208224736.png)

> **整个遍历的路径已经通过Huffman编码唯一的确定了**

在使用softmax的跳字模型和连续词袋模型中，词向量和二叉树中非叶子节点向量是需要学习的模型参数。

假设词典V很大，每次迭代的计算开销由O(|V|)下降至O(log2|V|)。

推荐资料：[学习word2vec的经典资料](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fx-hacker%2FWordEmbedding)

# SVD
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208225228.png)


分解矩阵，就可以得到embedding，和推荐系统的思路一样。SVD也存在维数问题，以及矩阵分解的困难。

# GloVe算法-基于局部和全局
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208225801.png)
比较SVD这种count based模型与Word2Vec这种direct prediction模型，它们各有优缺点：Count based模型优点是训练快速，并且有效的利用了统计信息，缺点是对于高频词汇较为偏向，并且仅能概括词组的相关性，而且有的时候产生的word vector对于解释词的含义如word analogy等任务效果不好；Direct Prediction优点是可以概括比相关性更为复杂的信息，进行word analogy等任务时效果较好，缺点是对统计信息利用的不够充分。所以Manning教授他们想采取一种方法可以结合两者的优势，并将这种算法命名为GloVe（Global Vectors的缩写），表示他们可以有效的利用全局的统计信息。

那么如何有效的利用word-word co-occurrence count并能学习到词语背后的含义呢？首先为表述问题简洁需要，先定义一些符号：对于矩阵X，$X_{ij}$代表了单词 i 出现在单词 j 上下文中的次数，则$X_i=\sum_k X_{ij}$
 即代表所有出现在单词 i 的上下文中的单词次数。我们用$P_{i j}=P(j | i)=\frac{X_{i j}}{X_{i}}$来代表单词 j 出现在单词 i 上下文中的概率。

我们用一个小例子来解释如何利用co-occurrence probability来表示词汇含义：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208225816.png)
例如我们想区分热力学上两种不同状态ice冰与蒸汽steam，它们之间的关系可通过与不同的单词 [公式] 的co-occurrence probability 的比值来描述，例如对于solid固态，虽然 $P(solidice)$ 与 $P(solid∣steam)$本身很小，不能透露有效的信息，但是它们的比值$\frac{P(solid|ice)} {P(solid|steam)}$ 却较大，因为solid更常用来描述ice的状态而不是steam的状态，所以在ice的上下文中出现几率较大，对于gas则恰恰相反，而对于water这种描述ice与steam均可或者fashion这种与两者都没什么联系的单词，则比值接近于1。所以相较于单纯的co-occurrence probability，实际上co-occurrence probability的相对比值更有意义。

通过定义如下的损失函数：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208230330.png)

优点是训练快，小数据集表现好。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20200208233632.png)