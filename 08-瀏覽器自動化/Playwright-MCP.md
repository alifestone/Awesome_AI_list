# Playwright MCP

- **分類**：瀏覽器自動化
- **連結**：https://github.com/microsoft/playwright-mcp

## 原清單說明

讓 AI 透過 MCP 操作瀏覽器。

## 概述

Playwright MCP（npm 套件 `@playwright/mcp`）是 Microsoft 推出的 Model Context Protocol（MCP）伺服器，讓 LLM 用戶端（Claude Code、VS Code、Cursor、Codex 等）透過 Playwright 自動化瀏覽器。它的特點是以頁面的**結構化無障礙快照（accessibility snapshot）**來理解與操作網頁，而非截圖，因此不需要視覺模型。

查閱時（2026-10）GitHub 約 38.1k stars、3.2k forks；最新 Release 為 v0.0.83（9 月 28 日發布）。

## 核心功能／特色

- **以無障礙樹為基礎**：官方稱其快速、輕量、不需視覺模型，且避免截圖方式的歧義；建議以 `browser_snapshot` 取代截圖。`browser_take_screenshot` 可截圖，但官方註明無法依截圖執行動作。
- **核心自動化工具**：點擊、輸入、hover、拖放、填寫表單、選擇選項、導航、按鍵、執行 JavaScript、上傳檔案、處理對話框、等待、調整視窗大小、快照／截圖。
- **分頁管理**：`browser_tabs`（列出、建立、關閉、選取）。
- **可選能力（`--caps=` 啟用）**：
  - `vision`：座標式滑鼠操作（如 `browser_mouse_click_xy`、`browser_mouse_move_xy`）。
  - `network`：路由 Mock、離線切換。
  - `storage`：Cookies、localStorage、sessionStorage、storage state 儲存／還原。
  - `devtools`：高亮、tracing、錄影、動作疊層、把使用者操作錄製成程式碼。
  - `pdf`：將頁面存成 PDF。
  - `testing`：產生 Locator、驗證元素／文字／清單／值。
  - `config`：`browser_get_config` 回傳實際設定。
- **多種瀏覽器**：`--browser` 可選 chrome、firefox、webkit、msedge。
- **連接既有瀏覽器**：`--extension` 透過 Playwright Extension 連到執行中的 Chrome／Edge。

## 技術架構或運作原理

- 以 MCP 伺服器形式執行，預設透過 stdio 與用戶端溝通；加上 `--port`／`--host` 則改用 HTTP（如 `http://localhost:8931/mcp`）。
- 底層使用 Playwright 驅動瀏覽器，將頁面的無障礙樹轉成結構化文字回傳給 LLM，LLM 再以元素參照呼叫工具操作。
- **設定檔（Profile）**：
  - 預設為持久化 profile，存於使用者快取目錄下 `ms-playwright/mcp-{channel}-{workspace-hash}`。
  - `--isolated`：profile 只存在記憶體，關閉即丟棄。
  - `--user-data-dir`：自訂 profile 目錄。
  - 持久化 profile 同時只能被一個瀏覽器使用，多個用戶端平行使用需用 `--isolated` 或不同 `--user-data-dir`。
- 大部分 CLI 參數有對應的 `PLAYWRIGHT_MCP_` 前綴環境變數，也可用 `--config` 載入 JSON 設定檔。

## 安裝與使用方式

需求：Node.js 18 以上，以及支援 MCP 的用戶端。

通用設定（多數用戶端適用）：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

各用戶端指令：

```bash
# Claude Code
claude mcp add playwright npx @playwright/mcp@latest

# VS Code
code --add-mcp '{"name":"playwright","command":"npx","args":["@playwright/mcp@latest"]}'

# Codex
codex mcp add playwright npx "@playwright/mcp@latest"

# 以 HTTP 模式啟動（用戶端連 http://localhost:8931/mcp）
npx @playwright/mcp@latest --port 8931

# Docker（僅支援 headless Chromium）
docker run -i --rm --init --pull=always mcr.microsoft.com/playwright/mcp
```

其他：Cursor 可新增 command 型 MCP 伺服器 `npx @playwright/mcp@latest`；Copilot CLI 用 `/mcp add` 或編輯 `~/.copilot/mcp-config.json`；README 另有 Amp、Cline、Gemini CLI、Goose、Kiro、LM Studio、opencode、Windsurf 等用戶端的安裝說明。

常用參數：`--headless`（預設為有視窗）、`--browser`、`--caps`、`--isolated`、`--user-data-dir`、`--extension`、`--storage-state`、`--allowed-origins`／`--blocked-origins`、`--viewport-size`、`--output-dir`、`--timeout-action`、`--timeout-navigation`。

## 適用情境

- 讓 AI Agent 進行探索式網頁操作（查資料、填表、跨頁流程）。
- 自我修復（self-healing）測試、需要維持瀏覽器狀態的長時間工作流程。
- 以 LLM 產生 Locator、驗證頁面內容、錄製操作為測試程式碼。
- 官方建議：若主要是 Coding Agent 寫程式／跑測試、在意 token 成本，改用 **Playwright CLI + Skills** 較省 token；MCP 較適合重視持久瀏覽器狀態而非 token 成本的情境。

## 授權與成本

- 授權：Apache-2.0。
- 成本：開源免費；實際成本來自所連接 LLM 的 token 用量（無障礙樹與工具 schema 會佔用上下文）。

## 限制與注意事項

- 官方明言 **Playwright MCP 不是安全邊界**，並指向 MCP 安全最佳實務。
- `browser_run_code_unsafe` 可在 Playwright 伺服器程序中執行任意 JavaScript，官方形容等同 RCE。
- `--allowed-origins`／`--blocked-origins` 不是安全邊界，且不影響重新導向。
- 檔案系統存取預設限於工作區根目錄；`file://` 導航預設封鎖，除非加上 `--allow-unrestricted-file-access`。
- secrets 功能只會遮蔽回應中的相符文字，官方稱其為便利功能而非安全控制。
- `--host` 預設 localhost；綁定 0.0.0.0 會把伺服器暴露給其他機器（Docker 長駐服務範例即綁定 0.0.0.0、port 8931）。
- Docker 映像僅支援 headless Chromium。
- 截圖無法作為動作依據；需要像素級操作時必須啟用 `--caps=vision`。
- 版本號仍為 0.0.x，介面可能持續變動。

## 相關工具

- Playwright（本資料夾另一條目）：底層自動化與測試框架。
- Playwright CLI（`@playwright/cli`）：官方推薦給 Coding Agent 的較省 token 替代方案。
- Playwright Extension：讓 MCP 連接既有 Chrome／Edge。

## 資料來源

- https://github.com/microsoft/playwright-mcp
- https://github.com/microsoft/playwright-mcp/releases
- https://github.com/microsoft/playwright
