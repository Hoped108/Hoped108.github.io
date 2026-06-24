# Hexo 和 npm 使用说明

本文是这个博客项目的日常使用说明。根目录 README 只保留快速入口，这里记录更完整的命令、目录规则和注意事项。

## 1. Hexo 是什么

Hexo 是一个基于 Node.js 的静态博客生成器。你写 Markdown，Hexo 读取 `source/`、`_config.yml` 和主题配置，然后生成 HTML/CSS/JS 静态文件。

流程可以理解为：

```text
Markdown 文章 + Hexo 配置 + 主题
        ↓
hexo generate
        ↓
public/ 静态网站
        ↓
hexo deploy
        ↓
GitHub Pages
```

Hexo 本身是 CLI 工具，常见命令包括：

```bash
hexo new
hexo generate
hexo server
hexo clean
hexo deploy
```

本项目通过 npm scripts 包装这些命令，所以日常优先使用 `npm run ...`。

## 2. npm 在这里负责什么

`npm` 负责两件事：

1. 安装和管理 Hexo 依赖。
2. 通过 `package.json` 里的 `scripts` 统一执行命令。

本项目的脚本在 [package.json](/home/ope/my-blog/package.json:5)：

```json
{
  "scripts": {
    "frontmatter": "sh tools/fix-front-matter.sh",
    "prebuild": "npm run frontmatter",
    "build": "hexo generate",
    "clean": "hexo clean",
    "predeploy": "npm run frontmatter",
    "deploy": "hexo clean && hexo generate && hexo deploy",
    "server": "hexo server"
  }
}
```

这里的 `prebuild` 和 `predeploy` 是 npm 的生命周期脚本。运行 `npm run build` 前，npm 会自动先运行 `npm run prebuild`；运行 `npm run deploy` 前，也会先运行 `npm run predeploy`。

## 3. 目录说明

```text
.
├── _config.yml                 # Hexo 站点总配置
├── package.json                # npm 脚本和依赖配置
├── source/                     # 博客源文件
│   ├── _posts/                 # 正式博客文章
│   ├── _drafts/                # 草稿目录，默认不发布，可能需要手动创建
│   ├── others/                 # 从 _posts 移出的非公开笔记，已被 Hexo/Git 忽略
│   ├── JavaNotes/              # 普通页面/笔记目录
│   └── mdBrochure/             # 普通页面/笔记目录
├── themes/butterfly/           # Butterfly 主题
├── public/                     # Hexo 生成出来的静态网站文件
├── tools/fix-front-matter.sh   # 自动补 Markdown front-matter 的脚本
├── docs/                       # 本项目说明文档
├── db.json                     # Hexo 缓存数据库
└── node_modules/               # npm 依赖
```

关键点：

- `source/_posts/` 是文章源文件目录，不是最终上传目录。
- `public/` 是生成后的静态网站目录。
- 部署时上传的是生成结果，不是 `_posts` 里的 Markdown 原文。
- 私密内容不要放进 `source/`。只要进入 `source/`，就有被生成和发布的风险。当前 `source/others/` 已被 `_config.yml` 的 `exclude`/`ignore` 和 `.gitignore` 忽略，用来临时存放从 `_posts` 移出的非公开笔记。

## 4. 常用命令

安装依赖：

```bash
npm install
```

自动补 Markdown front-matter：

```bash
npm run frontmatter
```

生成静态网站：

```bash
npm run build
```

本地预览：

```bash
npm run server
```

当前 `_config.yml` 配置的本地端口是 `5000`，访问：

```text
http://localhost:5000
```

清理缓存和生成文件：

```bash
npm run clean
```

部署到 GitHub Pages：

```bash
npm run deploy
```

当前 `npm run deploy` 的实际流程是：

```text
npm run frontmatter
hexo clean
hexo generate
hexo deploy
```

## 5. 写新文章

推荐用 Hexo 创建文章：

```bash
npx hexo new "文章标题"
```

Hexo 会在 `source/_posts/` 下面生成一篇 Markdown。

也可以手动创建：

```text
source/_posts/my-post.md
```

推荐文章格式：

```markdown
---
title: "文章标题"
date: 2026-05-02 12:00:00
tags:
  - note
categories:
  - 学习
---

# 文章标题

这里开始写正文。
```

Hexo 常用时间格式：

```text
YYYY-MM-DD HH:mm:ss
```

例如：

```text
2026-05-02 12:00:00
```

## 6. front-matter 是什么

front-matter 是 Markdown 文件开头的一段 YAML 配置，用来告诉 Hexo 这篇文章的标题、发布时间、标签、分类等信息。

最小示例：

```yaml
---
title: "Hello World"
date: 2026-05-02 12:00:00
---
```

常用字段：

```yaml
title: "文章标题"
date: 2026-05-02 12:00:00
updated: 2026-05-02 13:00:00
tags:
  - note
categories:
  - 学习
published: true
```

如果缺少正确的 front-matter，Hexo 可能把 Markdown 正文误当成 YAML 解析，从而出现 `YAMLException`。

## 7. 自动补 front-matter 脚本

本项目有一个脚本：

[tools/fix-front-matter.sh](/home/ope/my-blog/tools/fix-front-matter.sh:1)

它会扫描 `source/` 下的 `.md` 文件：

- 如果第一行是 `---`，认为已经有 front-matter，直接跳过。
- 如果没有 front-matter，就自动补 `title`、`date`、`tags`。
- `title` 优先从第一个一级标题 `# 标题` 提取。
- `date` 使用文件最后修改时间，格式是 `YYYY-MM-DD HH:mm:ss`。

自动补出来大概是：

```yaml
---
title: "从第一个一级标题提取"
date: 2026-05-02 12:00:00
tags:
  - note
---
```

注意：

- 这个脚本只处理“完全没有 front-matter”的文件。
- 已经有 front-matter 的文件不会被它修正。
- 不要把 `.sh` 文件放在项目根目录的 `scripts/` 里。Hexo 会把 `scripts/` 当成 JavaScript 插件目录加载。

## 8. 草稿、公开文章和私密内容

正式文章：

```text
source/_posts/
```

这里的 Markdown 会作为公开博客文章处理。

草稿：

```text
source/_drafts/
```

默认不发布。创建草稿：

```bash
npx hexo new draft "草稿标题"
```

预览草稿：

```bash
npx hexo server --draft
```

发布草稿：

```bash
npx hexo publish "草稿标题"
```

私密内容：

```text
private/
```

建议放在项目根目录的 `private/` 或项目外，不要放进 `source/`。如果以后把项目提交到 GitHub，还要确保 `private/` 被 `.gitignore` 忽略。

本项目还有一个已忽略目录：

```text
source/others/
```

它用于存放从 `_posts` 移出的非公开笔记。因为它在 `source/` 下，必须同时依赖 `_config.yml` 的 `exclude`/`ignore` 和 `.gitignore`，否则有被生成或提交的风险。

## 9. 配置文件

站点配置在：

```text
_config.yml
```

常用字段：

```yaml
title: 我的博客
subtitle: welcome to my website
description: 个人笔记
author: Hope
language: zh-CN
timezone: Asia/Shanghai
url: http://example.com
theme: butterfly
public_dir: public
```

如果部署到 GitHub Pages，建议把 `url` 改成真实地址：

```yaml
url: https://Hoped108.github.io
```

输出目录：

```yaml
public_dir: public
```

如果改成：

```yaml
public_dir: dist
```

Hexo 会把生成结果输出到 `dist/`。

部署配置：

```yaml
deploy:
   type: git
   repository: https://github.com/Hoped108/Hoped108.github.io.git
   branch: main
```

## 10. 推荐日常流程

写文章：

```bash
npx hexo new "文章标题"
```

构建检查：

```bash
npm run build
```

本地预览：

```bash
npm run server
```

确认没问题后部署：

```bash
npm run deploy
```

## 11. 常见问题

### `hexo generate` 和 `hexo deploy` 有什么区别？

`hexo generate` 只生成静态文件。

`hexo deploy` 负责部署。Hexo 官方也支持 `hexo deploy --generate` 或 `hexo deploy -g`，表示部署前先生成。

本项目已经把部署脚本包装成：

```text
hexo clean && hexo generate && hexo deploy
```

所以日常直接用：

```bash
npm run deploy
```

### 为什么 Markdown 会报 `YAMLException`？

通常是文件开头没有正确 front-matter，Hexo 把正文当成 YAML 解析了。

解决：

```bash
npm run frontmatter
npm run build
```

### 为什么 `scripts/` 目录不能放 shell 脚本？

Hexo 会把项目根目录的 `scripts/` 当成插件目录，并尝试加载里面的文件。`.sh` 文件会被当成 JavaScript 执行，导致 `SyntaxError`。

所以本项目的 shell 辅助脚本放在：

```text
tools/
```

### `_posts` 子目录能不能当 private？

不能。`source/_posts/` 是文章源目录，里面的内容默认会被当成公开文章处理。不要用 `_posts/private/` 这种路径保存隐私内容。

需要草稿用：

```text
source/_drafts/
```

真正私密的内容放项目外，或放 `private/` 并确保不会提交和部署。

## References

- Hexo Docs: Documentation  
  https://hexo.io/docs/

- Hexo Docs: Commands  
  https://hexo.io/docs/commands

- Hexo Docs: Writing  
  https://hexo.io/docs/writing

- Hexo Docs: Front-matter  
  https://hexo.io/docs/front-matter

- Hexo Docs: Configuration  
  https://hexo.io/docs/configuration

- npm Docs: scripts  
  https://docs.npmjs.com/cli/v11/using-npm/scripts

- GitHub Docs: Configuring a publishing source for your GitHub Pages site  
  https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
