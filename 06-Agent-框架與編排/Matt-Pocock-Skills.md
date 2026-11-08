# Matt Pocock Skills（mattpocock/skills）

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/mattpocock/skills
- **skills.sh 頁面**：https://skills.sh/mattpocock/skills

## 概述

TypeScript 教育者 Matt Pocock（Total TypeScript、AI Hero）公開的個人 agent skill 組，標語是「Skills for Real Engineers」——用來做真正的工程，而不是 vibe coding。README 的立場是：GSD、BMAD、Spec-Kit 這類方法想「接管整個流程」，結果拿走了使用者的控制權、流程出錯也很難修；這套 skill 則刻意做得小、好改、可組合，不綁定模型。

整套 skill 圍繞作者觀察到的四種 coding agent 失敗模式設計：

| 問題 | 解法 |
| --- | --- |
| Agent 沒做你想要的（雙方沒對齊） | `/grill-me`、`/grill-with-docs`：先讓 agent 反覆追問，把設計樹的每個分支問清楚 |
| Agent 太囉嗦（不懂專案術語） | `/grill-with-docs`、`domain-modeling`：建立共用語言，寫進 `GLOSSARY.md` 與 ADR |
| 程式碼不能動（沒有回饋迴圈） | `tdd`（紅-綠-重構）、`diagnosing-bugs`（逐階段把關的除錯迴圈） |
| 程式碼變成一團泥（熵增太快） | `to-spec`、`codebase-design`、`/improve-codebase-architecture`：以「深模組」思路持續投資設計 |

查閱時（2026-11-09）GitHub 顯示約 318k stars、26.6k forks；最新 release 為 v1.3.2（2026-10-29），repo 建立於 2026-02。

## 核心功能／特色

Skill 分成兩種：**使用者呼叫**（只有你打 `/xxx` 才會執行，負責編排流程）與**模型呼叫**（agent 判斷任務合適時會自己用，裝的是可重複使用的紀律）。使用者呼叫的 skill 可以叫用模型呼叫的 skill，但不會叫用另一個使用者呼叫的 skill。

### Engineering（每天寫程式用）

**使用者呼叫**
- `ask-matt`：問「我現在該用哪個 skill／流程」的路由器
- `grill-with-docs`：追問式對齊，同時建立專案的領域模型、更新 `GLOSSARY.md` 與 ADR
- `triage`：用一個狀態機推進 issue 分流
- `improve-codebase-architecture`：掃描 codebase 找可以「加深」的模組，輸出 HTML 報告，再針對你挑的一項追問
- `setup-matt-pocock-skills`：每個 repo 跑一次，設定 issue tracker、分流標籤、文件位置
- `to-spec` / `to-tickets`：把對話整理成 spec 發到 issue tracker；把 spec 拆成標明阻擋關係的 tracer-bullet 工單
- `implement` / `implement-spec`：照 spec 或工單實作，在約定好的接縫跑 `tdd`，最後 `code-review`；`implement-spec` 會在整合分支上用多個子 agent 平行處理可開工的工單
- `wayfinder`：規劃一個 session 裝不下的大工作，用 issue tracker 上的決策工單當共用地圖
- `retro`：session 結束後建議如何改善 agent 的工作環境（導覽、自動檢查、規範、steering 檔）

**模型呼叫**
- `prototype`：做拋棄式原型回答設計問題（單一 HTML 檔，或同一路由下可切換的多個 UI 變體）
- `diagnosing-bugs`：重現（先做出會變紅的回饋迴圈）→ 縮小 → 假設 → 加探針 → 修 → 回歸測試
- `research`：以背景 agent 查高可信度的一手來源，寫成附引用的 Markdown 檔
- `tdd`、`domain-modeling`、`codebase-design`（深模組的共用詞彙）
- `code-review`：兩軸審查——**Standards**（是否符合 repo 規範與 Fowler 程式碼異味基準）與 **Spec**（是否忠實實作原始需求），兩個子 agent 平行跑、互不干擾
- `pr`：PR 內文的格式（最小視覺摘要、前後證據、單向門／雙向門與影響範圍）
- `wizard`：產生互動式 bash 精靈，引導人類完成只有人能做的步驟（開基礎設施、設 CI secret、一次性遷移）

### Productivity（不限於寫程式）

- 使用者呼叫：`grill-me`（作者說最受歡迎）、`handoff`（把對話壓成交接文件）、`teach`（以目前目錄當狀態，跨 session 教你新技能）、`to-questionnaire`（把需要別人回答的決策寫成問卷）、`wait-what`（訊息看不懂時讓 agent 用你的術語重講）
- 模型呼叫：`grilling`（多個 skill 共用的追問原語）、`writing-for-agents`（怎麼寫 skill、AGENTS.md／CLAUDE.md 等給 agent 讀的文件）

### 其他（不在 plugin 內）

- `misc/`：`git-guardrails-claude-code`（用 Claude Code PreToolUse hook 擋下 `git push`、`reset --hard`、`clean -f`、`branch -D` 等危險指令）、`setup-pre-commit`、`migrate-to-shoehorn`、`scaffold-exercises`
- `in-progress/`：beta 版，如 `claude-handoff`（用 `claude --bg` 把對話交給背景 agent 接手）、`loop-me`、寫作系列 `writing-beats`／`writing-fragments`／`writing-shape`；作者明言可能隨時變動或消失

## 技術架構或運作原理

- 每個 skill 是一個資料夾，主體為 `SKILL.md`（純 Markdown 指示，沒有執行期程式），部分附參考檔或腳本（例如 git-guardrails 的 `block-dangerous-git.sh`）
- `.claude-plugin/plugin.json` 列出 plugin 版收錄的 27 個 skill（engineering 20 個、productivity 7 個）
- 檢查 repo 時未發現遙測或分析程式碼
- 多數 engineering skill 依賴 `setup-matt-pocock-skills` 寫下的設定（issue tracker 種類、分流標籤、文件放哪），可用 GitHub、GitLab、本機檔案或自行描述的 tracker

## 安裝與使用方式

plugin 會自動更新；skills.sh 則把可編輯的檔案複製進專案、需手動更新。每個 agent 擇一即可，兩種都裝會讓每個 skill 出現兩次。

```bash
# Claude Code
claude plugin install mattpocock-skills@claude-plugins-official

# Codex
codex plugin marketplace add mattpocock/skills
codex plugin add mattpocock-skills@mattpocock

# GitHub Copilot（CLI）
copilot plugin marketplace add mattpocock/skills
copilot plugin install mattpocock-skills@mattpocock

# Gemini CLI（手動更新）
gemini skills install https://github.com/mattpocock/skills.git --path skills/engineering
gemini skills install https://github.com/mattpocock/skills.git --path skills/productivity

# 其他 agent（Cursor、OpenCode、Windsurf、Amp…）或想要可編輯檔案
npx skills@latest add mattpocock/skills -a <agent>

# 單獨安裝 in-progress 或 misc 的 skill
npx skills@latest add mattpocock/skills --skill=<name>
```

裝好後在每個 repo 先跑一次 `/setup-matt-pocock-skills`，之後典型流程是：`/grill-with-docs` 對齊 → `/to-spec` → `/to-tickets` → `/implement`（內含 `tdd` 與 `code-review`）。

## 適用情境

- 想讓 coding agent 動手前先把需求問清楚，減少「做出來不是我要的」
- 想替專案建立術語表與 ADR，讓 agent 用一致的名詞命名與溝通
- 想要固定的 TDD 與除錯紀律，但不想被一整套重量級框架綁住
- 想定期找出 codebase 可以重構成深模組的地方
- 當作撰寫自家 skill 的範本（skill 短小、純 Markdown、容易改）

## 授權與成本

- **授權**：MIT。
- **成本**：免費；實際花費取決於所用 agent 與模型。

## 限制與注意事項

- 是作者個人的工作方式，流程偏重 issue tracker 與 spec／工單，小型或一次性任務可能顯得繁瑣。
- `implement-spec` 會平行啟動多個子 agent，token 用量較高。
- `in-progress/` 的 skill 不保證穩定；`misc/` 與 `in-progress/` 不會隨 plugin 安裝。
- `improve-codebase-architecture` 作者自己說明是「調查而非救援」：會列出候選，不會替你整理一團泥的舊 codebase。
- README 附作者電子報連結（AI Hero），非使用必要。

## 相關工具

- [Superpowers](Superpowers.md)：類似的「先設計 → 計畫 → TDD → 審查」流程，但 skill 會自動觸發、強制套用
- [ECC](ECC.md)：規模大得多的 harness 系統（數百個 skill、agent、hooks、記憶與資安掃描）
- [pstack](pstack.md)：同樣是「從調查到驗證」的 coding agent 工作流程 skill 組，偏多模型審查
- [desloppify](desloppify.md)：專注整理 AI 生成程式碼、追品質分數
- [yao-meta-skill](yao-meta-skill.md)：想自己製作、評測、打包 skill 時參考

## 資料來源

- https://github.com/mattpocock/skills
- https://raw.githubusercontent.com/mattpocock/skills/main/README.md
- https://github.com/mattpocock/skills/blob/main/.claude-plugin/plugin.json
- https://github.com/mattpocock/skills/tree/main/skills/in-progress
