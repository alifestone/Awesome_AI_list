# claude-work-mode

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/danyuchn/claude-work-mode（附[繁體中文 README](https://github.com/danyuchn/claude-work-mode/blob/main/README.zh-TW.md)）

## 概述

claude-work-mode 是 Dustin Yuchen Teng 做的 Claude Code 外掛，用一個 `/work-mode` 指令切換 session 的「工作模式」，改變 Claude 在這個 session 裡的做事方式：`auto` 讓它不為內部、可還原的步驟停下來問；`out` 讓它把可驗證的批次工作外包給子 agent 或外部 CLI；`wrap` 讓它收斂、把手上的事做完。模式可以疊加（`/work-mode auto wrap`），`off` 回到一般狀態。

模式說明只在切換後的下一個 prompt 或工具結果送給模型一次，compact 或 resume 之後再補送一次，不會每輪都塞進 context。另有選用的 `work-mode-gates` 外掛：一組 shell hook，在 `auto` 模式下把「詢問」改成「拒絕並說明該怎麼做」，讓工作不被確認提示打斷。

查閱時（2026-11-09）GitHub 顯示約 153 stars、11 forks；repo 建立於 2026-11-08，最後 commit 同日，兩個外掛版本皆為 0.5.0，沒有 GitHub release。

## 核心功能／特色

### 模式

| 模式 | 告訴模型的事 |
| --- | --- |
| **`auto`** | 內部、可還原的步驟（本機檔案、本機 commit、測試）不要停下來問。硬性停止點（對外發訊息、安裝、機密、無法復原的刪除、付款、權限變更、正式環境變更）記進待辦清單，最後一次回報。會跳出確認提示的呼叫留到最後連續執行，只打斷你一次 |
| **`out`** | 可以用檢查器或抽查驗證的批次工作（擷取、分類、摘要、審查）交給背景子 agent（較便宜的模型）或外部 CLI（如 `codex exec`、`gemini`），主執行緒負責驗證。主執行緒單一回合讀了大量原始輸出（預設 20,000 字元）卻沒外包時，會提醒一次 |
| **`wrap`** | 收斂：不開新分支，把已開的做完，只列出新的或有變動的決策，每項附標籤與建議 |
| `off` | 回到一般狀態 |

- 單打 `/work-mode` 會開多選選單
- 同時打 `out` 與 `wrap` 時以 `wrap` 為準
- 模式只對目前 session 有效

### 選用的 gates（`work-mode-gates`）

模式會寫到 `~/.claude/state/tempo/<session_id>`，讓 shell hook 讀得到。`hooks/lib/tempo-auto.sh` 提供 `tempo_auto_on` 和 `tempo_deny` 兩個函式，在 `auto` 模式下把原本會詢問的 gate 改成拒絕，並附上叫模型改用別的做法的理由。內建三個 gate：

| Gate | 事件 | 平常 | `auto` 模式下 |
| --- | --- | --- | --- |
| `scratch-doc-guard.sh` | PreToolUse `Write` | 建立新的 `SUMMARY*`、`REPORT*`、`NOTES*`、`FINDINGS*`、`ANALYSIS*.md` 前先詢問 | 拒絕：改更新既有文件、用暫存資料夾，或直接寫在回覆裡 |
| `git-safe-commit-gate.sh` | PreToolUse `Bash` | 帶路徑的 `git commit`，或 `git add` 一個本來就有未暫存修改的檔案時詢問 | 拒絕：改用 `git add -p` 再單純 `git commit` |
| `decision-label-guard.py` | Stop | 回覆的決策區塊有未加標籤的項目，或取捨項目沒寫出兩邊各得到什麼時擋下 | 同左 |

`tempo-auto.sh` 也可以拿去用在自己寫的 gate。README 特別提醒：真正的硬性停止點（機密、force push、部署）不要接這套轉換，任何模式下都應該詢問。

## 技術架構或運作原理

- `work-mode` 是 Claude Code 的 function-hook 外掛（TypeScript 模組）：註冊 `/work-mode` 指令，並在 session 開始、`/clear`、resume、fork、compact 與送出 prompt 時決定是否補送模式說明；外包提醒（nudge）是另一個模組
- 判斷「有沒有外包」：符合 `dispatch.commandPattern`（預設 `codex exec`、`gemini`、`claude -p`）的 Bash 指令算外包
- 模式狀態另外寫成檔案，因為 PreToolUse 的 shell hook 讀不到外掛內部狀態；沒有模式時檔案會被刪掉。狀態缺漏或格式錯誤一律當作關閉，gate 照常詢問
- `tempo.ts` 匯出 `setTempoStatusSink`，讓其他把多個部分組成同一條狀態列的外掛能顯示 work-mode 標籤
- 開發用 `./check.sh`：型別檢查、驗證 marketplace 與兩個外掛，並跑外掛測試、決策標籤自我測試與 gate 測試

## 安裝與使用方式

```
/plugin install work-mode --marketplace danyuchn/claude-work-mode
# 選用的 gates
/plugin install work-mode-gates --marketplace danyuchn/claude-work-mode
```

詢問是否加入 marketplace 時回答 `y`，再選安裝範圍。需要支援 function-hook 外掛的 Claude Code（2.1.314 以上）；gates 另需 `bash`、`jq`、`git`、`python3`。

```
/work-mode auto          # 不為可還原的步驟停下來問
/work-mode out           # 批次工作外包給子 agent／外部 CLI
/work-mode auto wrap     # 自主收尾
/work-mode off
```

### 設定（選用）

不設定也能用。語言依序取 `WORK_MODE_LOCALE`、Claude Code 的 `language` 設定（提到中文就用繁體中文）、`LC_ALL`／`LANG`，否則英文。要個人化可建立 `~/.config/work-mode/config.json`（或用 `WORK_MODE_CONFIG` 指定），可調整：稱呼你的方式與代名詞、`auto` 額外規則、`out` 的整段說明與外包指令的判斷規則、提醒門檻、`wrap` 的決策區塊標題與標籤、沒有待辦時自動執行的收尾指令等。

若有追蹤外部模型額度，可用 `dispatch.quotaFile` 指向一份額度表；`out` 開啟時，模型會收到一行說明哪個額度池已經超過下限，表格有變動才會再送。

## 適用情境

- 想讓 Claude Code 自己跑完一段工作，不要為了建檔、本機 commit、跑測試一直停下來問，但對外、不可逆的動作仍保留到最後由你確認
- 大量擷取、分類、摘要工作想丟給較便宜的子 agent 或 Codex、Gemini CLI，主 session 只負責驗證，省主模型的 context
- Session 快結束時，要 Claude 停止開新方向、收尾並整理出需要你決定的事項
- 想在自己的 PreToolUse hook 裡依目前模式改變行為

## 授權與成本

- **授權**：MIT。
- **成本**：免費。`out` 模式外包給外部 CLI 時，會用到那些服務自己的額度或費用。

## 限制與注意事項

- **非常新**：repo 2026-11-08 才建立，版本 0.5.0，尚無 release；需要較新的 Claude Code（2.1.314 以上）。
- `auto`、`out`、`wrap` 本身是給模型的指示，不是權限控管：模型是否照做取決於模型，Claude Code 的權限設定與確認提示照常生效。實際把「詢問」改成「拒絕」的只有選用 gates 裡的三個 hook。
- `auto` 搭配 gates 會讓那三個 gate 不再詢問，如果你本來依賴這些提示來審查 commit 或新文件，要注意這點；自寫 gate 時別把真正的硬性停止點接進來。
- 程式碼本身沒有網路呼叫；`out` 會讓模型去執行你已安裝的外部 CLI，把資料送到那些服務。

## 相關工具

- [TokenEconomizer](TokenEconomizer.md)：另一種控制 coding agent 成本的方式，從過去 session 學習、排除沒用到的工具
- [Superpowers](Superpowers.md)：整套強制的開發流程；claude-work-mode 只調整做事節奏，不規定開發方法
- [Claude Octopus](Claude-Octopus.md)：同樣會呼叫 Codex、Gemini，但目的是多模型互相審查，不是外包批次工作

## 資料來源

- https://github.com/danyuchn/claude-work-mode
- https://raw.githubusercontent.com/danyuchn/claude-work-mode/main/README.md
- https://github.com/danyuchn/claude-work-mode/tree/main/plugins
- https://api.github.com/repos/danyuchn/claude-work-mode
