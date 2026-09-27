---
domain: bilibili.com
aliases: [B站, bilibili, 哔哩哔哩]
updated: 2026-07-19
---
## 平台特征
- 搜索页面（search.bilibili.com）是 Vue SPA，未登录时内容区不渲染，即使页面标题正常也不会展示视频列表
- 用户日常浏览器通常已登录，可利用 cookies 调用 API

## 有效模式
- **搜索 API（2026-07-19 验证）**：在已打开的 B 站页面内通过 fetch + `credentials: "include"` 调用搜索 API，可获取完整视频数据（含标题、UP主、播放量、描述、BV号等）
  - 端点：`https://api.bilibili.com/x/web-interface/search/all/v2?keyword=<URL编码关键词>&search_type=video&page=<页码>&order=totalrank`
  - 返回结构：`data.result` 数组，`result_type === "video"` 的条目下 `data` 字段为视频列表
  - 每页 20 条，支持多页翻页
  - 视频 URL 通过 bvid 构造：`https://www.bilibili.com/video/<bvid>/`
- 需要先在 B 站任意页面创建 tab，再用该 tab 发起 fetch（跨域携带 cookies）

## 已知陷阱
- 搜索结果页面（search.bilibili.com）未登录时内容区完全为空，DOM 中 `.search-page-wrapper` 无子元素（2026-07-19）
- 不要尝试直接解析搜索结果页 DOM，应走 API 接口
- 标题字段含 `<em class="keyword">` 高亮标签，需清理
- `description` 字段可能为 `"-"` 字符串，实为空值
