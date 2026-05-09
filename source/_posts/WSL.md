---
title: "WSL"
date: 2026-05-02 14:48:18
tags:
  - note
---

# WSL安装和使用
## 前置处理
- 先打开cpu虚拟化，可查看任务处理器->性能->cpu虚拟化（已启用/...）
- 搜索栏->功能->打开适用于Linux的Windows子系统，以及虚拟机平台

## win11 快速处理wsl无法走代理
win + s 代开wsl setting->网络->网络模式，将NAT修改成mirrored，这样，wsl就不会有自己的ip，而是镜像主机的ip

## other
官方文档 ： https://learn.microsoft.com/en-us/windows/wsl/install
