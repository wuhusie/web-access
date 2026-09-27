# Local fork maintenance

This installation is a maintained Codex-specific fork rather than an unmodified
upstream checkout.

## Remotes

- `origin`: `git@github.com:wuhusie/web-access.git` — local customizations and backup
- `upstream`: `https://github.com/eze-is/web-access` — original project updates

Never replace this directory with a fresh clone and never use `git reset --hard`
to update it. Both operations can discard the Codex-specific commits.

## Known consumers

The following local skills require this skill's CDP proxy:

- `arxiv-translator`: opens `hjfy.top`, performs authenticated same-origin status
  and file API requests, then downloads the translated PDF.
- `xiaohongshu-scraper`: uses logged-in Chrome, DOM evaluation, foreground tab
  loading, comment expansion, rate-limit detection, and structured extraction.

Removing or incompatibly changing the proxy requires end-to-end verification of
both consumers.

## Tracked local site knowledge

The personal fork intentionally tracks these Codex-specific site patterns even
though upstream ignores `references/site-patterns/*.md`:

- `references/site-patterns/bilibili.com.md`
- `references/site-patterns/waimai.meituan.com.md`
- `references/site-patterns/xiaohongshu.com.md`

The explicit negations in `.gitignore` protect these files from disappearing on
a fresh clone. Review their `updated` dates before use because site behavior and
selectors can drift.

## Updating from upstream

Run from this repository:

```bash
scripts/update-from-upstream.sh
```

The script refuses to run with uncommitted changes, fetches `upstream`, and uses
a normal Git merge. Conflicts are left for explicit review instead of overwriting
local files. After testing the two consumers, publish the merged result with:

```bash
scripts/update-from-upstream.sh --push
```

Keep local changes separated into focused commits so upstream conflicts remain
easy to understand.
