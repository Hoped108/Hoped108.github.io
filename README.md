# My Hexo Blog

这是一个 Hexo 静态博客项目，用来把 Markdown 笔记生成成可以部署到 GitHub Pages 的静态网站。

## 快速开始

安装依赖：

```bash
npm install
```

生成静态网站：

```bash
npm run build
```

本地预览：

```bash
npm run server
```

部署：

```bash
npm run deploy
```

## 重要路径

```text
source/_posts/       # 正式博客文章
source/_drafts/      # 草稿，默认不发布，可能需要手动创建
source/others/       # 从 _posts 移出的非公开笔记，已被 Hexo/Git 忽略
public/              # Hexo 生成后的静态网站文件
tools/               # 本项目的辅助脚本
docs/                # 项目使用说明
_config.yml          # Hexo 站点配置
package.json         # npm 脚本配置
.gitignore           # Git 忽略规则
```

私密内容不要放进 `source/`，尤其不要放进 `source/_posts/`。放进 `source/` 的内容有被生成和发布的风险。
`.gitignore` 已忽略 `node_modules/`、`public/`、`db.json`、`.deploy_git/`、`.codex`、`private/` 和 `source/others/` 等本地或生成内容。

## 使用说明

详细说明见：

[docs/hexo-npm-usage.md](/home/ope/my-blog/docs/hexo-npm-usage.md)

这篇文档包含：

- Hexo 和 npm 的关系
- 常用命令
- Markdown front-matter 格式
- 自动补 front-matter 脚本
- 草稿和私密内容处理
- 部署流程
- 官方参考链接
