# Nuclei MCP

- **分類**：資安 / 弱點掃描
- **連結**：https://github.com/addcontent/nuclei-mcp

## 原清單說明

原清單與 Nuclei 列在同一項（「nulcei」），附上此連結，沒有說明。

> **查證結果**：這是第三方（`addcontent`）的 MCP server，把 [Nuclei](./Nuclei.md) 包裝成 MCP 工具，不是 ProjectDiscovery 官方專案。

## 概述

Nuclei MCP 是以 Go 撰寫的 Model Context Protocol server，讓支援 MCP 的 AI client（如 Claude Code、Claude Desktop）可以呼叫 Nuclei 執行掃描、管理模板與查詢結果。

查閱時 GitHub 顯示 49 stars、9 forks、34 commits；README 表示專案仍在積極開發中，可能有破壞性變更。

## 核心功能／特色

提供的 MCP 工具：

| 工具 | 用途 |
| --- | --- |
| `nuclei_scan` | 完整掃描，支援進階篩選 |
| `basic_scan` | 最少設定的快速掃描 |
| `vulnerability_resource` | 查詢與取得掃描結果 |
| `add_template` | 新增自訂模板 |
| `list_templates` | 列出可用模板 |
| `get_template` | 取得單一模板內容 |

其他：結果快取、併發掃描、含嚴重度與修補建議的結構化報告。

## 技術架構或運作原理

- 以 Go 撰寫，使用 `mark3labs/mcp-go`
- 兩種傳輸模式：`stdio`（由 client 以子程序啟動）與 `http`（獨立伺服器，預設 `127.0.0.1:3000`）
- 設定來源依序為：`--config` 參數、`./config.yaml`、`$HOME/.nuclei-mcp/config.yaml`、`/etc/nuclei-mcp/config.yaml`；也可用 `NUCLEI_MCP_` 前綴的環境變數
- 預設值範例：快取 1 小時、Nuclei timeout 5 分鐘、rate limit 150
- 若找不到 Nuclei，README 表示會自動下載

## 安裝與使用方式

README 中的安裝指令與 Releases 連結仍是 `your-org` 佔位符，需自行改成 `addcontent`。查閱時 Releases 頁面為空，建議從原始碼建置：

```bash
git clone https://github.com/addcontent/nuclei-mcp.git
cd nuclei-mcp
go build -o nuclei-mcp ./cmd/nuclei-mcp
./nuclei-mcp
```

或直接執行：`go run cmd/nuclei-mcp/main.go`。

可用 MCP Inspector 測試：`npx @modelcontextprotocol/inspector`。接到 MCP client 時，README 提供以 `go run` 啟動並設定環境變數的 JSON 範例。

## 適用情境

- 讓 AI agent 在授權範圍內自動執行 Nuclei 掃描並解讀結果
- 用自然語言請 agent 撰寫、新增並測試自訂模板
- 把弱點掃描整合進 AI 輔助的資安工作流程

## 授權與成本

- **授權**：MIT。
- **成本**：免費。

## 限制與注意事項

- **非官方、早期專案**：star 數少、README 有佔位符連結、沒有正式 release；README 建議正式使用時鎖定版本。
- **AI 自主掃描風險**：agent 可能掃描超出授權範圍的目標，應在設定或 prompt 層面限制目標，並保留紀錄。
- HTTP 模式不應暴露到外部網路。
- 只掃描有權測試的系統。

## 相關工具

- [Nuclei](./Nuclei.md)：底層掃描器
- [Pentest Swarm AI](./Pentest-Swarm-AI.md)：也提供 MCP server，並內建 Nuclei
- [GhidraMCP](./GhidraMCP.md)：同樣以 MCP 包裝資安工具的例子

## 資料來源

- https://github.com/addcontent/nuclei-mcp
- https://github.com/projectdiscovery/nuclei
