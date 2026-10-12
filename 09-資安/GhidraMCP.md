# GhidraMCP

- **分類**：資安 / 逆向工程
- **連結**：https://github.com/LaurieWired/GhidraMCP

## 原清單說明

讓 LLM 透過 MCP 操作 Ghidra。

> **查證結果**：與 README 一致。README 形容它是一個 Model Context Protocol（MCP）server，讓 LLM 自主對應用程式做逆向工程，並把「大量 Ghidra 核心功能」以工具形式提供給 MCP client。

## 概述

GhidraMCP 由 LaurieWired 開發，用 MCP 把 NSA 開源逆向工程框架 [Ghidra](./Ghidra.md) 接到 LLM client（例如 Claude Code、VS Code）。接上後，AI 助手可以直接叫 Ghidra 反編譯函式、列出符號、重新命名變數與函式，協助分析人員理解二進位程式。

查閱時 GitHub 頁面顯示約 11.1k stars、1.1k forks，採 Apache-2.0 授權。最新 release 是 **GhidraMCP 2.0**（Releases 頁標示 10 月 10 日，未顯示年份），說明為：更新支援 Ghidra 12.1.4、「不再需要 Python bridging」、新增 headless 模式、修正與更新工具。

## 核心功能／特色

- 在 Ghidra 中反編譯與分析二進位檔
- 自動重新命名函式（method）與資料
- 列出 methods、classes、imports、exports
- 舊版 release 陸續加入交叉參照（xrefs，1.3 版）與字串搜尋（1.3 版）
- **Headless 模式**（2.0 版）：不開 Ghidra GUI，透過 PyGhidra 直接匯入並分析二進位檔
- 支援 stdio 與 streamable HTTP 兩種 MCP 傳輸方式

README 沒有列出完整的 MCP 工具名稱清單，具體工具名稱資料不足。

## 技術架構或運作原理

依 README，架構分兩部分：

1. **Ghidra 外掛（Java）**：以 Ghidra extension 安裝，在 Ghidra 內啟動 HTTP server（預設 port 8080，可在 Tool Options 修改）。
2. **Python MCP server（`ghidra-mcp`）**：接收 MCP client 的請求，再轉送到 `--ghidra-server` 指定的 Ghidra HTTP server。stdio 模式由 client 啟動；streamable HTTP 模式預設在 port 8081 的 `/mcp`。

> 備註：2.0 版 release 說明寫「不再需要 Python bridging」，但 README 仍描述 Python 版的 `ghidra-mcp` 元件，下載包也含「Ghidra 外掛與 Python MCP client」。可能是指舊版 `bridge_mcp_ghidra.py` 腳本已改成可用 `uvx` 安裝的套件，但官方沒有明確說明，此處資料不足。

## 安裝與使用方式

需求：Ghidra 12.1.4；Python 3.10 以上（headless 模式需 3.10–3.13）；建議安裝 `uv`；從原始碼建置需 Java 21。

1. 從 Releases 下載對應 Ghidra 版本的 zip。
2. 在 Ghidra 中 `File → Install Extensions` 安裝後重新啟動。
3. 在 `File → Configure → Developer` 啟用 `GhidraMCPPlugin`。
4. 在 MCP client 註冊 server。以 Claude Code 為例，README 提供的指令形式為：

```bash
claude mcp add ghidra -- uvx --from git+https://github.com/LaurieWired/GhidraMCP ghidra-mcp --ghidra-server http://127.0.0.1:8080/
```

其他 client 可用 JSON 設定，以 `uvx` 啟動 `ghidra-mcp` 並指向 `--ghidra-server`。VS Code 可用 `.vscode/mcp.json` 或「MCP: Add Server」設定。需要以 URL 連線的 client，要自行用 `--transport streamable-http` 啟動。

- 從原始碼：先設定 `GHIDRA_INSTALL_DIR`，再用 Ghidra 的 Gradle wrapper 執行 `buildExtension`，產物在 `extension/dist/`。
- 開發：`uv run ghidra-mcp` 啟動，`uv run pytest` 測試。
- Headless：需要 extension（或 `--extension-jar`）與 `GHIDRA_INSTALL_DIR`；要保留分析結果須加 `--project`。

## 適用情境

- 惡意程式分析、事件回應中，讓 AI 協助快速理解反編譯結果
- 為大量未命名函式自動推測並套用有意義的名稱
- CTF 逆向題、軟體互通性研究、分析自己擁有的軟體
- 以 headless 模式整合進自動化分析流程

## 授權與成本

- **授權**：Apache-2.0。
- **成本**：GhidraMCP 與 Ghidra 都免費；搭配的 LLM client 或 API 可能另有費用。

## 限制與注意事項

- 一定要有執行中的 Ghidra（GUI 或 headless）並安裝外掛，bridge 無法單獨運作。
- 版本綁定：目前說明針對 Ghidra 12.1.4，舊版外掛對應舊版 Ghidra（例如 1.4 版對應 11.3.2）。
- macOS 上使用 headless 模式，需要先用 `buildNatives` 建置一次 Ghidra 反編譯器。
- README 沒有說明 HTTP 端點的認證或安全設計。建議只綁定在 127.0.0.1，不要暴露到網路上。
- 把二進位內容送進雲端 LLM 前，要確認符合資料保護與保密規定（例如客戶樣本、機密韌體）。
- AI 對反編譯結果的解讀與命名可能出錯，重要結論應由人工驗證。
- **合法使用**：只分析自己擁有、已取得授權，或法律允許研究（例如惡意程式分析、互通性）的軟體，並遵守軟體授權條款與當地法規。

## 相關工具

- [Ghidra](./Ghidra.md)：底層逆向工程框架
- [REA](./REA.md)：多目標逆向 MCP，可使用 Ghidra、Hopper 或 IDA 作為原生分析引擎
- PyGhidra：headless 模式使用的 Python 介面

## 資料來源

- https://github.com/LaurieWired/GhidraMCP
- https://github.com/LaurieWired/GhidraMCP/releases
