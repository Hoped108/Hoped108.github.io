---
title: "numpy&pandas"
date: 2026-05-02 00:00:00
tags:
  - note
---

# 🚀 零基础快速上手NumPy和Pandas

你好！既然你想直接开始学，那我就跳过理论，用最核心的代码示例带你快速上手。这些是我工作10年总结出的**最常用、最实用**的技能点，保证学完就能用！

## 🔢 NumPy - 数值计算的核心

### 1. 为什么用NumPy？
- **比Python列表快100倍**（向量化计算）
- **内存效率高**（连续内存存储）
- **所有数据科学库的基础**（Pandas, Scikit-learn, TensorFlow等都基于NumPy）

### 2. 核心代码示例（直接复制运行！）

```python
import numpy as np

# 创建数组 - 最常用的方式
arr = np.array([1, 2, 3, 4, 5])
print("基础数组:", arr)

# 二维数组（矩阵）
matrix = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
print("\n矩阵:\n", matrix)

# 快速创建特殊数组
zeros = np.zeros((3, 4))  # 3行4列的零矩阵
ones = np.ones((2, 2))    # 2x2单位矩阵
rand = np.random.rand(3, 3)  # 3x3随机数(0-1)
print("\n零矩阵:\n", zeros)
print("\n随机矩阵:\n", np.round(rand, 2))  # 四舍五入到2位小数

# 核心操作 - 向量化计算（不用for循环！）
arr = np.array([1, 2, 3, 4, 5])
print("\n向量化计算示例:")
print("每个元素+2:", arr + 2)
print("每个元素*3:", arr * 3)
print("平方:", arr ** 2)
print("平方根:", np.sqrt(arr))

# 索引和切片 - 比Python列表更强大
#matrix[start:end,start:end](行切片和列切片)
matrix = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
print("\n矩阵切片示例:")
print("第一行:", matrix[0, :])
print("第二列:", matrix[:, 1])
print("右下角2x2:", matrix[1:, 1:])
print("大于5的元素:", matrix[matrix > 5])  # 布尔索引

# 统计计算 - 数据分析核心
data = np.random.normal(10, 2, 1000)  # 生成1000个正态分布的随机数
print("\n统计计算:")
print(f"均值: {np.mean(data):.2f}")
print(f"标准差: {np.std(data):.2f}")
print(f"最小值: {np.min(data):.2f}, 最大值: {np.max(data):.2f}")
print(f"25%分位数: {np.percentile(data, 25):.2f}, 75%分位数: {np.percentile(data, 75):.2f}")

# 实战示例：股票收益率计算
prices = np.array([100, 102, 101, 105, 107, 110])
returns = (prices[1:] - prices[:-1]) / prices[:-1]  # 无需循环！
print("\n股票日收益率:", np.round(returns * 100, 2), "%")
```

### 3. NumPy核心技能总结
- `np.array()`：一切的起点
- 向量化操作：`+`, `-`, `*`, `/`, `**` 直接应用于整个数组
- 布尔索引：`arr[arr > 5]` 选择符合条件的元素
- 聚合函数：`np.mean()`, `np.sum()`, `np.std()`, `np.max()`, `np.min()`
- 形状操作：`arr.reshape()`, `arr.flatten()`

> 💡 **记住**：NumPy的核心思想是**避免Python循环**，用向量化操作让代码更快更简洁！

---

## 📊 Pandas - 数据处理的瑞士军刀

### 1. 为什么用Pandas？
- **处理表格数据**（像Excel，但更强大）
- **内置数据清洗功能**（处理缺失值、异常值）
- **强大的分组和聚合**（数据分析的核心）

### 2. 核心代码示例（直接上手！）

```python
import pandas as pd
import numpy as np

# 创建DataFrame - 最核心的数据结构
data = {
    '姓名': ['张三', '李四', '王五', '赵六', '钱七'],
    '年龄': [23, 35, 28, np.nan, 42],  # 包含缺失值
    '城市': ['北京', '上海', '北京', '广州', '上海'],
    '收入': [15000, 25000, 18000, 22000, 30000],
    '入职日期': ['2020-01-15', '2018-05-22', '2019-11-30', '2021-03-10', '2017-08-05']
}
df = pd.DataFrame(data)
print("基础DataFrame:\n", df)

# 数据导入/导出 - 每天都要用
# df = pd.read_csv('sales_data.csv')  # 读取CSV
# df.to_excel('output.xlsx', index=False)  # 保存到Excel

# 数据清洗 - 80%的工作在这里
print("\n数据清洗示例:")
print("检查缺失值:\n", df.isnull().sum())  # 每列缺失值数量
df_clean = df.fillna({'年龄': df['年龄'].mean()})  # 用均值填充年龄缺失值
print("\n填充后年龄列:", df_clean['年龄'])

# 数据类型转换
df_clean['入职日期'] = pd.to_datetime(df_clean['入职日期'])  # 转为日期类型
df_clean['工龄'] = (pd.Timestamp.now() - df_clean['入职日期']).dt.days // 365  # 计算工龄
print("\n转换后数据类型:\n", df_clean.dtypes)

# 数据筛选 - 多种方法
print("\n数据筛选示例:")
print("年龄>30的人:\n", df_clean[df_clean['年龄'] > 30])
print("\n北京的员工:\n", df_clean.query('城市 == "北京"'))  # query方法更简洁
print("\n收入在20000-25000之间:\n", df_clean[(df_clean['收入'] >= 20000) & (df_clean['收入'] <= 25000)])

# 分组聚合 - 数据分析核心
print("\n分组聚合示例:")
print("按城市分组统计:\n", df_clean.groupby('城市').agg({
    '年龄': 'mean',
    '收入': ['mean', 'sum', 'count'],
    '工龄': 'max'
}).round(1))

# 透视表 - Excel用户最爱
pivot_table = pd.pivot_table(df_clean, 
                           values='收入', 
                           index='城市',
                           columns='工龄',
                           aggfunc='mean',
                           fill_value=0)
print("\n透视表:\n", pivot_table)

# 时间序列分析 - 业务常用
df_clean['月份'] = df_clean['入职日期'].dt.month
monthly_avg_income = df_clean.groupby('月份')['收入'].mean().round(2)
print("\n月度平均收入:\n", monthly_avg_income)

# 实战示例：销售数据分析
# 假设我们有销售数据
sales_data = pd.DataFrame({
    '日期': pd.date_range(start='2023-01-01', periods=100, freq='D'),
    '产品': np.random.choice(['A', 'B', 'C'], 100),
    '数量': np.random.randint(1, 20, 100),
    '单价': np.random.choice([100, 150, 200], 100)
})
sales_data['销售额'] = sales_data['数量'] * sales_data['单价']

# 分析每个产品的销售情况
product_analysis = sales_data.groupby('产品').agg({
    '销售额': 'sum',
    '数量': 'sum',
    '单价': 'mean'
}).sort_values('销售额', ascending=False)

print("\n产品销售分析:\n", product_analysis)
```

### 3. Pandas核心技能总结
- **数据清洗**：`isnull()`, `fillna()`, `dropna()`
- **数据筛选**：布尔索引 `df[df['列']>值]`, `query()`方法
- **分组聚合**：`groupby()` + `agg()`（数据分析的黄金组合）
- **数据转换**：`apply()`, `map()`, `astype()`
- **时间处理**：`pd.to_datetime()`, `.dt`访问器
- **合并数据**：`pd.merge()`, `pd.concat()`

### 4. 最常用的5个Pandas操作（每天都要用）

```python
# 1. 查看数据概览
df.head()          # 前5行
df.info()          # 数据类型和内存使用
df.describe()      # 统计摘要

# 2. 处理缺失值
df.dropna()        # 删除缺失值
df.fillna(0)       # 用0填充
df['列'].fillna(df['列'].mean())  # 用均值填充

# 3. 条件筛选
df[df['年龄'] > 30]                # 基础筛选
df.query('年龄 > 30 & 城市=="北京"')  # query语法更简洁

# 4. 分组聚合
df.groupby('城市')['收入'].mean()  # 简单聚合
df.groupby(['城市', '部门']).agg({'收入': ['mean', 'sum'], '年龄': 'max'})  # 复杂聚合

# 5. 创建新列
df['收入/年龄'] = df['收入'] / df['年龄']  # 简单计算
df['年龄段'] = pd.cut(df['年龄'], bins=[0, 30, 40, 50, 100], labels=['青年', '壮年', '中年', '老年'])  # 分桶
```

## 🎯 一日速成计划（今天就能完成！）

### 上午（2小时）：NumPy
1. 创建不同类型的数组（一维、二维、随机数）
2. 练习向量化操作（+，-，*，/，**）
3. 尝试布尔索引（`arr[arr > 5]`）
4. 计算统计量（mean, std, min, max）

### 下午（3小时）：Pandas
1. 创建DataFrame（用字典）
2. 读取一个CSV文件（用Kaggle上的泰坦尼克号数据集）
3. 处理缺失值（isnull, fillna）
4. 筛选数据（条件筛选，query）
5. 分组聚合（groupby + agg）

### 晚上（1小时）：实战
```python
# 尝试这个完整示例 - 股票分析
import pandas as pd
import numpy as np

# 创建模拟股票数据
dates = pd.date_range(start='2023-01-01', end='2023-12-31', freq='B')  # 工作日
stock_data = pd.DataFrame({
    '日期': dates,
    '开盘价': np.random.uniform(95, 105, len(dates)),
    '收盘价': np.random.uniform(95, 105, len(dates)),
    '成交量': np.random.randint(100000, 500000, len(dates))
})
stock_data['收益率'] = (stock_data['收盘价'] - stock_data['开盘价']) / stock_data['开盘价']

# 分析
print("平均日收益率:", stock_data['收益率'].mean() * 100, "%")
print("最大单日涨幅:", stock_data['收益率'].max() * 100, "%")
print("成交量最大的5天:\n", stock_data.nlargest(5, '成交量')[['日期', '成交量', '收益率']])

# 按月分析
stock_data['月份'] = stock_data['日期'].dt.month
monthly_analysis = stock_data.groupby('月份').agg({
    '收益率': 'mean',
    '成交量': 'sum'
})
print("\n月度分析:\n", monthly_analysis)
```

## 💡 老师的终极忠告

1. **不要试图记住所有函数** - 只需记住核心5个，其他用时查文档
2. **遇到错误是好事** - 每次解决错误，你就又掌握了一个知识点
3. **从真实数据开始** - 用你自己的Excel数据，或者[Kaggle泰坦尼克数据集](https://www.kaggle.com/c/titanic/data)
4. **代码要像讲故事** - 好的Pandas代码应该是：读取数据 → 清洗 → 分析 → 可视化

**现在就行动**：复制上面的代码，一行一行运行，修改参数，看看结果如何变化。遇到不懂的函数，直接在Jupyter Notebook中输入`pd.read_csv?`查看帮助文档。

有任何问题，随时问我！数据科学之路，我陪你一起走。💪
