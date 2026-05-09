---
title: "BTree"
date: 2026-05-02 14:48:18
tags:
  - note
---

# B树
B树是一个多路查找树，类似BST（二叉搜索树），但是每一个节点可以有多个分支，多个节点值。
**节点最大的孩子数目称为B树的阶**（order）
## B树性质
- 分支数比节点值个数多一，即每个非根节点有k-1个元素，k个孩子，[m/2]<=k<=m
- 根节点要么是叶节点没有孩子，要么至少有两棵子树
```cpp
//非STL实现
class BTreeNode{
public:
    int* keys;
    BTreeNode** children;
    bool isLeaf;
    int n_keys;
    int order;

    BTreeNode(int order,bool isLeaf) : order(order),isLeaf(isLeaf){
        keys = new int[order-1];
        children = new BTreeNode*[order-1];
        n_keys = 0;
    }
};
```

## B树构建
构建功能有插入和分裂两个操作，当某个节点的元素值个数达到阶数-1个时，就会分裂
e.g. **三阶B树** 
```md
    5
  /   \   插入9，此时5的child[1]->n_keys == 3 - 1,此时就需要分裂
3 4   6 7 
``` 
```md    
        7
       /  \
6 7 ->6   [9] 此时9就将插入到7的右边，7就放置到5的数组里面
```

- 根节点是叶节点 -> 逐个插入 -> 超过最大数量 -> 分裂 （根节点变成非叶节点）
- 插入值先经过根节点的比较，找到合适的子树下标idx，如果child的元素数量达到上限，就先分裂
- 找到idx之后就递归node->child[idx](插入函数)，直到是叶节点再插入
