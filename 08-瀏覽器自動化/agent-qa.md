# agent-qa

- **分類**：瀏覽器自動化
- **連結**：https://vostride.com

## 原清單說明

網頁、Android 與 iOS 的自然語言測試，結合 memidex 持久記憶與經驗證的自我改進。

## 概述

agent-qa 是 vostride 的應用程式測試工具，可透過 CLI、本機儀表板或 MCP 編寫與執行測試，並保留截圖及步驟證據。

## 核心功能／特色

- **跨平台測試**：以自然語言描述網頁、Android 與 iOS 的操作及預期結果。
- **memidex 記憶**：保存經驗證的應用知識，供後續測試使用。
- **自我改進**：從執行證據產生候選經驗，通過檢查後才採用。
- **可追查結果**：透過 CLI 或 MCP 讀取執行結果、截圖及步驟證據。

## 技術架構或運作原理

測試先完成判定，再進行診斷、學習與驗證。自我改進更新應用知識與可重用的操作，不會改寫工具自己的程式碼或提示詞。CI 執行只提出候選知識。

## 安裝與使用方式

依[CLI 文件](https://vostride.com/docs/agent-qa/cli)設定模型與執行環境後，可啟動專案內的 MCP 伺服器：

```sh
npx agent-qa mcp
```

MCP 用戶端可藉此編寫測試、執行測試與讀取證據；詳見[MCP 文件](https://vostride.com/docs/agent-qa/mcp)。

## 適用情境

網頁及行動應用的端對端回歸測試，以及 coding agent 完成變更後的應用驗證。

## 授權與費用

[FSL-1.1-ALv2](https://github.com/vostride/agent-qa/blob/main/LICENSE.md)；授權允許範圍內可免費使用，各版本滿兩年後可改依 Apache-2.0 使用。模型供應商及執行基礎設施可能另有費用。

## 限制與注意事項

需要模型設定與對應的瀏覽器或行動裝置環境。本條目依官方文件查證，未做實機測試；沒有引用未驗證的速度或成功率比較。

## 相關工具

[Playwright](Playwright.md)、[Playwright MCP](Playwright-MCP.md)。

## 資料來源

- [官方網站](https://vostride.com)
- [GitHub](https://github.com/vostride/agent-qa)
- [自我改進流程](https://vostride.com/docs/agent-qa/self-improvement)
