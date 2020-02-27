---
title: '集成学习GDBT,XGBOOST,RF'
date: 2019-11-16 14:58:20
tags:
mathjax: true
---

集成学习（Ensemble Learning），集成学习的目的是通过结合多个基学习器的预测结果来改善单个学习器的泛化能力和鲁棒性。

集成学习致分为两大类：
- Boosting:即个体学习器之间存在强依赖关系、必须串行生成的序列化方法，Adaboost, GDBT, Xgboost.
- Bagging以及个体学习器间不存在强依赖关系、可同时生成的并行化方法，“随机森林”（Random Forest）。

# 1. Bagging

Bagging：简单放回抽样，多数表决（分类）或简单平均（回归）,同时Bagging的基学习器之间属于并列生成，无依赖关系。
## 1.1 随机森林
Random Forest（随机森林）：Bagging的扩展变体，它在以决策树为基学习器构建Bagging集成的基础上，进一步在决策树的训练过程中引入了随机特征选择，因此可以概括RF包括四个部分：
1、随机选择 样本（放回抽样）；
2、随机选择 特征；
3、构建分类器；如：ID3、C4.5、CART、SVM、Logistic regression等
4、投票（平均）

随机性偏差会有微增（相比于单棵不随机树），‘平均’会使得方差减小更多

- 随机森林的优点
1、速度快，精度不会很差
2、能够处理高维数据，不用特征选择，训练完后，可给出特征重要性；
3、可并行化  
- 随机森林的缺点：在噪声较大的分类或者回归问题上回过拟合。

# 2. Boosting
## 2.1 基于调整权重 Adaboost
每生成一棵树之后，计算两个权重
> 1 计算这个树的误差率，误差率越高，权重越低
> 2 计算每个样本的错分率，错分的样本，权重越高，之后更容易分对

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116091802.png)
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116091915.png)


## 2.2 基于残差：GB(GBTD,Xgboost)
### 2.2.1 GBTD
GBDT只能由回归树组成.
- 基本思想：
在GradientBoost中，每个新的模型的建立是为了使得之前的模型的残差往梯度下降的方法。

![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116110339.png)
- 如果是分类树，损失函数是指数损失函数：
𝐿(𝑦,𝑓(𝑥))=𝑒𝑥𝑝(−𝑦𝑓(𝑥))
- 如果是回归树，损失函数是均方损失（CART）：
𝐿(𝑦,𝑓(𝑥))=(𝑦−𝑓(𝑥))^2
- 如何防止过拟合？
> 1. 步长v(0-1)，权重衰减 𝑓𝑘(𝑥)=𝑓𝑘−1(𝑥)+𝑣 ℎ𝑘(𝑥)，降低新来的分类器的影响力
> 2. 子采样比例
> 3. 用弱学习器

### 2.2.2 xgboost
当已经生成了一棵树的时候，如何去选择新子树：
- 1 目标函数：
$$Obj=\sum_{i=1}^{n} l\left(y_{i}, \hat{y}_{i}\right)+\sum_{k} \Omega\left(f_{k}\right), f_{k} \in \mathcal{F}$$

- 1.1 第t轮的时候：
$$\begin{aligned} O b j^{(t)} 
&=\sum_{i=1}^{n} l\left(y_{i}, \hat{y}_{i}^{(t)}\right)+\sum_{i=1}^{t} \Omega\left(f_{i}\right) 
\\ & \equiv \sum_{i=1}^{n} l\left(y_{i}, \hat{y}_{i}^{(t-1)}+f_{t}\left(x_{i}\right)\right)+\Omega\left(f_{t}\right)+c\end{aligned}$$
- 这时候需要寻找f_t来让目标函数最小


> 
> a. 式子左边，对目标函数在$f_t(x)$上泰勒展开，去二阶，求得近似解：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116120113.png)

> b. 式子右边，定义复杂度 $\Omega\left(f_{t}\right)$ 
每颗树，都是由枝干(分类节点)和叶子(树的末端)组成的。
定义复杂度为：叶子个个数T, 加上每个叶子的值w平方和（各有系数）。
树越复杂，T ↑，w平方和 ↑，复杂度 ↑，惩罚 ↑。
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116121238.png)

- 更新目标函数：
$$
\begin{aligned} O b j^{(t)} & \simeq \sum_{i=1}^{n}\left[g_{i} f_{t}\left(x_{i}\right)+\frac{1}{2} h_{i} f_{t}^{2}\left(x_{i}\right)\right]+\Omega\left(f_{t}\right) +c\\ &=\sum_{i=1}^{n}\left[g_{i} w_{q\left(x_{i}\right)}+\frac{1}{2} h_{i} w_{q\left(x_{i}\right)}^{2}\right]+\left(\gamma T+\lambda \frac{1}{2} \sum_{j=1}^{T} w_{j}^{2}\right)+c
\\ &=\sum_{j=1}^{T}\left[\left(\sum_{i \in I_{j}} g_{i}\right) w_{j}+\frac{1}{2}\left(\sum_{i \in I_{j}} h_{i}+\lambda\right) w_{j}^{2}\right]+\gamma T +c \end{aligned}
$$

> - 其中$f_{t}(x)=w_{q(x)}, w \in \mathbf{R}^{T}, q: \mathbf{R}^{d} \rightarrow\{1,2, \cdots, T\}$，表示x→叶节点→对应的值w。目的是统一用$w_{j}$表示树$f_t$。
> - 第三行的理解，对于示性函数$I_{j}=\left\{i | q\left(x_{i}\right)=j\right\}$，$I_j$表示一个集合在j的叶子节点中。用示性函数求和代替1-n的求和，然后交换求和顺序。

- 这里发现目标函数是关于$w_{j}$的二次函数，二次函数在对称轴上取极值。
简化表达：$G_{j}=\sum_{i \in I_{j}} g_{i} \quad H_{j}=\sum_{i \in I_{j}} h_{i}$得到：
$$
\begin{aligned} O b j^{(t)} =\sum_{j=1}^{T}\left[G_{j} w_{j}+\frac{1}{2}\left(H_{j}+\lambda\right) w_{j}^{2}\right]+\gamma T \end{aligned}
$$
二次函数求极值得到：
$$
\begin{array}{c}{w_{j}^{*}=-\frac{G_{j}}{H_{j}+\lambda}} \\ {} \\ {O b j=-\frac{1}{2} \sum_{j=1}^{T} \frac{G_{j}^{2}}{H_{j}+\lambda}+\gamma T}\end{array}
$$
w是每一个叶节点值，Obj是这个树的分数，分数越低越好。
这样，就可以直接计算出树的分数，可以对于候选进行评比。
---
如何生成候选树？
- Enumerate 枚举可能的结构
- 通过刚才的式子计算最优分数
- 但是问题是有无限的可能性。
---
- 所以通过贪婪学习：（不详细讲）
每一次尝试对已有的叶子结点加入一个分割，选择具有最佳增益的分割对结点进行分裂。对于一个具体的分割方案，我们可以获得的增益可以由如下公式计算：
![](https://liyuanimage.oss-cn-beijing.aliyuncs.com/img/20191116142330.png)


> 也就是通过信息增益去寻找最优分割点。
> 这里有个好处就是如果惩罚大于增益，gain就会为负数，自动停止。


# 3 模型对比
## 3.1 随机森林vsGDBT

- 决策树类型：组成随机森林的树可以是分类树，也可以是回归树；而GBDT只能由回归树组成；  
- 结果预测：对于最终的输出结果而言，随机森林采用多数投票、简单平均等；而GBDT则是将所有结果累加起来，或者加权累加起来；  
- 并行/串行：组成随机森林的树可以并行生成；而GBDT只能是串行生成；  
- 异常值：随机森林对异常值不敏感；GBDT对异常值非常敏感；
- 方差/偏差：随机森林减少方差；GBDT是通过减少偏差。


## 3.2 GDBT vs XGboost

- GDBT只支持CATR树，xgboost还支持线性分类器
- GDBT只用了一阶，xgboost泰勒展开，用了二阶
- xgboost有正则项，而且会自动停止生成(依赖参数gamma)。
- xgboost可以列抽样，借鉴了随机森林的做法
- XGBOOST可以自动学习出缺失值的分裂方向
- XGBOOST实现了并行化：每个特征并行计算，每个特征划分也并行计算

后期实现中，xgboost还有优化，所以很快：
- 在寻找分割点，枚举贪心法效率低，xgboost实现近似的算法。大致的思想是根据百分位法列举几个成为分割点的候选者，然后再进一步计算。
- xgboost考虑了训练数据为稀疏值的情况（我也不懂T^T）
- 特征列排序后以块的形式存储在内存中，在迭代中可以重复使用；虽然boosting算法迭代必须串行，但是在处理每个特征列时可以做到并行。
- Shrinkage（缩减），相当于学习速率（xgboost中的eta）。xgboost在进行完一次迭代后，会将叶子节点的权重乘上该系数，主要是为了削弱每棵树的影响，让后面有更大的学习空间。实际应用中，一般把eta设置得小一点，然后迭代次数设置得大一点。（补充：传统GBDT的实现也有学习速率）

总结，一个简单的idel不断优化，借鉴别的想法，优化到了极致，导致xgboost能这么强。






参考资料：xgboost原文
[https://blog.csdn.net/weixin_42158523/article/details/81737370](https://blog.csdn.net/weixin_42158523/article/details/81737370)
[https://www.cnblogs.com/aixiao07/p/11375168.html](https://www.cnblogs.com/aixiao07/p/11375168.html)


