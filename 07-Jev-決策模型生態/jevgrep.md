# jevgrep

- **分類**：Jev 決策模型生態 / 用 Jev 做事的工具
- **連結**：https://github.com/dzhng/jevgrep

## 原清單說明

「問它做什麼」就能找到相關程式碼的 CLI，給 coding agent 用。

> 查證結果：與 README 相符（標語「Find code by asking what it does」）。CLI 指令名為 `jg`，npm 套件 `@dzhng/jevgrep`。

## 概述

jevgrep 是給 coding agent 使用的命令列工具（指令 `jg`）。你用自然語言問程式庫的問題，例如「認證是在請求到達 handler 之前的哪裡檢查的？」，它會回傳相關檔案、閱讀線索與逐字的原始碼摘錄。README 強調輸出是「給 agent 使用的證據，而非生成的答案」，後續實作與測試仍由 coding agent 完成。由 GitHub 帳號 `dzhng` 維護。撰寫時（2026-10-13）GitHub 約 2.6k stars、192 forks。

## 核心功能／特色

- 自然語言程式碼搜尋；即使無法回傳摘錄，也會保留符合條件的檔案位置。
- 檔案過濾：遵守 ignore 檔，排除隱藏檔、相依／建置目錄、二進位檔與明顯的憑證檔。
- `jg files [root]`：統計搜尋可能讀取的檔案數，不需金鑰、不連網。
- `--exclude`：gitignore 風格的排除樣式。
- `jg auth` 儲存供應商設定；`jg doctor` 以合成輸入做健康檢查。
- 預設在本機快取評估結果（快取控制見 `jg --help`）。
- `jg skill`：為 Claude Code、Codex、OpenCode 等 agent 安裝 skill。

## 技術架構或運作原理

- 以 Jev 判斷資料夾、檔案、宣告層級的相關性。
- 沿著程式庫階層探索，追蹤符合條件的分支；以內容預覽挑選檔案，再找出有用的原始碼單元與周邊上下文。
- 輸出順序：摘要與精簡檔案清單 → 含行號的原始碼 → 詳細的宣告與呼叫位置。
- 宣告解析支援 Python、TypeScript/JavaScript、Go、Rust；其他文字使用退回機制。
- 技術棧：TypeScript、Bun workspaces、Turborepo；發佈的套件只需 Node.js。

### README 公布的基準

- **原始比較（僅計 Sol 成本）**：10 個調校過的 Python SWE-bench 任務，jevgrep 與基線都解出 8/10；Sol 成本從 $7.62 降到 $5.44（實測 28.6%，約 30%），不含 Jev 成本。
- **0.4.3 版總成本重跑（含 Jev）**：總成本降低 25.8%，同樣 8/10。
- **0.5.0 版**：維持 8/10；原生 Jev 成本較 0.4.3 降約 59%，但 Sol + Jev 合計成本高 2–3%，README 視為可接受的小代價。
- README 說明這些都是單次執行觀察，不代表統計等價，也未量測速度改善。

## 與 Jev 的關係

- Jev 是 jevgrep 判斷相關性的模型；README 連結到 Jev 在 Vercel AI Gateway 的頁面。
- 支援的供應商：Vercel AI Gateway、TypeSafe、OpenRouter、OpenCode Zen，或自訂的 TypeSafe 相容端點（選擇供應商需 0.3.0 以上版本）。
- README 提到一項使用「Jev 原生 TypeSafe 端點」的速度研究。
- 搜尋時符合條件的原始碼會經由所選供應商送到 Jev。

## 安裝與使用方式

需求：Node.js 22+；macOS、Linux 或 Windows；上述任一供應商的金鑰。不需另裝 Python、Bun 或 ripgrep。

```bash
npm install -g @dzhng/jevgrep
jg auth          # 設定供應商與金鑰（必要）
jg skill         # 偵測 coding agent 並安裝 skill；--global 全域安裝，--yes 無人值守
```

不經 CLI 安裝 skill：`npx skills add dzhng/jevgrep --skill jevgrep`（0.1.0 版的 `jg skill` 只會印出 skill，需改用此方式）。skill 安裝器不設定憑證，仍須執行 `jg auth`。

升級（無 `jg upgrade` 指令）：

```bash
npm install -g @dzhng/jevgrep@latest
jg --version
jg skill   # 專案內的 skill 檔不會自動更新，需重跑
```

查詢範例：

```bash
jg "How are telemetry events recorded and sent?" ./my-project
jg "Where is authentication checked before a request reaches a handler?" .
jg "How are database connections created, pooled, and closed?" ./src
jg "Which tests cover retry behavior when a request times out?" .
```

從原始碼開發：`bun install --frozen-lockfile`、`bun run dev --help`、`bun run verify`（含以 Docker 測試安裝後的 Node 套件）。

## 適用情境

- coding agent 面對陌生、大型的程式庫，需要跨多個檔案理解某個行為的實作位置。
- 想降低 agent 主模型在探索程式碼時消耗的 token／成本。
- README 建議：若已知確切符號或路徑，直接讀檔或用 `rg` 就夠了。

## 授權與成本

- 授權：MIT。
- 成本：工具本身免費；需付費使用所選供應商的 Jev API。Jev 官方計價依 DataCamp 報導為每百萬輸入 token 0.042 美元、輸出免費；透過 Vercel／OpenRouter 等轉售的價格：資料不足。

## 限制與注意事項

- 結果是證據，不保證找到所有相關檔案。
- 宣告解析僅限 Python、TS/JS、Go、Rust。
- 基準僅 10 個 Python 任務、單次執行；不保證每個程式庫都省錢，也未量測速度。
- 原始碼會被送到外部供應商；敏感內容過濾「不保證移除所有敏感資訊」，應謹慎選擇搜尋根目錄。
- `jg auth` 將金鑰存於僅擁有者可讀的設定檔；已不再使用環境變數憑證與端點覆寫；舊的未指定供應商的金鑰會被視為 Vercel 金鑰。
- CLI 只輸出到 stdout，不產生報告檔。

## 相關工具

- [fast-jev-compaction](./fast-jev-compaction.md)：同樣以 Jev 服務 Claude Code 的上下文壓縮外掛。
- ripgrep（`rg`）：已知符號時的直接搜尋替代方案。
- Claude Code、Codex、OpenCode（`jg skill` 支援的 agent）。
- Vercel AI Gateway、OpenRouter、OpenCode Zen（Jev 存取供應商）。

## 資料來源

- https://github.com/dzhng/jevgrep
- https://www.datacamp.com/blog/system-one-models-jev
