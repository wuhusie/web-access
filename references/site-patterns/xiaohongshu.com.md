---
domain: xiaohongshu.com
aliases: [小红书, XHS, redbook, xhslink.com]
updated: 2026-09-15
---
## 平台特征
- 单页应用（SPA）。分享短链 `xhslink.com/...` 会 302 到 `xiaohongshu.com/login?redirectPath=<真实笔记URL>`，登录墙拦截。
- 真实笔记 URL 形如 `xiaohongshu.com/explore/<noteId>?...&xsec_token=...`，其中 `xsec_token` 为必需参数（来自分享链接），缺失会被拦截。直接把 login 页 `redirectPath` 里解码出的完整 URL 用 `/navigate` 打开即可绕过登录墙看正文。
- 评论区总数在 `.total`（如「共 136 条评论」）。

## 有效模式（已验证 2026-07-07）
- **正文**：`#detail-title` 标题、`#detail-desc` 正文、`.bottom-container .date` 发布信息。
- **评论层级结构**：
  - `.parent-comment` = 一个顶层评论块，其 `:scope > .comment-item` 是父评论，`.reply-container .comment-item` 是回复。
  - 单条 `.comment-item`：`.author .name` 作者、`.avatar a[data-user-id]` 用户ID、`.content .note-text` 内容、`.info .date` 日期（含地区后缀如「05-21山东」）、`.info .location` 地区、`.interactions .like .count` 点赞。
  - `id` 属性为 `comment-<commentId>`。
- **滚动容器是 `.note-scroller`**（不是 window/body），`sc.scrollTop=sc.scrollHeight` + `dispatchEvent(new Event('scroll',{bubbles:true}))` 触发顶层评论分页；到底出现 `.end-container` 文案「- THE END -」。
- **展开回复**：循环点击所有 `.show-more`（文案「展开 N 条回复」/「展开更多」），多轮直到 `.show-more` 数量为 0；最终 `.comment-item` 总数应等于 `.total` 的数字。

- **搜索（已验证 2026-09-15）**：`/new` 打开 `https://www.xiaohongshu.com/search_result?keyword=<urlencode>&source=web_search_result_notes`，等 ~4s 后首屏约 25 条。卡片 `section.note-item`，标题 `.title`，点赞 `.count`，链接 `a.cover`（形如 `/search_result/<noteId>?xsec_token=...`）。把路径改成 `/explore/<noteId>?xsec_token=<同一token>&xsec_source=pc_search` 即可打开正文；同一 tab 串行 navigate、每篇间隔 4-7s，连读 33 篇未触发风控。
- 笔记页互动数：`.engage-bar .like-wrapper .count` / `.collect-wrapper .count`。

## 已知陷阱
- **后台 tab（`document.hidden=true`）无法触发评论懒加载分页**：顶层评论会永远卡在首屏 10 条（20 项），`.list-container` 底部无加载哨兵。必须先把 tab 切到前台使 `document.visibilityState=visible`，原生 IntersectionObserver 才会分页。
  - proxy 无 activate 端点，Chrome 的 `/json/activate/<id>` 实测未改变可见性。可靠做法：`osascript` 让 `Google Chrome` activate 并将 `active tab index` 设为 URL 含 noteId 的那个 tab、`set index of w to 1`。这是本次唯一让分页生效的方法。
- `location.reload()` 与直接 `/navigate` 都能重新挂载，但都受上面「前台」限制。
- **展开回复会触发频率风控（`error_code=300013` "Too many requests"）**（2026-07-09 验证）：每点击一个「展开N条回复」都会发一次子评论 API 请求。短时间内累计过多请求（评论多、回复线程多的帖子尤甚）会被跳转到 `xiaohongshu.com/website-login/error?...error_code=300013`，**评论 DOM 被整体清空（`.comment-item` 归零）**。
  - **顶层评论的滚动分页不受此限**——只有「展开回复」的子评论请求会触发。滚动加载 77 条顶层从未被封。
  - 一旦被封需**冷却**才恢复；反复触发会**升级**封禁时长（从几十秒升到数分钟以上，甚至连点 2 下即封）。调试时切忌反复硬刚。
  - 可靠策略（已实现于 `xiaohongshu-scraper` skill）：**限速分批展开（每轮 ≤2-3 个）+ 每轮按 comment id 快照合并 + 被封则等冷却重开续跑（已完成线程用 id 跳过）**。fresh 状态下单轮可展开上百条回复；复位后 2-3 轮通常可补齐全部。
  - **无标题笔记**：部分笔记 `#detail-title` 为空（正文在 `#detail-desc`），命名/展示需兜底，不能假设 title 一定存在。

## 历史经验：创作者平台发布图文（2026-03-19，未复测）

以下流程来自 Git 历史中的旧版站点经验。选择器和平台行为可能已经变化，执行前必须先检查当前页面结构；不得直接把它当作已验证现状。

- 发布入口：`https://creator.xiaohongshu.com/publish/publish`。当时创作者平台与主站登录态不互通，需要单独扫码登录。
- 切换到“上传图文”：查找文字匹配“上传图文”的 `.creator-tab`，用 `el.click()`。
- 上传图片：用 `/setFiles` 设置 `input[type=file].upload-input`；当时支持多文件。
- 填写标题：目标为 `input.d-text[placeholder*="标题"]`。通过原生 `value` setter 写入，再派发 `input` 事件以触发 React 更新；字数限制以页面计数器为准。
- 填写正文：目标为 `.tiptap.ProseMirror`。当时可在 `focus()` 后用 `document.execCommand("insertText")` 写入；字数限制同样以页面计数器为准。
- 话题标签当时尚未解决：直接在正文末尾追加 `#标签名` 只会形成纯文本，可能需要逐字键盘事件或使用页面话题搜索控件。
- 发布按钮当时匹配 `button.bg-red.d-button:not(.upload-button)`；发布属于对外写操作，点击前必须展示最终内容并取得用户明确确认。
- 当时文件上传不能依靠脚本点击按钮调起文件对话框，`/setFiles`（`DOM.setFileInputFiles`）是可靠方式。
