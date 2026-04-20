# Claude Code 分级记忆与记事本 Skill

为 [Claude Code](https://claude.com/claude-code) 提供**持久化分级记忆**和**提醒记事本**：会话启动时自动整理记忆边界、在对话里用人话增删提醒，不再让 Claude 每次把你当陌生人。

**English**: [README.md](README.md)

## 功能

- **分级记忆** — 重要度 (H/M/L) × 时效 (鲜明/精炼/归档)；常用配置过 30 天仍在鲜明区，一次性琐事尽早淘汰
- **周期触发** — 每天边界检查；每月 1 号做 `verified` 复查；每月 15 号 + 最后一天提取模式
- **记事本** — 对话里人话增删："5 月 10 号提醒我 X"、"X 搞定了"；支持 `[earliest:HH:MM]` 的时间段锁
- **多窗口去重** — 时间戳锁（默认 8 小时），同时开多个 CLI 窗口只报告一次，每多一个窗口省 ~300-500 tokens
- **零依赖** — hook 脚本只用 `bash` + `grep` + `date`。不需要 `jq`、不需要 Python

## 工作原理

每次 Claude Code 会话通过 SessionStart hook 注入两种之一：

1. **REQUIRED** — cooldown 窗口内第一个会话 → Claude 先输出分级检查报告再回答你的问题
2. **SKIP** — 另一个窗口刚做过 → Claude 直接回答你的问题

报告逻辑由 `MEMORY.md` 里的规则（分级策略 + Startup Protocol）和 `reminders.md` 里的条目共同驱动。

## 安装

### 1. 克隆仓库

```bash
git clone https://github.com/USER/claude-memory-reminder ~/.claude/skills/claude-memory-reminder
```

（可放任意位置；hook 脚本通过 `CMR_SKILL_DIR` 环境变量支持自定义路径。）

### 2. 部署 hook 脚本

```bash
mkdir -p ~/.claude/hooks
cp ~/.claude/skills/claude-memory-reminder/hooks/session-start.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/session-start.sh
```

### 3. 把 hook 注册到 settings.json

在 `~/.claude/settings.json` 顶级对象里加入以下字段（和已有 key 合并）：

```json
"hooks": {
  "SessionStart": [
    {
      "hooks": [
        { "type": "command", "command": "bash ~/.claude/hooks/session-start.sh" }
      ]
    }
  ]
}
```

> 安装脚本只输出上面的 JSON 供你粘贴，**不会自动改你的 `settings.json`**，避免破坏已有配置。

### 4. 初始化项目记忆目录

```bash
TARGET="$HOME/.claude/projects/你的项目/memory"
mkdir -p "$TARGET"
cp ~/.claude/skills/claude-memory-reminder/templates/MEMORY.md "$TARGET/"
cp ~/.claude/skills/claude-memory-reminder/templates/reminders.md "$TARGET/"
```

按需填写 `MEMORY.md` 里的 User Info / Preferences 区。

### 5.（可选）自定义参数

```bash
cd ~/.claude/skills/claude-memory-reminder
cp config.example.json config.json
# 编辑 config.json
```

### 6. 验证

新开一个 Claude Code 对话，Claude 应该一上来就输出类似：

```
[session-start] Today: 2026-04-20, Now: 10:47. REQUIRED: ...
分级检查报告:
  边界: 无跨线条目
  verified: 全部在期
  提取: 今日不触发
  提醒 (2): ⚠️ 今日 - 年度体检; 🔁 常驻 - 试试新记忆系统
  建议: 无
```

## 使用

直接用人话对 Claude 讲就行：

| 你说 | 结果 |
|------|------|
| "2026 年 5 月 10 号提醒我 X" | 写入 `[due: 2026-05-10][active] X` |
| "记得提醒我 X" | 写入 `[due: on-demand][active][created:TODAY] X` |
| "5 月 10 号中午 12 点以后提醒我 X" | 写入 `[due: 2026-05-10][earliest:12:00][active] X` |
| "每天提醒我 X 直到搞定" | 写入 `[due: daily-until-done][active] X` |
| "X 搞定了" / "X 做完了" | 对应条目标 `done` |
| "X 不做了" / "取消 X" | 对应条目直接删除 |

## 配置

`config.json` 所有字段可选，默认值见 `config.example.json`：

```json
{
  "cooldown_hours": 8,
  "ondemand_timeout_days": 14,
  "verified_refresh_day": 1,
  "extract_days": [15, "last"],
  "boundary_days": { "vivid": 7, "distilled": 30 }
}
```

只有 `cooldown_hours` 由 hook 自己读取（正则提取）。其他字段 Claude 在执行 Startup Protocol 时自己读取 JSON。

## 卸载

```bash
rm ~/.claude/hooks/session-start.sh
rm -f ~/.claude/memory/.last-reminded
# 手动删除 ~/.claude/settings.json 里的 "hooks" 块
rm -rf ~/.claude/skills/claude-memory-reminder
```

## 路线图

- [ ] 可选的"疑似完成"启发式判断（方案 B）：扫过去对话事件推断软完成信号
- [ ] 多项目记忆分发
- [ ] 浏览 Recent Memory 的 Web UI

## License

MIT — 见 [LICENSE](LICENSE)。
