# CyberStrikeAI

- **分類**：資安
- **連結**：https://github.com/AIPentest/CyberStrikeAI

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：用 Go 寫的自架 AI 資安作業平台，有 Web 主控台：AI agent 把自然語言指令轉成實際的資安工具呼叫，搭配 MCP、知識庫（RAG）、視覺化工作流、攻擊鏈分析、資產與漏洞管理、人工審批與稽核紀錄。另內建 WebShell 管理與 **C2**。原 repo 為 `Ed1s0nZ/CyberStrikeAI`，現已轉移到 `AIPentest` 組織（舊網址會轉址，README 的 clone 指令仍寫舊網址）。⚠️ 高度雙重用途，僅限自有或取得書面授權的系統。Apache-2.0。

## 概述

部署後在瀏覽器開 Web 主控台，設定一個 OpenAI 相容的模型通道（OpenAI、DeepSeek、Qwen、本機模型等），就能用一句話下指令，例如「列舉 example.com 的子網域，再對結果跑 nuclei」。agent 會挑工具、執行、讀結果，發現寫進漏洞管理與專案攻擊鏈，整個過程留稽核紀錄、可逐步重播。

v1.8.0（2026-11-13）把 agent 引擎從 Eino 換成 **Pi SDK**（由獨立的 Node worker 執行，Go 端負責權限、MCP 執行與證據）。repo 建立於 2025-11-08，至今仍每天更新；查詢當下（2026-11-19）約 8.8k 顆星、2k forks。已加入知道創宇的 404StarLink 計畫，README 也列出騰訊 TCH 智慧滲透賽事的名次。

## 核心功能／特色

- **Agent 編排**：單 agent，以及 Deep、Plan-Execute、Supervisor 三種多 agent 模式；可用圖形化工作流把 agent、工具、條件判斷、審批串成可重用流程。
- **14 個預設角色**：針對不同測試情境的提示詞與工具權限。
- **工具**：`tools/` 有 90 多個 YAML 工具定義（README 寫 100+），涵蓋掃描（nmap、masscan）、web（sqlmap、ffuf、nuclei）、子網域、FOFA／Shodan 等測繪引擎、API、容器、雲端（prowler、pacu）、二進位分析、漏洞利用（metasploit）、密碼破解、鑑識、後滲透（mimikatz、bloodhound、impacket）、CTF 工具；沒裝的工具執行時會略過或替代。
- **MCP**：支援 HTTP、stdio、SSE 與外部 MCP server 聯合；工具呼叫有逾時、可取消、斷路器與輸出上限。也能以 MCP stdio 模式被其他用戶端呼叫。
- **Agent Skills**：標準 `SKILL.md` 格式，按需載入。
- **知識庫**：查詢改寫、向量檢索、rerank。
- **視覺模型**：另接一個視覺模型看截圖、驗證碼與 UI。
- **治理**：人工審批模式、工具白名單、稽核 agent 複核；工具呼叫前可用 regex 攔截（**預設擋政府網域**）；多使用者 RBAC、稽核紀錄、SQLite 儲存。
- **作業管理**：專案與攻擊鏈（跨對話事實、風險評分、圖形檢視、重播）、資產管理（網域／IP／埠／服務去重，XLSX／CSV 匯入匯出）、漏洞生命週期與複測追蹤、批次任務、Word 報告。
- **WebShell 管理與內建 C2**：listener、加密 beacon、session、任務佇列、payload 輔助。
- **外掛**：Burp Suite 擴充、Chrome／Edge DevTools 擴充（把網路流量送進平台分析）。
- **聊天機器人**：個人微信、企業微信、釘釘、飛書、Telegram、Slack、Discord、QQ。
- **一鍵更新**：主控台或 `./cyberstrike-ai -update`，保留本機的角色、skill、工具與設定，可 rollback。

## 安裝／使用方式

需要 Go 1.25+、Python 3.10+，以及 Node.js 22.19+（Pi worker 用）：

```bash
git clone https://github.com/AIPentest/CyberStrikeAI.git
cd CyberStrikeAI
chmod +x run.sh && ./run.sh        # 預設 HTTPS（自簽憑證）；./run.sh --http 改用 HTTP
```

1. 終端機顯示 `● ONLINE` 與網址後打開（預設 `https://127.0.0.1:8080/`），接受自簽憑證警告。
2. 用終端機印出的一次性 `admin` 密碼登入，並立即修改。
3. 到「系統設定 → 基本設定 → AI 通道設定」填 provider、Base URL、API key、model；或先改 `config.yaml`（範本見 `config.example.yaml`）。
4. 依需要安裝 `tools/` 列出的資安工具（如 `apt install nmap sqlmap nuclei ...`）。

## 授權與成本

- **Apache-2.0**。
- 軟體免費；成本為 LLM API 用量（支援 OpenAI 相容端點，可接本機模型）。FOFA、Shodan 等測繪服務需自備帳號。

## 限制與注意事項

- **只能用在自有或取得書面授權的系統**；README 要求在共用或正式環境啟用高風險工具、WebShell、C2 前，先看 security model 與 hardening 文件。
- 內建 C2、WebShell、後滲透工具，能力範圍比一般「AI 掃描器」大得多，部署時務必限制網路暴露與帳號權限。
- 預設只聽 `127.0.0.1`；對外開放前要設正式 TLS 憑證並強化設定。
- 升級時官方要求先備份 `config.yaml` 與 `data/`，並看 release notes 的設定／資料庫變更。
- 社群與文件以中文為主（有英文 README 與 `docs/en-US`），支援管道為 Discord 與企業微信群。

## 相關工具

- [PentestCode](PentestCode.md)：終端機版的多 agent 自主滲透 agent，偏內網與 AD；本工具則是有 Web 主控台、資產／漏洞管理的團隊平台。
- [ARES](https://github.com/Mafifrizi/ARES)：同樣是自架、有範圍控管與報告的紅隊演練平台。
- [Pentest Copilot](Pentest-Copilot.md)、[Pentest Swarm AI](Pentest-Swarm-AI.md)：其他 AI 滲透測試工具。
- [Nuclei](Nuclei.md)：本平台內建的弱點掃描工具之一。

## 資料來源

- https://github.com/AIPentest/CyberStrikeAI
- https://github.com/AIPentest/CyberStrikeAI/blob/main/docs/en-US/pi-runtime.md
- https://github.com/AIPentest/CyberStrikeAI/releases/tag/v1.8.0
