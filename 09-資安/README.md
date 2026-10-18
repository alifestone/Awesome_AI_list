# 🔐 資安

AI 輔助的資安工具：逆向工程、滲透測試、程式碼漏洞研究與弱點掃描、LLM 應用的紅隊測試，以及 AI agent 的安全規格。

> ⚠️ 這裡許多工具是雙重用途，**只能用在你擁有或取得書面授權的系統上**。收錄目的是防禦、教學與合法授權測試。

## 逆向工程

### [Ghidra](Ghidra.md)

NSA 開源的逆向工程框架，可分析多種處理器指令集與執行檔格式，支援互動與自動化，能用 Java 或 Python 寫腳本。Apache-2.0。

可以做到：
- 惡意程式分析、事件回應、韌體與嵌入式系統分析。
- 漏洞研究與修補程式比對。
- CTF 逆向題、原始碼遺失時維護遺留系統。
- 當 GhidraMCP、REA 等 AI 逆向工具的後端。

### [GhidraMCP](GhidraMCP.md)

用 MCP 把 Ghidra 接到 Claude Code 等 LLM 用戶端。Apache-2.0。

可以做到：
- 讓 AI 直接反編譯函式、列出符號、重新命名變數與函式，協助理解二進位程式。
- 替大量未命名函式自動推測並套用有意義的名稱。
- 以 headless 模式整合進自動化分析流程。

### [REA](REA.md)

「Reverse Engineer Anything」：透過 MCP 或 CLI 把逆向能力交給 AI agent，在本機分析原生二進位、Electron、.NET、APK、WASM、韌體等目標，並回傳附證據的發現。原生分析可用 Hopper、Ghidra 或 IDA（Hopper 經核准才會選擇性安裝）。MIT。

可以做到：
- 讓 agent 逆向分析 macOS 原生 app、Electron 應用、APK 等，並附上證據。
- 惡意程式分析、軟體互通性研究、舊遊戲與停止維護軟體的保存。
- 根據分析結果撰寫並測試重新實作。

## 滲透測試

### [Pentest Copilot](Pentest-Copilot.md)

BugBase 的 AI 滲透測試 agent：連接一台 Kali 攻擊機，自主執行資安工具、分析輸出、決定下一步。MIT。

可以做到：
- 在授權的委託案中輔助偵查與例行工作。
- 練習 HackTheBox、TryHackMe 等靶機與 CTF。
- 把 Burp Suite、VPN、Kali 工具整合到同一個 AI 工作台。

### [ARTEX](ARTEX.md)

多個 LLM agent 協作的自主滲透測試平台（Go + Next.js），百度「agent+」攻防挑戰賽冠軍專案。⚠️ 原作者已下架，連結為第三方備份。AGPL-3.0。

可以做到：
- 研究多 agent 自主滲透測試的架構（規劃者／執行者分工、雙圖記憶、審批閘門）。
- 在完全隔離的實驗環境中做技術驗證與教學。
- 讓防守方了解這類工具的能力與流量特徵。

### [Pentest Swarm AI](Pentest-Swarm-AI.md)

以 AI agent「蜂群」對 API 與網頁應用做自主滲透測試，agent 在共享黑板上交換發現，攻擊鏈經實際驗證後才寫進報告。自稱 XBOW 的開源替代，多項功能仍是 alpha／beta。AGPL-3.0。

可以做到：
- 授權的 API／網頁應用滲透測試與 bug bounty 偵查。
- 用內建靶場（Juice Shop、crAPI）學 API 攻擊手法。
- 以 GitHub Action 在 CI 中做持續安全測試。

### [Claude-Red](Claude-Red.md)

攻擊性資安的 Claude Skills 集合（78 個 skill、23 類），每個 skill 針對一個攻擊面，依對話內容按需載入。MIT。

可以做到：
- 在授權紅隊演練中，讓 Claude 依專業方法論協助分析。
- Bug bounty 分流與報告撰寫、CTF 練習。
- 當撰寫自家資安 skill 的範本。

## 程式碼漏洞研究 / 弱點掃描

### [open-kritt](open-kritt.md)

自架的程式碼漏洞研究平台：把研究拆成許多小任務，平行交給 Codex／Claude Code 執行，再驗證、排序與去重。AGPL-3.0。

可以做到：
- 對授權範圍內的開源程式碼做大規模 AI 審查。
- 審計自家程式碼與相依套件。
- 參考如何把漏洞研究拆成可重複的 agent 工作流程。

### [Nuclei](Nuclei.md)

ProjectDiscovery 以 YAML 模板為基礎的高效能弱點掃描器，社群持續更新新漏洞的檢測模板；新版可用自然語言產生模板、用 LLM 做語意比對。MIT。

可以做到：
- 盤點授權範圍內資產的弱點。
- 新漏洞公開後，快速檢查自家暴露面。
- 在 CI/CD 中對自家服務做回歸檢測。

### [Nuclei MCP](Nuclei-MCP.md)

第三方 MCP server，讓 Claude Code 等 AI 用戶端呼叫 Nuclei。⚠️ 早期專案，可能有破壞性變更。MIT。

可以做到：
- 讓 AI agent 執行 Nuclei 掃描並解讀結果。
- 用自然語言請 agent 撰寫、新增並測試自訂模板。

### [OWASP CVE Lite CLI](CVE-Lite-CLI.md)

在本機、push 之前執行的 JS/TS 相依套件弱點掃描器，直接告訴你「要跑什麼指令修正」。本身不是 AI 工具。MIT。

可以做到：
- push 前快速檢查相依套件弱點，原始碼不離開本機。
- 在 CI 中用 SARIF 和 `--fail-on` 設安全門檻；產出 SBOM；離線掃描。
- 讓 AI coding agent 改完 `package.json` 後自動跑一次檢查。

## AI agent 安全規格 / 治理

### [Foundry Security Spec](Foundry-Security-Spec.md)

Cisco 把內部安全評估系統的設計提煉成的開放規格：8 個核心 agent 角色、11 條憲章原則，把雜訊告警變成「有界、排序、可驗證的發現」。不含程式碼，搭配 spec-kit 產生實作。CC BY 4.0。

可以做到：
- 企業自建 AI 程式碼安全評估系統時，當架構藍圖。
- 設計 AI 漏洞研究工具時，參考角色分工、驗證與去重的做法。

## LLM 測試 / 紅隊

### [Promptfoo](Promptfoo.md)

LLM 應用的評測、回歸測試與紅隊工具：用 YAML 定義 prompt、模型與測試案例，在本機執行。MIT。

可以做到：
- 並排比較不同模型與 prompt 的輸出。
- 把 LLM 應用的品質回歸測試放進 CI/CD。
- 上線前對 chatbot、RAG、agent 做紅隊測試（prompt injection、資料外洩、越權、有害輸出），並為 OWASP LLM Top 10 等合規需求準備證據。

## 怎麼挑

- **分析二進位程式**：Ghidra + GhidraMCP；要一個 MCP 涵蓋原生程式、Electron、APK、WASM 等多種目標：REA。
- **滲透測試**：先從 Pentest Copilot 或 Claude-Red 開始；要多 agent 自主化：Pentest Swarm AI。
- **審查自己的程式碼**：AI 深度審查用 open-kritt，已知漏洞掃描用 Nuclei，JS/TS 相依套件用 CVE Lite CLI。
- **測試自己的 LLM 應用**：紅隊與 YAML 設定用 Promptfoo；偏品質評測的 [DeepEval](../06-Agent-框架與編排/DeepEval.md) 在 Agent 框架類。
- **設計 AI 資安系統**：Foundry Security Spec；skill 發布前的安全政策可參考 [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md)。
