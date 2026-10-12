# Playwright

- **分類**：瀏覽器自動化
- **連結**：https://github.com/microsoft/playwright

## 原清單說明

跨瀏覽器自動化與 E2E 測試框架。

## 概述

Playwright 是 Microsoft 開源的網頁測試與自動化框架，官方說法是「以單一 API 驅動 Chromium、Firefox 與 WebKit」，可用於測試、腳本，以及 AI Agent。它同時提供完整的測試執行器（Playwright Test）、無測試執行器的函式庫（Playwright Library）、給 Coding Agent 用的 Playwright CLI、MCP 伺服器（Playwright MCP，另見同資料夾條目），以及 VS Code 擴充套件。

查閱時（2026-10）GitHub 約 97.5k stars、6.6k forks；最新 Release 為 v1.64.0（10 月 7 日發布）。

## 核心功能／特色

- **跨瀏覽器**：README 列出的瀏覽器版本為 Chromium 156.0.8078.12（預設使用 Chrome for Testing）、WebKit 27.2、Firefox 157.0，皆支援 headless 與 headed 模式。
- **跨平台**：Linux、macOS、Windows。
- **多語言綁定**：JavaScript/TypeScript 為主，另有 Python、.NET、Java 版本。
- **自動等待（Auto-wait）**：操作前自動等待元素可互動，不需人工加 timeout。
- **Web-first 斷言**：斷言會自動重試直到條件成立。
- **語意化 Locator**：`getByRole`、`getByLabel`、`getByPlaceholder`、`getByTestId` 等，貼近使用者看到頁面的方式。
- **隔離與 Browser Context**：每個測試取得獨立的 browser context（相當於全新瀏覽器設定檔，額外開銷近乎零）；可用 `storageState` 儲存並重用登入狀態。
- **追蹤與除錯**：失敗時可擷取 trace、截圖與影片；Trace Viewer 可檢視 DOM 快照、網路請求與 console 訊息。
- **Codegen 測試錄製**：開啟瀏覽器、依操作自動產生測試程式碼（CLI 與 VS Code 擴充都支援）。
- **平行執行**：預設在設定的多個瀏覽器間平行跑測試。
- **函式庫用途**：截圖、PDF 生成、行動裝置模擬、網路攔截等。
- **近期新增（v1.63／v1.64）**：WebMCP 支援（`page.webmcp`／`frame.webmcp` 可列出並呼叫頁面透過實驗性 WebMCP API 註冊的工具）、`locator.within()`、`page.getByRef()`、`--shuffle` 隨機測試順序、測試鎖（`lock`）、`locator.visible()`、`perfetto` reporter 等。

## 技術架構或運作原理

- 由 Playwright 驅動三大瀏覽器引擎（Chromium／Firefox／WebKit），透過統一 API 對外提供操作；需先以 `npx playwright install` 下載對應瀏覽器。
- 以 **Browser → Browser Context → Page** 分層：Context 是輕量、彼此隔離的瀏覽器工作階段，讓每個測試互不干擾。
- 產品分層：
  - **Playwright Test**：測試執行器，預設平行、headless。
  - **Playwright Library**：純自動化 API，無測試框架。
  - **Playwright CLI**：給 Coding Agent（如 Claude Code、Copilot）使用的命令列工具，官方表示比 MCP 更省 token（不需把大型工具 schema 與無障礙樹載入模型上下文），含 `playwright-cli show` 即時畫面儀表板。
  - **Playwright MCP**：以結構化無障礙快照（accessibility snapshot）讓 AI Agent 控制瀏覽器。

## 安裝與使用方式

系統需求（官方文件）：Node.js 最新的 22.x／24.x／26.x；Windows 11+、Windows Server 2019+ 或 WSL；macOS 14（Sonoma）以上；Debian 12/13、Ubuntu 22.04/24.04/26.04（x86-64 或 arm64）。

```bash
# 建立 Playwright Test 專案（建議方式，會產生 playwright.config.ts 與 tests/example.spec.ts）
npm init playwright@latest

# 手動安裝
npm i -D @playwright/test
npx playwright install        # 下載瀏覽器

# 執行測試／UI 模式／檢視 HTML 報告
npx playwright test
npx playwright test --ui
npx playwright show-report

# 錄製測試
npx playwright codegen demo.playwright.dev/todomvc

# 只用函式庫
npm i playwright

# 給 Coding Agent 的 CLI
npm install -g @playwright/cli@latest
playwright-cli install --skills   # 選用：安裝 agent skills

# MCP 伺服器（給 Claude Code 等）
claude mcp add playwright npx @playwright/mcp@latest
```

VS Code 使用者可從 Marketplace 安裝 Playwright 擴充，取得執行／除錯測試、錄製、Locator 挑選與 Trace Viewer 整合。

## 適用情境

- 現代 Web App 的端對端（E2E）與跨瀏覽器測試，含 CI（初始化時可產生 GitHub Actions workflow）。
- 爬取、截圖、產生 PDF、網路攔截／Mock 等自動化腳本。
- 行動裝置模擬測試。
- 作為 AI Agent／Coding Agent 操作瀏覽器的底層（透過 Playwright CLI 或 Playwright MCP）。

## 授權與成本

- 授權：Apache-2.0。
- 成本：開源免費；無官方付費方案資訊（資料不足）。

## 限制與注意事項

- 需自行下載瀏覽器二進位檔；README 中的瀏覽器版本會隨 Playwright 版本更新，與使用者日常安裝的瀏覽器不一定相同（Chromium 預設使用 Chrome for Testing）。
- 作業系統支援有明確範圍（見上方系統需求），非列出的 Linux 發行版可能需要額外處理。
- 版本更新可能包含破壞性變更，例如 v1.64.0：裝置描述檔會轉送 `screen`、JSX 遵循 `tsconfig.json`、隱藏 iframe 內元素視為隱藏。
- WebMCP 支援依賴瀏覽器端的實驗性 API。

## 相關工具

- Playwright MCP（本資料夾另一條目）：Playwright 的 MCP 伺服器版本。
- Playwright CLI（`@playwright/cli`）：給 Coding Agent 使用的命令列介面。
- Playwright VS Code Extension。

## 資料來源

- https://github.com/microsoft/playwright
- https://github.com/microsoft/playwright/releases
- https://playwright.dev/docs/intro
- https://playwright.dev/docs/codegen
