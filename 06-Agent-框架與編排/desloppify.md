# desloppify

- **分類**：Agent 框架與編排 / Coding agent 外掛（程式碼品質）
- **連結**：https://github.com/peteromallet/desloppify
- **PyPI**：https://pypi.org/project/desloppify/
- **介紹文章**：https://www.opensourceprojects.dev/post/desloppify

## 原清單說明

（投稿時僅附連結，無原清單說明）

> **查證結果**：與 GitHub API、README、PyPI 相符。repo 描述為 *Agent harness to make your slop code well-engineered and beautiful.*，作者 Peter O'Malley。授權為作者自訂的 Open Source Native License（OSNL）v0.2，GitHub 顯示為 "Other"，不是 OSI 認可的開源授權。查詢當下（2026-11-06）約 4.1k 顆星、310 forks、312 個 open issues + PR。最新 release 與 PyPI 版本為 v1.0（2026-05-13），main 分支最後一次 commit 也在同一天；repo 建立於 2026-02-11。

## 概述

desloppify 是給 AI coding agent 用的「程式碼品質 harness」：讓 agent 掃描整個 codebase、得到一個 0–100 的健康分數，再照一份排好優先順序的佇列一項一項修，直到分數到達你設定的目標。它針對 vibe coding 產生的程式碼隨時間「爛掉」的問題——不只是沒用到的 import，還有抽象層不再合理、命名漂移、錯誤處理三種寫法並存這類結構性問題。

它結合兩種分析：機械式偵測（死碼、重複、複雜度、測試缺口等）與 LLM 主觀審查（命名、抽象、模組邊界、錯誤處理一致性等）。狀態存在 `.desloppify/`，所以可以跨多個 session 慢慢推進。作者的說法是分數 98 以上應該對應到「資深工程師會說漂亮」的 codebase，並且刻意設計成難以靠壓警告「刷分」。

## 核心功能／特色

- **一個可追的分數**：整體分數由機械式與主觀兩池混合，另有 strict（wontfix 也算未解決，官方建議以此為目標）、objective（只算機械式）、verified（只算確認修好的）等分數。
- **固定的修正迴圈**：`next` 給出現在該修哪一項、在哪個檔案、修完要下的 `resolve` 指令；修完再 `next`，反覆進行。
- **Triage 與計畫**：agent（或你）先觀察發現、歸納主題與根因、把問題分群，排出執行佇列；可用 `plan` / `plan queue` 調整順序。
- **防刷分**：標 wontfix 會拉大寬鬆分數與 strict 分數的差距；重新審查可能讓分數下降；審查分數剛好等於目標值時會自動重設，並提供「盲審」流程。
- **Autofix**：部分機械式問題可用 `desloppify autofix <fixer> --dry-run` 預覽後自動修。
- **成績卡徽章**：掃描會產生 scorecard 圖，可放在 GitHub 個人頁或 README。
- **29 種語言**：TypeScript、Python、C#、C++、Dart、GDScript、Go、Rust 有完整外掛深度；Ruby、Java、Kotlin 等另外 21 種只有通用 linter + tree-sitter 支援。C++ 以 `compile_commands.json` 為主，只有 Makefile 時退回盡力而為的 include 掃描。
- **多種 agent**：`desloppify update-skill <agent>` 安裝對應的工作流程說明，README 列出 claude、cursor、codex、copilot、droid、windsurf、gemini、rovodev；docs 另有 Amp、Hermes、opencode、Qwen 的說明。

## 技術架構或運作原理

流程是 scan → score → review → triage → execute → rescan：

1. **Scan**：各語言的機械式偵測器跑過整個 codebase，問題依維度（File health、Code quality、Duplication、Test health、Security）計分。每個維度分數 = (檢查總數 − 加權失敗數) ÷ 檢查總數 × 100；檢查數少於 200 的維度會依比例降低權重。
2. **Review**：LLM 依主觀維度打 0–100 分，權重最高的是 High／Mid elegance（各 22），其次 Low elegance、Contracts、Type safety（各 12）、Design coherence（10）等。審查有幾條路徑：Codex 或 Rovo Dev 自動跑批次、Claude Code 用 `review --prepare` 後開平行子 agent 再 `--import`、外部 session，或手動逐維度審查後匯入。
3. **計分**：機械式池占 25%、主觀池占 75%。還沒跑主觀審查時分數 100% 來自機械式；主觀部分從 0% 起算，所以第一次審查前後分數會大幅變動。
4. **Triage → Execute → Rescan**：排出執行佇列、照 `next` 修、重掃確認並抓連鎖影響，再進入下一輪。

## 安裝與使用方式

需要 Python 3.11 以上。README 的用法是把一段 prompt 貼給你的 agent，讓它自己安裝與執行；重點指令如下：

```sh
pip install --upgrade "desloppify[full]"
desloppify update-skill claude      # 換成你的 agent：cursor、codex、copilot、droid、windsurf、gemini、rovodev
echo ".desloppify/" >> .gitignore   # 本機狀態，不要 commit

desloppify exclude <path>           # 先排除 vendor、build 輸出、生成碼、worktree 等
desloppify scan --path .
desloppify next                     # 修 → resolve → next，反覆
```

- 前後端分屬不同目錄時，分別掃描：`desloppify --lang typescript scan --path ./frontend`、`desloppify --lang python scan --path ./backend`。不要掃包含兩者的上層目錄。
- CI 用法（當成整個 codebase 的健康門檻，不是只看 diff 的 linter）：

```sh
desloppify scan --path . --profile ci --no-badge
desloppify status --json
```

- `pip` extras：`treesitter`、`csharp-xml`、`python-security`、`scorecard`、`plan-yaml`，`full` 包含全部。

## 適用情境

- 用 Claude Code、Codex、Cursor 等 agent vibe coding 出來的專案，想有系統地整理結構、命名與重複程式碼。
- 想讓 agent 跨多個 session 持續做重構，而不是每次「整理一下」都從頭開始、做一半就忘。
- 想在 CI 設一個整體程式碼品質門檻。
- 想要一個量化指標追蹤 codebase 品質的變化。

## 授權與成本

- **授權**：Open Source Native License（OSNL）v0.2，作者自訂，不是 OSI 認可的開源授權。
  - 任何個人或公司在內部使用（包含拿來改善自家 codebase）都免費、不需登記。
  - 把它（或衍生作品）放進產品或服務散布、提供給第三方時：公司本身主要業務資產是開源（OSI 授權或 OSNL）的免費；不是開源的公司，募資與年營收都低於 100 萬美元免費，達 100 萬美元每月 1,000 美元，年營收達 1,000 萬美元每月 5,000 美元，達 1 億美元每月 10,000 美元。
- **成本**：工具本身免費；主觀審查用的是你的 agent 或模型，token 費用另計。官方提醒審查子 agent 一次只開 3–5 個，同時開 20 個以上可能用光 API 額度而拿不到結果。

## 限制與注意事項

- **非 OSI 開源授權**：只是拿來整理自己的程式碼不受影響；要把它包進商業產品或服務前，請先讀 LICENSE。
- **分數有 75% 來自 LLM 主觀審查**：不同模型、不同次審查的結果可能不同；分數是否真的對應「好程式碼」是作者的設計目標，README 也承認「還沒做完」。
- **不支援真正的增量／只看 diff 的掃描**：每次都是全 codebase 掃描，monorepo 要每個專案分開跑。
- **語言支援深淺不一**：只有 8 種語言有完整外掛，其他 21 種僅通用 linter + tree-sitter。
- **會讓 agent 大量修改程式碼**：官方 prompt 要求 agent 大小重構都做；建議在乾淨的分支上跑，並有測試把關。
- **維護狀態**：v1.0 之後 main 分支（截至查詢時）沒有新 commit，open issues + PR 有 312 個。

## 相關工具

- [pstack](pstack.md)：同樣支援多種 coding agent 的 skill 組，著重從調查到驗證的工作流程，而非整體品質分數
- [Claude Octopus](Claude-Octopus.md)：用多個模型交叉審查程式碼
- [TokenEconomizer](TokenEconomizer.md)：同樣是 coding agent 外掛，著重降低 token 成本

## 資料來源

- https://github.com/peteromallet/desloppify （README）
- https://github.com/peteromallet/desloppify/blob/main/LICENSE （OSNL v0.2 條款與收費級距）
- https://github.com/peteromallet/desloppify/blob/main/docs/scoring.md （計分方式與維度權重）
- https://github.com/peteromallet/desloppify/blob/main/docs/SKILL.md （工作流程、分數種類、審查路徑）
- https://api.github.com/repos/peteromallet/desloppify （星數、forks、open issues、建立時間）
- https://pypi.org/project/desloppify/ （v1.0、Python ≥3.11、extras）
- https://www.opensourceprojects.dev/post/desloppify （介紹文章，2026-10-23）
