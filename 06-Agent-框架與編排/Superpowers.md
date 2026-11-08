# Superpowers

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/obra/superpowers
- **作者發表文**：https://blog.fsck.com/2025/10/09/superpowers/

## 概述

Superpowers 是 Jesse Vincent（GitHub `obra`）與 Prime Radiant 團隊做的 coding agent「軟體開發方法論」：一組可組合的 skill，加上一段啟動指示，確保 agent 真的會用它們。和多數要你手動打 `/指令` 的 skill 組不同，Superpowers 的 skill **自動觸發**——agent 每接一個任務前都會先檢查有沒有相關 skill，README 的說法是「強制流程，不是建議」。

核心流程：agent 發現你要做東西時不會直接寫程式，而是先追問你真正要什麼、整理出 spec 分段給你看；你核准設計後，它寫出細到「一個熱心但沒品味、沒判斷力、不懂專案、討厭寫測試的初級工程師也能照做」的實作計畫（強調紅-綠 TDD、YAGNI、DRY）；你說「開始」後，它以 subagent-driven development 逐項派子 agent 實作並審查。README 稱 agent 照計畫自主工作幾個小時並不罕見。

查閱時（2026-11-09）GitHub 顯示約 314k stars、28k forks；最新 release 為 v7.0.2（2026-11-03），repo 建立於 2025-10。

## 核心功能／特色

### 基本流程（各 skill 會在對應時機自動啟動）

1. **brainstorming**：動手前用提問引出你要什麼、為什麼，再複述讓你修正；小改動在對話中確認，專案則產出可據以規劃的設計文件
2. **using-git-worktrees**：設計核准後開新分支的獨立 worktree，跑專案設定、確認測試基線乾淨
3. **writing-plans**：把工作拆成 2–5 分鐘的小任務，每項都有精確檔案路徑、完整程式碼與驗證步驟
4. **subagent-driven-development** 或 **executing-plans**：前者每項任務派新的子 agent、做完各自審查（最徹底）；後者在目前 session 依序實作、最後對整個分支審查一次（最省）
5. **test-driven-development**：強制紅-綠-重構——寫失敗測試、看它失敗、寫最少程式碼、看它通過、commit；**會刪掉先於測試寫出的程式碼**
6. **requesting-code-review**：任務之間依計畫審查、按嚴重度回報，嚴重問題會擋住進度
7. **finishing-a-development-branch**：全部完成後驗證測試，讓你選 merge／PR／保留／丟棄，並清掉 worktree

### Skill 庫（共 15 個）

| 類別 | Skill |
| --- | --- |
| 測試 | `test-driven-development`（含測試反模式參考） |
| 除錯 | `systematic-debugging`（四階段找根因）、`verification-before-completion`（確認真的修好）、`diagnosing-superpowers`（分析某個 session 裡 Superpowers 哪裡出錯，附逐行證據，可打包去識別化的回報） |
| 協作 | `brainstorming`、`writing-plans`、`executing-plans`、`dispatching-parallel-agents`、`requesting-code-review`、`receiving-code-review`、`using-git-worktrees`、`finishing-a-development-branch`、`subagent-driven-development`（兩階段審查：先查是否符合 spec，再查程式碼品質） |
| Meta | `writing-skills`（照最佳實踐寫新 skill，含測試方法）、`using-superpowers`（skill 系統導論） |

## 技術架構或運作原理

- 每個 skill 是 `skills/<名稱>/SKILL.md`，部分附參考檔與腳本（例如 brainstorming 的視覺輔助伺服器 `server.cjs`）
- 「自動觸發」靠一個 **SessionStart hook**（在啟動、`/clear`、compact 時執行）：讀入 `using-superpowers/SKILL.md` 注入 context，指示 agent 先找相關 skill 再動手；不支援 hook 的平台則靠該 skill 的 description 引導模型載入
- Skill 行為測試使用 [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/) 的 drill 評測工具；外掛基礎設施測試在 `tests/`

## 安裝與使用方式

每個 harness 要各自安裝。

```bash
# Claude Code（官方 marketplace）
/plugin install superpowers@claude-plugins-official
# 或用 Superpowers 自己的 marketplace
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# Gemini CLI
gemini extensions install https://github.com/obra/superpowers

# GitHub Copilot CLI
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace

# Cursor（Agent 對話中）
/add-plugin superpowers

# Devin CLI
devin plugins install obra/superpowers
```

Codex App／CLI、Grok Build CLI、Kimi Code 可從各自的官方外掛市集安裝；README 另列 Antigravity、Factory Droid、OpenCode、Pi、Qwen Code、Hermes Agent、Muse 的安裝方式。

裝好後不需要特別呼叫，直接描述要做的東西即可。若某次 session 表現怪異，對 agent 說「figure out what went wrong with superpowers in this session」會啟動 `diagnosing-superpowers`。

## 適用情境

- 想讓 agent 自主跑長時間的功能開發，同時保有「先設計、再計畫、TDD、逐項審查」的紀律
- 不想記一堆指令，希望流程自動套用
- 需要用 git worktree 隔離 agent 的工作分支
- 跨多種 coding agent 使用同一套方法論

## 授權與成本

- **授權**：MIT。
- **成本**：免費；Prime Radiant 另提供企業商業支援（需洽詢）。實際花費取決於所用 agent 與模型。

## 限制與注意事項

- **預設有使用量統計**：brainstorming 的選用視覺輔助功能會從 Prime Radiant 網站載入 logo，請求中帶有 Superpowers 版本號（README 表示不含專案、prompt 或 agent 資訊）。設環境變數 `SUPERPOWERS_DISABLE_TELEMETRY` 可關閉；也會遵守 Claude Code 的 `DISABLE_TELEMETRY` 與 `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`。
- 流程是強制的：小改動也可能先被拉去 brainstorming；TDD skill 會刪掉沒有先寫測試的程式碼。
- `subagent-driven-development` 每項任務都開新子 agent 並審查，token 用量高；想省可改用 `executing-plans`。
- SessionStart hook 每次啟動都會把 `using-superpowers` 注入 context。
- 專案一般不接受外部貢獻的新 skill，也不接受 agent 代寫、修別人回報問題的 PR。

## 相關工具

- [Matt Pocock Skills](Matt-Pocock-Skills.md)：同樣主打「先對齊 → spec → TDD → 審查」，但 skill 多為手動呼叫、刻意輕量
- [ECC](ECC.md)：規模大得多的 harness 系統（數百個 skill、agent、hooks、記憶與資安掃描）
- [pstack](pstack.md)：從調查到驗證的工作流程 skill 組，偏多模型審查

## 資料來源

- https://github.com/obra/superpowers
- https://raw.githubusercontent.com/obra/superpowers/main/README.md
- https://github.com/obra/superpowers/blob/main/hooks/session-start
- https://blog.fsck.com/2025/10/09/superpowers/
