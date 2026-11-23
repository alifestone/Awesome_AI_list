# SecurityContext

- **分類**：資安 / 程式碼漏洞研究 / 弱點掃描（開源軟體的資安情資查詢服務）
- **連結**：https://securitycontext.com/
- **API**：https://api.securitycontext.com
- **MCP**：https://mcp.securitycontext.com

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：ProjectDiscovery（Nuclei 的開發商）推出的免費服務，網站自稱「Built for agents」，不用登入，提供 REST API 與 MCP。它是**託管的資料服務**，不是可自架的開源工具；查閱時網站與 API 文件都沒有標示資料或程式碼的授權條款，也沒有公開原始碼倉庫。

## 概述

SecurityContext 把公開 GitHub 倉庫、套件、原生（C/C++）函式庫、NVD 產品與 CVE 的資安暴露情況整理成一份可查詢的資料集，回答「這個東西暴露在哪些風險下」：相依套件帶了哪些 advisory 與惡意版本、是否有洩漏的憑證、過去怎麼修過資安問題、程式碼具備哪些能力，以及 CVE 是否已被利用、有沒有公開 exploit 或 Nuclei 模板。

網站每一頁都有對應的 API 路徑，資料相同；任何 GET 路徑加上 `.md` 就回傳 Markdown，方便直接餵給 LLM。

依 `/v1/index`（資料集時間 2026-11-23）：

| 項目 | 數量 |
|---|---|
| 倉庫 | 173,966（實際掃描 94,982） |
| 組織 | 54,604 |
| 套件 | 340,599 |
| 原生函式庫 | 66 |
| NVD 產品 | 190,304 |
| CVE | 411,525 |
| Advisory | 14,145 |

變更紀錄從 2026-10-02 開始，各來源（弱點資料庫、利用訊號、惡意套件、掃描結果）大多每日更新，套件 registry 資料較舊（查閱時為 2026-11-08）。

## 核心功能／特色

- **倉庫報告**：相依套件與其 advisory、洩漏的憑證（只給數量，人名遮蔽）、資安修補歷史、程式碼能做什麼、風險分數
- **CVE 紀錄**：嚴重度、CVSS、EPSS、CISA 與 VulnCheck KEV、公開 exploit、Nuclei 模板（`?include=templates` 附 YAML），以及哪些倉庫受影響
- **檢查你的技術棧（`/stack`）**：一次丟入套件版本（`ecosystem/name@version`、purl、OS 套件 purl 或 CPE），GET 最多 50 筆、POST 最多 500 筆，每個版本回傳 `affected`／`clean`／`undetermined`、advisory 範圍與修正版本、利用狀態、惡意版本，以及有多少已索引倉庫在用
- **產品版本對 CVE**：例如 `apache/log4j` 2.14.1 受哪些 CVE 影響
- **資安修補（`/security-fixes`）**：專案自身程式碼裡確認過的修補，`disclosed=false` 可找出沒有發 advisory 的「靜默修補」
- **Nuclei 模板索引**：projectdiscovery/nuclei-templates 合併後幾分鐘內上架，含沒有 CVE 的錯誤設定、預設帳密模板
- **掃描新倉庫**：索引沒有的倉庫可用 `POST /v1/scans` 或 MCP 工具即時建立報告
- **訂閱**：最近 30 天的「升級事件」RSS／Atom／JSON Feed（新列入已知被利用、首次出現公開 exploit 或 Nuclei 模板、升為 critical、被 NVD 駁回等），可用 `stack=owner/name` 只看影響某倉庫的 CVE

## 技術架構或運作原理

- **MCP server**：`https://mcp.securitycontext.com`，Streamable HTTP、無狀態、不需 key 或 session。三個工具：
  - `get_security_context`：查單一對象的完整情資（預設為倉庫，也可查套件、函式庫、產品、組織、CVE 或資料集本身）
  - `search_security_context`：以和 REST 列表相同的篩選條件列出倉庫、套件、CVE 等
  - `create_security_context`：掃描索引裡沒有的倉庫後回傳報告
- **REST API**：唯讀 JSON（加 `.md` 為 Markdown），唯一的寫入是 `POST /v1/scans`。`/v1/tools` 把每個端點輸出成 JSON-schema function 定義，可直接當任何模型的 tool list；`/v1/openapi.json` 為 OpenAPI 3.1
- **風險分數**：衡量倉庫目前程式碼的暴露程度，用來排序，不是弱點判定；網站特別說明「列出代表暴露，不代表已被入侵」

## 安裝與使用方式

Claude Code：

```bash
claude mcp add --transport http securitycontext https://mcp.securitycontext.com
```

Cursor（`~/.cursor/mcp.json`）：

```json
{ "mcpServers": { "securitycontext": { "url": "https://mcp.securitycontext.com" } } }
```

Codex（`~/.codex/config.toml`）：

```toml
[mcp_servers.securitycontext]
url = "https://mcp.securitycontext.com"
```

Claude Desktop：Customize → Connectors → Add custom connector，URL 填 `https://mcp.securitycontext.com`，驗證選 No sign in。VS Code、Windsurf 的設定見 `https://api.securitycontext.com/mcp`。

直接用 REST：

```bash
# 倉庫完整情資（Markdown）
curl https://api.securitycontext.com/v1/repositories/facebook/react.md

# 單一 CVE
curl https://api.securitycontext.com/v1/cves/CVE-2021-44228

# 某產品版本受哪些 CVE 影響
curl https://api.securitycontext.com/v1/products/apache/log4j/versions/2.14.1

# 檢查技術棧
curl "https://api.securitycontext.com/v1/stack?p=npm/lodash@4.17.20,pypi/pillow@9.5.0"

# 本週新列入已知被利用的 CVE
curl "https://api.securitycontext.com/v1/cves?changed=known_exploited"
```

完整篩選與排序說明在 `https://api.securitycontext.com/v1/guide`。

## 適用情境

- 收到弱點告警時分流：誰在用受影響版本、是否已被利用、哪個版本修好
- 引入套件前先查 advisory、惡意版本、維護者與使用廣度
- 評估開源專案或供應商的風險與洩漏紀錄
- 依利用狀態與本週變化排定修補優先順序
- 讓 coding agent 改相依套件時，透過 MCP 順手查一次

## 授權與成本

- **授權**：查閱時未標示資料或服務的授權條款，也沒有開源。
- **成本**：免費、不需登入。匿名使用每個 IP 每分鐘 60 次請求（回應帶 `X-RateLimit-*` header，超過回 429），新掃描每小時 3 次；MCP 的 `initialize` 與 `tools/list` 不計次。更高額度要透過 ProjectDiscovery 的付費產品 Neo。

## 限制與注意事項

- 只看得到外部可見的資訊，「列出」代表暴露、不代表已被入侵；風險分數只用於排序
- 倉庫只涵蓋公開 GitHub 倉庫，約 17.4 萬個中實際掃描過的約 9.5 萬個
- 原生函式庫只有 66 個，其中 38 個有版本範圍資料；只有約一半的套件對應得到原始碼倉庫
- 託管服務：查詢內容（例如你的套件清單）會送到 ProjectDiscovery 的伺服器，敏感的內部相依清單請自行評估
- 網站本身沒有說明授權與服務條款，商用或大量轉存資料前請先確認

## 相關工具

- [Nuclei](./Nuclei.md)：同為 ProjectDiscovery，SecurityContext 索引了它的模板；Nuclei 用來實際掃描執行中的服務
- [OWASP CVE Lite CLI](./CVE-Lite-CLI.md)：本機掃 JS/TS 相依套件，資料不離開本機
- OSV、deps.dev、Socket：類似的套件／弱點資料來源

## 資料來源

- https://securitycontext.com/
- https://securitycontext.com/llms.txt
- https://api.securitycontext.com/
- https://api.securitycontext.com/mcp
- https://api.securitycontext.com/v1/index.md
