# 🌐 瀏覽器自動化

用程式或 AI 操作瀏覽器的工具：自動測試、爬取網頁、填表，以及讓 AI agent 上網做事。

### [Playwright](Playwright.md)

Microsoft 開源的網頁測試與自動化框架，用單一 API 驅動 Chromium、Firefox 與 WebKit。包含測試執行器、函式庫、給 coding agent 用的 Playwright CLI、MCP 伺服器與 VS Code 擴充套件。

可以做到：
- 現代 Web App 的端對端（E2E）與跨瀏覽器測試，並放進 CI。
- 爬取、截圖、產生 PDF、攔截或 mock 網路請求。
- 模擬行動裝置測試。
- 當 AI agent 操作瀏覽器的底層。

### [Playwright MCP](Playwright-MCP.md)

Microsoft 的 MCP 伺服器，讓 Claude Code、VS Code、Cursor、Codex 等 LLM 用戶端透過 Playwright 操作瀏覽器。它讀取頁面的結構化無障礙快照，而不是截圖，所以不需要視覺模型。

可以做到：
- 讓 AI agent 查資料、填表、跑跨頁流程。
- 自我修復測試、需要維持瀏覽器狀態的長流程。
- 由 LLM 產生 locator、驗證頁面內容，並把操作錄成測試程式碼。

## 怎麼挑

- **寫測試、跑 CI**：Playwright。
- **讓 AI 即時操作瀏覽器**：Playwright MCP。官方建議：如果主要是 coding agent 寫程式、跑測試又在意 token 成本，改用 Playwright CLI + Skills 比較省。
- **要更快、更便宜的網頁 agent**：另見 [Jev 決策模型生態](../07-Jev-決策模型生態/) 的 Jev Ultrafast。
