# fast-jev-compaction

- **分類**：Jev 決策模型生態
- **連結**：https://github.com/tamaratran/fast-jev-compaction

## 原清單說明

Claude Code 外掛：用 Jev 判斷哪些工具呼叫／結果已過時並刪掉，取代摘要式壓縮，保留下來的內容維持原文。

> 查證結果：大致相符。README 稱其為「Claude Code plugin that replaces the compaction summary with Jev decisions」，同時也是一個 npm 函式庫。小幅修正：除了「保留」與「刪除」之外，還有第三種結果「保留呼叫、但把結果截斷成前 300 字元 + 註記」；因此並非所有保留的工具結果都維持全文。使用者與助理的文字訊息則一律原文保留。

## 概述

fast-jev-compaction 是一個 npm 函式庫兼 Claude Code 外掛。當對話需要壓縮（compaction）時，它不讓 LLM 撰寫有損的摘要，而是請 TypeSafe 的 Jev 對每一個工具呼叫與工具結果做決策，只移除 Jev 判定已不需要的部分；使用者與助理的文字訊息原文、原順序保留。撰寫時（2026-10-13）GitHub 約 7.6k stars、538 forks。

## 核心功能／特色

- **不改寫**：只刪除工具呼叫與結果，從不摘要。
- **文字原文保留**：使用者與助理訊息照原樣保留。
- **釘選訊息**：第一則訊息與最新的 `preserveRecentMessages` 則訊息永不處理。
- **分階段擬合**：送給 Jev 的狀態會分階段裁剪以符合 `maxStateTokens`。
- **逐呼叫決策**：每個呼叫／結果得到 keep / truncate / remove 決策。
- **失敗即拋錯**：由呼叫端或 hook 決定後續處理。
- **可注入傳輸層**：可自行實作 `JevAsker`。

## 技術架構或運作原理

1. 以 `tool_use_id` 配對每個 `tool_use` 與 `tool_result`。
2. 把完整對話送給 Jev，但每個工具結果被替換為簡短註記（例如 `ok, 4213 chars (omitted)`）。
3. 分階段將狀態擬合至 `maxStateTokens`（預設 25k）：工具輸入依序截為 1000 → 200 → 60 字元；長文字縮為頭尾摘錄；舊訊息折疊；仍放不下則拋錯。
4. 對每個未釘選的呼叫，Jev 回答兩個問題：這個呼叫要保留嗎？結果要原文保留嗎？
5. 問題分批，使「狀態 + 問題」低於 `maxRequestTokens`（預設 30k，低於 Jev 的 32k 上限），請求並行送出。
6. 以 `keepThreshold`（預設 0.5）決定：
   - `keepResult` ≥ 門檻 → 呼叫與結果都保留；
   - 否則若 `keepCall` ≥ 門檻 → 保留呼叫，結果截為 `truncateHeadChars`（預設 300）字元並加註記；
   - 否則兩者都刪除。
7. 重建訊息清單，確保沒有結果失去其對應的呼叫。

Token 數不使用 tokenizer，而是估算：約每 6 個字母 1 token、每個數字 0.5 token、其他符號約各 1 token。

## 與 Jev 的關係

- Jev 是本專案的核心判斷模型，預設模型名 `jev-latest`，經由 TypeSafe 的 System One 端點 `https://api.typesafe.ai/v1/systemone` 呼叫，以 `TYPESAFE_API_KEY` 驗證。
- 每個工具呼叫被轉成兩道封閉式是非題，正是 Jev「狀態 + 有型別問題 → 機率」的典型用法。
- 由於傳輸層可注入（`JevAsker`），理論上可接到其他 Jev 相容端點（如 Laya 的 `laya-serve`），但 README 未示範此用法（資料不足）。

## 安裝與使用方式

函式庫：

```bash
npm install fast-jev-compaction
export TYPESAFE_API_KEY=...
```

Claude Code 外掛（function hooks 為早期存取功能，需 Claude Code 2.1.274+）。先在 `~/.claude/settings.json` 加入：

```json
{ "env": { "CLAUDE_CODE_ENABLE_FUNCTION_HOOKS": "1", "TYPESAFE_API_KEY": "<your key>" } }
```

再執行：

```bash
claude plugin marketplace add tamaratran/fast-jev-compaction
claude plugin install fast-jev-compaction@fast-jev-compaction
```

然後重啟 Claude Code 或執行 `/reload-plugins`。不安裝、直接從 checkout 執行：`CLAUDE_CODE_ENABLE_FUNCTION_HOOKS=1 claude --plugin-dir .`

程式用法：

```ts
import { compactMessages, reductionRatio, type Message } from 'fast-jev-compaction';

const result = await compactMessages(transcript, { preserveRecentMessages: 4 });
console.log(result.messages, result.decisions, result.stats);
if (reductionRatio(result) < 0.25) {
  // 不值得：保留原始對話，或改用摘要
}
```

自訂傳輸：實作 `JevAsker` 並呼叫 `compact(messages, asker, options)`；另匯出 `buildJevRequest` 與 `parseJevResponse`。`Message` 是 Claude Code `SessionMessage` 的子集，可直接傳入 session transcript。

選項預設值：`apiKey`=`TYPESAFE_API_KEY`、`model`=`jev-latest`、`baseUrl`=`https://api.typesafe.ai/v1/systemone`、`keepThreshold`=0.5、`preserveRecentMessages`=6、`maxStateTokens`=25000、`maxRequestTokens`=30000、`truncateHeadChars`=300。`result.stats` 回報前後訊息與字元數、決策統計、狀態估計 token 數、使用的擬合階段、請求數。

開發：

```bash
npm install
npm run typecheck
npm test
npm run build
npm run validate:plugin
TYPESAFE_API_KEY="$(cat ~/.typesafe_key)" npm run demo
```

單元測試使用假的 Jev；demo 會實際連網。`demo/JevDemo` 是 macOS SwiftUI 動畫示範（腳本化、不呼叫 API），以 `demo/JevDemo/build.sh` 建置。

## 適用情境

- 長時間 Claude Code session 中，大量過時的工具輸出（檔案讀取、測試輸出、搜尋結果）塞滿上下文。
- 希望壓縮後仍保留使用者／助理對話原文、避免摘要造成資訊扭曲。
- 自建 agent 框架中需要以決策模型做上下文修剪。

## 授權與成本

- 授權：MIT。
- 成本：需 TypeSafe API 金鑰。依 DataCamp 報導，Jev 計價為每百萬輸入 token 0.042 美元、輸出免費，且目前為早期存取（waitlist）。README 未提供本外掛實際的單次壓縮費用（資料不足）。

## 限制與注意事項

- 只移除工具呼叫與結果；輸出中不會刪除文字訊息（但在送給 Jev 的狀態中文字會被縮略）。
- Token 數為字元估算，非真實 tokenizer。
- 「保留／刪除」機率不代表刪除一定安全；必要時助理可重新執行工具。
- 每個請求都會重送完整狀態，若歷史接近狀態上限，每幾個問題就要一個請求。
- Function hooks 是 Claude Code 的早期存取功能，需要特定版本與環境變數。
- 依賴 TypeSafe Jev 的可用性（早期存取、需金鑰）。

## 相關工具

- [jevgrep](./jevgrep.md)：同樣以 Jev 服務 coding agent 的程式碼搜尋 CLI。
- [Laya](./Laya.md)：可自架、提供 Jev 相容 `/v1/systemone` 端點的模型。
- Claude Code 內建的摘要式 compaction（本專案的替代對象）。

## 資料來源

- https://github.com/tamaratran/fast-jev-compaction
- https://www.datacamp.com/blog/system-one-models-jev
