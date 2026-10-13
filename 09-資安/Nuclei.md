# Nuclei

- **分類**：資安 / 弱點掃描
- **連結**：https://github.com/projectdiscovery/nuclei

## 原清單說明

原清單寫作「nulcei」，附上 Nuclei 與 nuclei-mcp 兩個連結，沒有說明。

> **查證結果**：「nulcei」應為 **Nuclei** 的拼字錯誤。Nuclei 是 ProjectDiscovery 的開源弱點掃描器；nuclei-mcp 是第三方 MCP 包裝，另見 [Nuclei MCP](./Nuclei-MCP.md)。

## 概述

Nuclei 是以 YAML 模板（template）為基礎的高效能弱點掃描器，由 ProjectDiscovery 開發。每個模板描述「要送什麼請求、怎麼判斷結果」，可掃描網頁應用、API、網路、DNS 與雲端設定。社群維護的 [nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) 會持續加入新漏洞的檢測模板。

近期版本加入 AI 功能：可用自然語言 prompt 產生並執行模板，也可在模板中使用 LLM 做語意比對。

查閱時 GitHub 顯示約 32k stars、3.9k forks；最新版本為 **v3.11.1（2026-08-08）**。

## 核心功能／特色

- **YAML 模板**：簡單易寫，可自訂各種檢測情境
- **社群模板庫**：快速涵蓋新出現的漏洞
- **模擬真實步驟驗證漏洞**，降低誤報
- **平行掃描與請求叢集**，速度快
- **多協定**：HTTP、DNS、TCP、SSL、WHOIS、JavaScript、code 等
- **CI/CD 整合**：可用於偵測與回歸測試
- **報告整合**：Jira、Splunk、GitHub、Elastic、GitLab
- **AI 功能**（依 README 的參數說明）：
  - `-ai, -prompt`：以 AI prompt 產生並執行模板
  - `-llm`：啟用 LLM 語意 matcher 與 extractor
  - `-llm-provider`：openai、ollama、llamacpp、vllm、lmstudio、groq、openrouter、together（預設 openai）
  - `-llm-base-url`、`-llm-model`：可指向本機或任何 OpenAI 相容端點
- **模板簽章**：`-sign` 簽署模板，`-dut` 可停用未簽章模板

## 技術架構或運作原理

以 Go 撰寫。掃描時讀取模板，依模板定義的協定送出請求，再用 matcher（字串、正則、狀態碼、DSL，或 LLM 語意比對）判斷是否命中，用 extractor 擷取資料。`code` 類模板可執行本機程式碼，預設不載入，需加 `-code` 才會啟用。

ProjectDiscovery 另有雲端平台，提供免費的 AI 模板編輯器。`-ai` 產生模板的細節與是否需要雲端帳號，README 未詳述，請參考官方文件。

## 安裝與使用方式

需 Go 1.24.2 以上：

```bash
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

常用指令：

```bash
nuclei -target https://example.com           # 掃描單一目標
nuclei -list urls.txt                        # 掃描清單
nuclei -target 192.168.1.0/24                # 掃描網段
nuclei -u https://example.com -t my.yaml     # 使用自訂模板
nuclei -target https://example.com -dashboard
```

## 適用情境

- 授權範圍內的資產弱點盤點與 bug bounty 偵查
- 在 CI/CD 中對自家服務做回歸檢測
- 新漏洞公開後，快速以社群模板檢查自家暴露面
- 搭配 LLM 撰寫或產生自訂檢測模板

## 授權與成本

- **授權**：MIT。
- **成本**：開源免費；使用雲端 LLM 做語意比對時需自付 API 費用。

## 限制與注意事項

- **僅限授權目標**：主動掃描未經授權的系統屬違法行為。
- 社群模板品質不一，`code` 類模板會在本機執行程式碼，載入第三方模板前應先審查。
- 大量平行請求可能影響目標服務，應調整 rate limit。
- LLM 語意比對可能誤判，結果需人工驗證；送往雲端 LLM 的回應內容可能含敏感資料。

## 相關工具

- [Nuclei MCP](./Nuclei-MCP.md)：讓 AI 透過 MCP 呼叫 Nuclei
- [Pentest Swarm AI](./Pentest-Swarm-AI.md)：其 recon agent 包裝了 Nuclei 等 ProjectDiscovery 工具
- subfinder、httpx、katana：ProjectDiscovery 的其他偵查工具

## 資料來源

- https://github.com/projectdiscovery/nuclei
- https://github.com/projectdiscovery/nuclei/releases
- https://github.com/projectdiscovery/nuclei-templates
