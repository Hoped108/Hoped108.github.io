---
title: "🎨 快速上手Matplotlib和Scanpy"
date: 2026-05-02 14:48:18
tags:
  - note
---

# 🎨 快速上手Matplotlib和Scanpy

你好！既然你已经掌握了NumPy和Pandas的基础，接下来我们直接进入**数据可视化**和**单细胞数据分析**的核心工具。我会用最实用的代码示例，让你快速掌握这两个强大库的核心技能。

---

## 📈 Matplotlib - Python可视化基础

### 1. 为什么用Matplotlib？
- **Python可视化基础**：几乎所有高级可视化库（Seaborn, Plotly）都基于它
- **高度可定制**：从学术论文到商业报告，满足所有要求
- **与Pandas无缝集成**：`df.plot()`底层就是Matplotlib

### 2. 核心代码示例（直接运行！）

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# 基础设置（每次都要做！）
plt.style.use('seaborn-v0_8-whitegrid')  # 更美观的样式
plt.rcParams['font.size'] = 12          # 全局字体大小
plt.rcParams['figure.figsize'] = (10, 6)  # 默认图形大小

# 示例1：最简单的折线图（监控指标趋势）
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

plt.figure(figsize=(10, 6))  # 创建新图形
plt.plot(x, y1, 'b-', label='sin(x)', linewidth=2)  # 蓝色实线
plt.plot(x, y2, 'r--', label='cos(x)', linewidth=2)  # 红色虚线
plt.title('三角函数示例', fontsize=16)
plt.xlabel('X轴', fontsize=14)
plt.ylabel('Y值', fontsize=14)
plt.legend()  # 显示图例
plt.grid(True, linestyle='--', alpha=0.7)  # 网格线
plt.savefig('trig_plot.png', dpi=300, bbox_inches='tight')  # 保存高清图
plt.show()

# 示例2：散点图（查看变量关系）
np.random.seed(42)
x = np.random.normal(0, 1, 1000)
y = x * 0.5 + np.random.normal(0, 0.5, 1000)
colors = np.where(x > 0, 'red', 'blue')
sizes = np.abs(x) * 50

plt.figure(figsize=(10, 8))
plt.scatter(x, y, c=colors, s=sizes, alpha=0.6, edgecolors='w', linewidth=0.5)
plt.title('散点图：相关性分析', fontsize=16)
plt.xlabel('特征X', fontsize=14)
plt.ylabel('特征Y', fontsize=14)
plt.colorbar(label='颜色映射')  # 添加颜色条
plt.show()

# 示例3：直方图（数据分布）
data = np.random.normal(170, 10, 1000)  # 模拟身高数据

plt.figure(figsize=(10, 6))
plt.hist(data, bins=30, density=True, alpha=0.7, color='skyblue', edgecolor='black')
# 添加核密度估计
from scipy.stats import gaussian_kde
density = gaussian_kde(data)
xs = np.linspace(data.min(), data.max(), 200)
plt.plot(xs, density(xs), 'r-', linewidth=2, label='KDE')
plt.title('身高分布直方图 + 密度估计', fontsize=16)
plt.xlabel('身高(cm)', fontsize=14)
plt.ylabel('密度', fontsize=14)
plt.legend()
plt.show()

# 示例4：与Pandas集成（最常用！）
# 创建销售数据
dates = pd.date_range(start='2023-01-01', periods=12, freq='M')
sales = pd.DataFrame({
    '电子产品': np.random.randint(50, 150, 12),
    '服装': np.random.randint(30, 100, 12),
    '食品': np.random.randint(80, 200, 12)
}, index=dates)

plt.figure(figsize=(12, 7))
plt.plot(sales.index, sales['电子产品'], 'o-', label='电子产品', linewidth=2, markersize=8)
plt.plot(sales.index, sales['服装'], 's--', label='服装', linewidth=2, markersize=8)
plt.plot(sales.index, sales['食品'], 'd-.', label='食品', linewidth=2, markersize=8)
plt.title('月度销售趋势', fontsize=16)
plt.ylabel('销售额(万元)', fontsize=14)
plt.xticks(rotation=45)  # 旋转x轴标签
plt.legend(loc='best')
plt.tight_layout()  # 自动调整边距
plt.show()

# 示例5：子图（多图表在一个图中）
fig, axes = plt.subplots(2, 2, figsize=(15, 10))  # 2x2网格

# 左上：折线图
axes[0, 0].plot(x, y1, 'b-')
axes[0, 0].set_title('折线图')
axes[0, 0].grid(True)

# 右上：散点图
axes[0, 1].scatter(x, y1 + np.random.normal(0, 0.1, 100), alpha=0.6)
axes[0, 1].set_title('散点图')

# 左下：条形图
categories = ['A', 'B', 'C', 'D', 'E']
values = [23, 45, 12, 67, 34]
axes[1, 0].bar(categories, values, color='skyblue')
axes[1, 0].set_title('条形图')

# 右下：箱线图
data = [np.random.normal(0, std, 100) for std in range(1, 5)]
axes[1, 1].boxplot(data)
axes[1, 1].set_title('箱线图')
axes[1, 1].set_xticklabels(['Group 1', 'Group 2', 'Group 3', 'Group 4'])

plt.suptitle('子图示例', fontsize=18)
plt.tight_layout(rect=[0, 0, 1, 0.96])  # 为总标题留空间
plt.show()
```

### 3. Matplotlib核心技能总结
- **基础结构**：`figure`（画布）→ `axes`（坐标系）→ `plot`（绘图）
- **常用图表**：
  - `plt.plot()`：折线图（趋势分析）
  - `plt.scatter()`：散点图（关系分析）
  - `plt.hist()`：直方图（分布分析）
  - `plt.bar()`：条形图（类别比较）
  - `plt.boxplot()`：箱线图（异常值检测）
- **自定义关键**：
  - `plt.title()`, `plt.xlabel()`, `plt.ylabel()`：添加标签
  - `plt.legend()`：图例
  - `plt.grid()`：网格线
  - `plt.tight_layout()`：自动调整布局
- **保存图片**：`plt.savefig('filename.png', dpi=300, bbox_inches='tight')`

> 💡 **专业技巧**：使用`ax = plt.gca()`获取当前坐标轴，然后用`ax.set_...`方法进行精细控制，比`plt.set_...`更灵活！

---

## 🔬 Scanpy - 单细胞RNA测序分析利器

### 1. 为什么用Scanpy？
- **专为单细胞设计**：处理10X Genomics等平台产生的大规模单细胞数据
- **完整分析流程**：从原始数据到生物学洞见
- **高性能**：基于AnnData数据结构，优化内存使用
- **生态整合**：与Scanorama、CellRank等工具无缝协作

### 2. 核心代码示例（实验室日常使用版）

```python
import scanpy as sc
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 设置Scanpy默认参数（每次都要做！）
sc.settings.verbosity = 3  # 显示详细信息
sc.settings.figdir = './figures'  # 保存图片的目录
sc.set_figure_params(dpi=100, frameon=False, figsize=(4, 4), color_map='viridis')  # 图形参数

# 步骤1：加载数据（使用内置示例数据集）
adata = sc.datasets.pbmc3k()  # 3K PBMCs from 10x Genomics
print(f"数据形状: {adata.shape}")  # (细胞数, 基因数)
print(f"前5个基因: {adata.var_names[:5].tolist()}")
print(f"前5个细胞: {adata.obs_names[:5].tolist()}")

# 步骤2：质量控制 - 关键步骤！
# 计算每个细胞的统计量
adata.var['mt'] = adata.var_names.str.startswith('MT-')  # 标记线粒体基因
sc.pp.calculate_qc_metrics(adata, qc_vars=['mt'], percent_top=None, log1p=False, inplace=True)

# 绘制QC图
fig, axs = plt.subplots(1, 4, figsize=(16, 4))
sns.distplot(adata.obs['n_genes_by_counts'], kde=False, ax=axs[0])
axs[0].set_title('每个细胞的基因数')
sns.distplot(adata.obs['total_counts'], kde=False, ax=axs[1])
axs[1].set_title('每个细胞的总counts')
sns.scatterplot(x='n_genes_by_counts', y='total_counts', data=adata.obs, ax=axs[2], alpha=0.5)
axs[2].set_title('基因数 vs 总counts')
sns.scatterplot(x='n_genes_by_counts', y='pct_counts_mt', data=adata.obs, ax=axs[3], alpha=0.5)
axs[3].set_title('基因数 vs 线粒体基因比例')
plt.tight_layout()
plt.savefig('./figures/qc_metrics.png')
plt.show()

# 过滤低质量细胞
sc.pp.filter_cells(adata, min_genes=200)  # 保留至少200个基因的细胞
sc.pp.filter_cells(adata, max_genes=2500)  # 去除超过2500个基因的细胞（可能是双细胞）
adata = adata[adata.obs['pct_counts_mt'] < 5, :]  # 去除线粒体基因比例>5%的细胞
print(f"过滤后细胞数: {adata.n_obs}")

# 步骤3：数据预处理
sc.pp.normalize_total(adata, target_sum=1e4)  # 标准化到10,000 counts/细胞
sc.pp.log1p(adata)  # log(1+x)变换
sc.pp.highly_variable_genes(adata, min_mean=0.0125, max_mean=3, min_disp=0.5)  # 识别高变基因
sc.pl.highly_variable_genes(adata, save='_hvg.png')  # 保存高变基因图

# 仅保留在下游分析中使用的高变基因
adata = adata[:, adata.var['highly_variable']]

# 步骤4：降维
sc.pp.scale(adata, max_value=10)  # 标准化到均值为0，方差为1
sc.tl.pca(adata, svd_solver='arpack')  # PCA
sc.pl.pca(adata, color='CST3', save='_pca.png')  # 按基因着色
sc.pl.pca_variance_ratio(adata, log=True, save='_variance.png')  # 解释方差比例

# 步骤5：邻居图和UMAP
sc.pp.neighbors(adata, n_neighbors=10, n_pcs=40)  # 基于PCA结果构建KNN图
sc.tl.umap(adata)  # UMAP降维
sc.pl.umap(adata, color=['CST3', 'NKG7', 'PPBP'], save='_umap_genes.png')  # 按基因着色

# 步骤6：聚类
sc.tl.leiden(adata, resolution=0.5)  # Leiden聚类
sc.pl.umap(adata, color='leiden', legend_loc='on data', title='细胞聚类', save='_umap_clusters.png')

# 步骤7：标记基因识别
sc.tl.rank_genes_groups(adata, 'leiden', method='wilcoxon')  # 差异表达分析
sc.pl.rank_genes_groups(adata, n_genes=20, sharey=False, save='_markers.png')  # 保存标记基因图

# 步骤8：注释细胞类型（基于标记基因）
cell_type_map = {
    '0': 'CD4 T cells',
    '1': 'CD14+ Monocytes',
    '2': 'B cells',
    '3': 'CD8 T cells',
    '4': 'NK cells',
    '5': 'FCGR3A+ Monocytes',
    '6': 'Dendritic cells',
    '7': 'Megakaryocytes'
}
adata.obs['cell_type'] = adata.obs['leiden'].map(cell_type_map)

# 可视化细胞类型
sc.pl.umap(adata, color='cell_type', legend_loc='on data', frameon=False, 
           title='细胞类型注释', save='_umap_celltypes.png')

# 步骤9：差异表达分析 - 比较两个细胞群
sc.tl.rank_genes_groups(adata, 'cell_type', groups=['CD4 T cells'], 
                        reference='CD8 T cells', method='wilcoxon')
sc.pl.rank_genes_groups_heatmap(adata, groups='CD4 T cells', n_genes=10, 
                                groupby='cell_type', show_gene_labels=True, 
                                save='_diff_expr_heatmap.png')

# 步骤10：保存结果
adata.write('./results/pbmc3k_processed.h5ad')  # 保存处理后的数据
```

### 3. Scanpy核心工作流总结
1. **数据加载**：`sc.datasets.pbmc3k()`或`sc.read_10x_h5()`
2. **质量控制**：
   - `sc.pp.calculate_qc_metrics()`
   - `sc.pp.filter_cells()`, `sc.pp.filter_genes()`
3. **预处理**：
   - `sc.pp.normalize_total()`
   - `sc.pp.log1p()`
   - `sc.pp.highly_variable_genes()`
4. **降维**：
   - `sc.pp.scale()`
   - `sc.tl.pca()`
5. **可视化**：
   - `sc.tl.umap()`
   - `sc.pl.umap()`
6. **聚类**：
   - `sc.pp.neighbors()`
   - `sc.tl.leiden()`
7. **标记基因**：
   - `sc.tl.rank_genes_groups()`
   - `sc.pl.rank_genes_groups()`

### 4. 专业技巧
- **AnnData结构**：`adata.X`（数据矩阵），`adata.obs`（细胞元数据），`adata.var`（基因元数据）
- **批量效应校正**：`sc.external.pp.harmony_integrate()`
- **轨迹分析**：`sc.tl.dpt()`（扩散伪时间）
- **细胞通讯**：与CellPhoneDB或NicheNet整合
- **交互式探索**：`sc.external.pl.interactive()`（基于IPywidgets）

> 💡 **实验室经验**：在开始分析前，先用`adata.obs['sample'].value_counts()`检查批次效应，这会节省你90%的后续麻烦！

---

## 🚀 一日速成计划（今天就能实践！）

### 上午（2小时）：Matplotlib
1. 运行示例1-3，修改参数看效果
2. 用自己的数据（或Pandas DataFrame）创建一个折线图和散点图
3. 尝试自定义：修改颜色、标签、标题、保存为PNG

### 下午（3小时）：Scanpy
1. 安装Scanpy：`pip install scanpy pandas numpy matplotlib seaborn`
2. 运行PBMC3K示例，确保每一步理解
3. 重点理解：QC过滤、标准化、降维、聚类这四个核心步骤
4. 尝试修改聚类分辨率（`resolution`参数），观察UMAP变化

### 晚上（1小时）：整合应用
```python
# 完整示例：从单细胞数据到出版级图表
import scanpy as sc
import matplotlib.pyplot as plt
import seaborn as sns

# 1. 加载并处理数据
adata = sc.datasets.pbmc3k_processed()  # 已处理的PBMC数据

# 2. 创建出版级UMAP
fig, ax = plt.subplots(figsize=(8, 6), dpi=300)
sc.pl.umap(adata, color='louvain', ax=ax, show=False, 
           frameon=False, size=30, palette='tab20')
ax.set_title('PBMC细胞类型', fontsize=16, fontweight='bold')
ax.set_xlabel('UMAP1', fontsize=14)
ax.set_ylabel('UMAP2', fontsize=14)
plt.tight_layout()
plt.savefig('./figures/umap_publication.png', dpi=300, bbox_inches='tight')
plt.show()

# 3. 创建标记基因小提琴图
markers = {'CD4 T cells': ['IL7R', 'CCR7'], 
           'CD8 T cells': ['CD8A', 'CD8B'],
           'B cells': ['MS4A1', 'CD79A']}
fig, axes = plt.subplots(2, 3, figsize=(15, 8), dpi=150)
axes = axes.flatten()

for i, (cell_type, genes) in enumerate(markers.items()):
    for j, gene in enumerate(genes):
        idx = i*2 + j
        if idx >= len(axes): break
        
        ax = axes[idx]
        sc.pl.violin(adata, gene, groupby='louvain', ax=ax, show=False)
        ax.set_title(f'{cell_type}: {gene}', fontsize=12)
        ax.set_ylabel('表达量', fontsize=10)
        ax.set_xlabel('细胞群', fontsize=10)
        ax.tick_params(axis='x', rotation=45)

plt.tight_layout()
plt.savefig('./figures/violin_markers.png', dpi=300, bbox_inches='tight')
plt.show()
```

## 💡 老师的终极建议

1. **Matplotlib**：
   - 从`plt.style.available`中选择一个你喜欢的样式
   - 使用`plt.tight_layout()`避免标签被裁剪
   - 保存图片时用`dpi=300`满足出版要求

2. **Scanpy**：
   - 每次处理新数据集都从QC开始，不要跳过！
   - 聚类分辨率（resolution）是关键参数，需要反复调整
   - 保存中间结果：`adata.write('checkpoint.h5ad')`

3. **学习资源**：
   - Matplotlib：[官方教程](https://matplotlib.org/stable/tutorials/index.html)
   - Scanpy：[Scanpy教程](https://scanpy.readthedocs.io/en/stable/tutorials.html)
   - 实战数据：[10x Genomics数据集](https://support.10xgenomics.com/single-cell-gene-expression/datasets)

**记住**：在数据科学中，**可视化是沟通的桥梁**。再好的分析，如果没有清晰的可视化，也无法传达价值。而Scanpy则是打开单细胞世界大门的钥匙，每天都有新的生物学发现通过它被揭示。

现在就开始动手！复制代码，修改参数，观察变化。遇到错误不要怕，这是学习的一部分。有任何问题，随时问我！🔬✨