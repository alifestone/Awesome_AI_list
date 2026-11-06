# TokenEconomizer

- **分類**：Agent 框架與編排 / Coding agent 外掛（成本控制）
- **連結**：https://github.com/microsoft/TokenEconomizer
- **論文**：https://arxiv.org/abs/2610.22732
- **專案頁**：https://tokeneconomizer.github.io

## 原清單說明

（投稿時僅附連結，無原清單說明）

> **查證結果**：與 GitHub API 及 README 相符。repo 描述為 *Experience-Driven Black-Box Cost Control for Coding Agents*，由 UC Berkeley、Microsoft Research 與 Microsoft Security 的作者群發表。授權 Apache-2.0。查詢當下（2026-11-06）約 4.9k 顆星、294 forks、20 個 open issues，最新 release 為 v0.1.0（2026-10-26）。repo 建立於 2026-10-13。

## 概述

TokenEconomizer 是給 coding agent 用的外掛，目標是讓你常用的 repository 裡的 agent 跑起來更便宜，而且不改 agent 本身（模型、權重、程式碼都不動，所以叫「黑箱」）。它從 agent 在同一個 repo 跑過的 session 學經驗，用來減少之後 session 的浪費。

README 的出發點是：每一輪對話都要重付 agent 指令、所有已載入工具的定義與到目前為止的對話。同一個 agent 一再用在同一個 repo，就會一再重新發現相同的事實、送出從沒用過的工具、陷入同類的失敗迴圈。

支援 **Claude Code**、**Codex**、**GitHub Copilot CLI**、**Pi**；**opencode**、**Cursor Agent**、**Hermes Agent** 為實驗性支援。

## 核心功能／特色

三個機制，各自可開關：

- **Micro-skills（記住 repo 怎麼運作）**：學習像「這裡要用 `python -m pytest` 而不是 `pytest`」「某個指令需要哪個環境變數」「生成檔放在哪」這類事實。來源有兩個：跨 session 重複出現的失敗，以及每 *k*（預設 3）個 session 由模型回顧近期紀錄並提出事實。一個事實要經過三個 session 確認才會在 session 開頭注入，之後被推翻就移除。**預設關閉**，因為提案器會增加模型呼叫，省多少視 repo 而定；另有 `envfacts` 模式只從重複失敗學、不呼叫模型。
- **Tool pruning（不載入用不到的工具）**：每個已載入工具的定義會隨每次請求送出。一個工具若在橫跨至少 2 個 session 的 10 個 prompt 中都沒用到，或連續 5 個 session 沒用到，就透過 agent 自己的設定把它排除。一個指令就能還原。預設開啟；可設為 `propose` 只提案不套用。
- **Failure-loop intervention（loop guard，卡住時介入）**：一輪工作反覆遇到相同失敗時，由 judge 模型判斷是否卡住；信心 ≥ 0.7 時在 context 加一段短提示要求換方法，每輪最多 1 次。之後仍卡住就告訴你怎麼中斷，**從不自己中斷**。預設開啟。

其他特點：

- 每個動作會用一行訊息告知；外掛任何部分失敗，session 照常進行。
- 外掛自己的模型呼叫（事實提案器、judge 與提示）走你的 agent 本身的方案或登入，不需要額外 API key，成本也算進它的報告裡。
- 學到的東西只存在本機 `~/.tokeneconomizer`。
- 在 Claude Code 上可選擇匯入 repo 過去的 session 紀錄（`history_import`，預設關閉，不呼叫模型）。

## 技術架構或運作原理

- **只透過 agent 已經會讀的東西作用**：事實在 session 開頭注入 context；工具排除寫入 agent 的設定檔，不需要 agent 學新工具。
- **工具排除寫在哪**：Claude Code 寫入 `.claude/settings.local.json`（單一工具）；Codex 寫入 `.codex/config.toml`（capability package）；Copilot CLI 寫入 `.github/copilot/settings.local.json`（整個 MCP server）；Pi、Cursor、opencode、Hermes 目前不做排除。只新增自己的項目，不碰你寫的 deny 規則；建立的設定檔會加進 `.git/info/exclude`。
- **等閒置才寫 deny list**：因為改變工具清單會讓 prompt cache 失效，它會等 repo 的 session 閒置 60 分鐘（最晚一天）才寫入。
- **成本以實際計費方式計算**：大部分 token 是快取重讀，因此以快取價格計算，並含外掛自己的模型呼叫。
- **Loop guard 的基準**：先觀察 5 輪「正常結束」的工作，學會這個 repo 一輪通常多長，之後才開始介入；超過平常長度 2.5 倍且反覆改同樣地方、遇同樣失敗的輪次，不經 judge 直接提示。
- 套件只用 Python 標準函式庫。

## 安裝與使用方式

需要 Python 3.10 以上，以及已登入的支援 agent。Claude Code、Codex、Copilot CLI、opencode 直接從 clone 下來的資料夾執行外掛，所以 clone 要保留。

```sh
# Claude Code
git clone https://github.com/microsoft/TokenEconomizer.git
claude plugin marketplace add "$PWD/TokenEconomizer"
claude plugin install tokeneconomizer@tokeneconomizer
# 啟動 claude 後執行 /tokeneconomizer:status
# 每台機器一次（Claude Code 更新後再一次）：/tokeneconomizer:toolprune refresh-catalog

# Codex
codex plugin marketplace add "$PWD/TokenEconomizer"
codex plugin add tokeneconomizer@tokeneconomizer

# Copilot CLI
copilot plugin marketplace add "$PWD/TokenEconomizer"
copilot plugin install tokeneconomizer@tokeneconomizer

# Pi
pi install git:github.com/microsoft/TokenEconomizer
```

常用指令（Claude Code 寫法；Codex 用 `$tokeneconomizer:`，Pi 用 `/te`，終端機用 `~/.tokeneconomizer/bin/te`，終端機執行不耗模型 turn）：

```text
/tokeneconomizer:status                      # 學到什麼、做了什麼、session 花多少
/tokeneconomizer:microskills                 # 注入的事實與形成中的事實
/tokeneconomizer:toolprune                   # 被排除的工具與證據
/tokeneconomizer:toolprune restore           # 還原工具，之後不會再被排除
/tokeneconomizer:config set microskills=on   # 開啟 micro-skills（加 --global 套用到所有 repo）
```

單一 session 可用環境變數控制，例如 `TE_DISABLE=1 claude` 整個關閉，`TE_LOOPGUARD=off codex` 關閉單一機制。

## 適用情境

- 長期在同一批 repo 用 Claude Code、Codex 或 Copilot CLI，想降低 token 成本。
- 裝了很多 MCP server 或工具，但每個 repo 實際只用到少數。
- agent 常在測試失敗、指令拼錯之類的地方原地打轉。
- 研究 coding agent 成本控制，可用 `experiments/` 重跑論文的 SWE-Bench 與 Web-Bench 實驗。

## 授權與成本

- **授權**：Apache-2.0。
- **成本**：外掛本身免費；它的模型呼叫走你既有的 agent 方案，費用計入同一帳單（也計入它的報告）。

## 成效（論文自述）

論文以 5 種 agent × 模型組合跑同一批 277 個 SWE-Bench 任務（6 個 repo），每個任務一個 session、每個 repo 依序從零開始學：

- 平均成本降低 **18.4–30.9%**，30 個 repo × 組合格子全部比預設便宜（各格降 5–40%）。
- Pass@1 在 5 個組合中有 4 個上升：Claude Code + Sonnet 5 成本 −23.6%、Pass@1 +1.3；+ Opus 4.8 −30.9%、−1.0；Codex + GPT-5.6 Terra −24.7%、+0.9；+ GPT-5.6 Sol −26.1%、+1.6；Copilot CLI + Sonnet 5 −18.4%、+2.6。
- Web-Bench 降 16–21%；兩個每題都是新 repo 的資安稽核基準降 6–20%。

以上皆為作者自己的量測，未見第三方重現。

## 限制與注意事項

- **版本範圍很窄**：README 只支援 Claude Code 2.1.300–2.1.310、Codex 0.153.1–0.164.0、Copilot CLI 1.0.83–1.0.102、Pi 1.2.0–1.3.0，較舊版本不支援，較新版本未測試。Codex 0.141.0 以前完全不跑外掛 hook。
- **早期版本**：最新 release 為 v0.1.0。
- **實驗性支援的限制**：Cursor 無法取得 session 成本、僅 macOS／Linux；opencode 沒有外掛指令，要從終端機下；Hermes 不支援 tool pruning，只測過 classic CLI 與一次性執行。
- **Claude Code 上訊息不易看見**：外掛的訊息只出現在詳細 transcript（Ctrl+O），「仍卡住」的提示需要 Claude 在回覆中轉述，模型可能改寫或省略。
- **Headless 執行**：沒人看時被標記的輪次會跑到結束或 agent 自身上限為止。
- 效益集中在常用的 repo；需要累積幾個 session 才會開始作用。

## 相關工具

- [Claude Octopus](Claude-Octopus.md)：同樣是 Claude Code 外掛，但方向相反——用多個模型交叉審查，增加成本換品質
- [pstack](pstack.md)：同樣支援 Claude Code、Codex、Copilot、Pi 的 skill 組，著重工作流程而非成本
- [Cline](Cline.md)：開源 coding agent 本身

## 資料來源

- https://github.com/microsoft/TokenEconomizer （README）
- https://api.github.com/repos/microsoft/TokenEconomizer （星數、授權、建立與最近推送時間、open issues）
- https://api.github.com/repos/microsoft/TokenEconomizer/releases/latest （v0.1.0）
- https://arxiv.org/abs/2610.22732 （論文，README 所附連結）
