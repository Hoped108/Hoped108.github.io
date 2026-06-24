---
title: "intellj里面打包成JAR文件（Main文件包含所有类）"
date: 2026-05-02 14:48:18
tags:
  - note
---

# intellj里面打包成JAR文件（Main文件包含所有类）
- `tankbattle`
## 备份
先打开和项目同级的目录，然后复制项目粘贴到同一级文件夹里面备份

## 新建java类
然后在项目src里面新建java类

## 剪切到新建类
直接ctrl + x到新建类

## git上传
``git add .``向缓存区上传所有修改文件
``git commit -m "你的提交说明" `` 提交说明
``git push ``推送到远程仓库
``git pull`` 提交之前可以先拉取别人的最新修改

## 创建jar
点击intellj左上角的file->project structrue->Aritfacts->JAR->From modules with dependcies
然后再copy to the output directory and link via manifest
Main Class 选择Main（一定要有`public static void main(String[] args)` ）->apply-ok
然后在左上角Build->Build Artifacts->build

## 附：jar转msi
要求：jdk14+（14以上才会有jpackage）
生成jar运行之后没问题，就直接使用wix打包
先`cd 目录`(和jar同级的)，然后使用
```shell
jpackage ^
  --type msi ^
  --name ... ^
  --input . ^
  --main-jar 命名.jar ^
  --dest . ^
  --win-shortcut ^
  --win-menu ^
  --win-dir-chooser

```