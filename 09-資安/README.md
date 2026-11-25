# 🔐 資安

AI 輔助的資安工具：逆向工程、滲透測試、程式碼漏洞研究與弱點掃描、威脅偵測與監控，以及 AI agent 的安全規格。LLM 應用的紅隊測試工具 Promptfoo 在 [🧠 Agent 框架與編排](../06-Agent-框架與編排/) 的「LLM 評測」。

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

### [ARES](https://github.com/Mafifrizi/ARES)

自架的授權紅隊演練自動化平台，針對 Active Directory 與雲端環境，內建範圍強制檢查（ScopeGuard）、攻擊路徑圖與報告產出，可選擇接 LLM 輔助規劃。作者為匿名個人，尚無獨立條目檔，連結直接指向 GitHub。⚠️ 雙重用途，只能用在取得書面授權的系統上。MIT。

可以做到：
- 在授權的紅隊演練中，把範圍控管、執行紀錄與報告放在同一個平台。
- 讓防守方了解這類平台的能力，用於偵測與防禦規劃。
- 參考「範圍檢查在執行前強制攔截」的設計。

### [Claude-Red](Claude-Red.md)

攻擊性資安的 Claude Skills 集合（78 個 skill、23 類），每個 skill 針對一個攻擊面，依對話內容按需載入。MIT。

可以做到：
- 在授權紅隊演練中，讓 Claude 依專業方法論協助分析。
- Bug bounty 分流與報告撰寫、CTF 練習。
- 當撰寫自家資安 skill 的範本。

### [Claude-BugHunter](Claude-BugHunter.md)

給 Claude Code 的 bug bounty／外部紅隊 skill 組：83 個 skill、15 個 slash command，hunt 類整理自 681 份公開 HackerOne 報告，另有 M365／Okta／VPN／vCenter 等企業平台攻擊串連、送出前的範圍驗證關卡與各平台報告格式；可接 Burp MCP、HackerOne MCP，skill 也能裝到 Codex CLI、OpenCode 等。程式碼 MIT、內容 CC BY 4.0。⚠️ 高度雙重用途，僅限授權目標；只涵蓋外部攻擊面。

可以做到：
- 在授權 bug bounty 中跑偵察、排序攻擊面，依漏洞類別測試並驗證。
- 依 HackerOne、Bugcrowd 等平台規則寫報告，截圖去敏。
- 外部紅隊演練中評估企業對外平台並產出客戶報告。

### [CyberStrikeAI](CyberStrikeAI.md)

用 Go 寫的自架 AI 資安作業平台，有 Web 主控台：agent 把自然語言指令轉成 90 多個資安工具的實際呼叫，搭配 MCP、知識庫、圖形化工作流、攻擊鏈分析、資產與漏洞管理、人工審批與稽核紀錄，另內建 WebShell 管理與 C2；可接 OpenAI 相容的任何模型。⚠️ 高度雙重用途，僅限授權系統。Apache-2.0。

可以做到：
- 團隊在授權演練中共用一個平台管理資產、漏洞、任務與攻擊鏈。
- 用一句話串起子網域列舉、掃描、弱點驗證，並保留可重播的證據。
- 透過 Burp／瀏覽器擴充把抓到的流量交給 AI 分析。

### [PentestCode](PentestCode.md)

終端機裡的自主滲透測試 agent，OpenCode 的 hard fork：主導 agent 平行派出 recon、AD、webapp、後滲透等 12 個子 agent，共用一份可跨 session 保存的 engagement state（主機、漏洞、憑證、存取權、關係圖），並推薦攻擊路徑；支援 20+ 個 LLM provider。Beta。⚠️ 高度雙重用途，僅限授權測試。MIT。

可以做到：
- 授權內網滲透與 AD 測試：從掃描、列舉、憑證噴灑一路到網域管理員，每步附證據。
- 練 HTB 與 CTF 靶機。
- 用 `guided` 模式逐步核准每個動作，最後產出報告。

### [Cairn](Cairn.md)

「通用狀態空間搜尋引擎」，首先用在自主滲透測試：agent 不分角色，只透過共享的事實－意圖圖（黑板）協作，人類可隨時注入提示；worker 可用 Claude Code、Codex 或 Pi，支援 Docker 容器或本機模式。騰訊雲黑客松 AI 滲透測試賽唯一全解 54 題的隊伍（排名第 3）。⚠️ 雙重用途，僅限授權測試；本機模式沒有沙箱。AGPL-3.0，商用需另購授權。

可以做到：
- 授權的黑箱滲透測試與 CTF 解題，用已訂閱的 Claude Code／Codex CLI 當 worker。
- 研究沒有固定角色、靠共享黑板協作的多 agent 架構。
- 在自動探索過程中隨時加入人類判斷（Hint）引導方向。

## 程式碼漏洞研究 / 弱點掃描

### [open-kritt](open-kritt.md)

自架的程式碼漏洞研究平台：把研究拆成許多小任務，平行交給 Codex／Claude Code 執行，再驗證、排序與去重。AGPL-3.0。

可以做到：
- 對授權範圍內的開源程式碼做大規模 AI 審查。
- 審計自家程式碼與相依套件。
- 參考如何把漏洞研究拆成可重複的 agent 工作流程。

### [Cloudflare Security Audit Skill](Cloudflare-Security-Audit-Skill.md)

Cloudflare 官方的 coding agent skill，也是其內部漏洞挖掘 harness 的起點：主控 agent 協調隔離的子 agent，跑偵查、依覆蓋率搜尋、對抗式驗證、獨立複核與報告六個階段，產出可機器驗證的 `findings.json`。執行目標程式碼前要求 OS 層級沙箱。MIT。

可以做到：
- 對自家 codebase 做完整 AI 資安稽核，區分「確認／待驗證／已推翻」三種結果。
- 平常問資安問題或審查特定模組（預設的 guidance mode，不產生檔案）。
- 重複執行，利用覆蓋率帳本補齊上次的盲點。

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

### [SecurityContext](SecurityContext.md)

ProjectDiscovery 的免費資安情資服務：查公開 GitHub 倉庫、套件、原生函式庫、NVD 產品與 CVE 的暴露情況（相依 advisory、惡意版本、洩漏憑證數、修補歷史、KEV／EPSS／公開 exploit／Nuclei 模板），不用登入，提供 REST API 與 MCP。託管服務，未標示授權。

可以做到：
- 讓 agent 透過 MCP 查某個倉庫或套件的完整資安狀況，或即時掃描索引沒有的倉庫。
- 一次檢查整份技術棧的套件版本是否受影響、哪個版本修好。
- 依「已知被利用」「新出現 exploit」等事件排修補優先，或用 RSS 訂閱。

## 威脅偵測 / 監控

### [Hugging Face Nightwatch](HF-Nightwatch.md)

Hugging Face 給 Enterprise 客戶的付費加購服務：資安 agent 即時掃描組織在 Hub 上的活動紀錄，搭配外部 OSINT 找出可疑行為（token 外洩後大量讀取私有倉庫、私有資料集被異常公開等），用 Slack 發告警，也可轉到組織的資安事件系統。託管服務，價格需洽業務。

可以做到：
- token 或帳號被盜、私有模型／資料集被大量讀取或 clone 時及早收到通知。
- 私有倉庫被意外或惡意公開時，馬上知道是誰、從哪裡、有沒有外部下載。
- 讓 agent 先讀完 Hub 活動紀錄，只把值得處理的事件推給資安團隊。

## AI agent 安全規格 / 治理

### [Foundry Security Spec](Foundry-Security-Spec.md)

Cisco 把內部安全評估系統的設計提煉成的開放規格：8 個核心 agent 角色、11 條憲章原則，把雜訊告警變成「有界、排序、可驗證的發現」。不含程式碼，搭配 spec-kit 產生實作。CC BY 4.0。

可以做到：
- 企業自建 AI 程式碼安全評估系統時，當架構藍圖。
- 設計 AI 漏洞研究工具時，參考角色分工、驗證與去重的做法。

## 怎麼挑

- **分析二進位程式**：Ghidra + GhidraMCP；要一個 MCP 涵蓋原生程式、Electron、APK、WASM 等多種目標：REA。
- **滲透測試**：先從 Pentest Copilot 或 Claude-Red 開始；專做 bug bounty 與外部紅隊、要整套流程到報告：Claude-BugHunter；要多 agent 自主化：Pentest Swarm AI；要有範圍管控與報告的紅隊演練平台：ARES；要有 Web 主控台、資產／漏洞管理的團隊平台：CyberStrikeAI；終端機裡打內網與 AD、要跨 session 記住進度：PentestCode；不分角色、靠共享黑板自主搜尋、可隨時插入人類提示：Cairn。
- **審查自己的程式碼**：直接在 coding agent 裡跑完整稽核用 Cloudflare Security Audit Skill，要自架平台做大規模 AI 審查用 open-kritt，已知漏洞掃描用 Nuclei，JS/TS 相依套件用 CVE Lite CLI；要讓 agent 查某個套件、倉庫或 CVE 的資安情資（是否被利用、誰受影響）用 SecurityContext。
- **監控組織在 Hugging Face Hub 上的異常活動**（Enterprise 方案）：Hugging Face Nightwatch。
- **測試自己的 LLM 應用（紅隊）**：[Promptfoo](../06-Agent-框架與編排/Promptfoo.md)，和偏品質評測的 [DeepEval](../06-Agent-框架與編排/DeepEval.md) 一起放在 Agent 框架類的「LLM 評測」。
- **想在本機用不上雲的資安專用模型**：[OrcaCyber Nano 1.0](../10-模型/OrcaCyber-Nano-1.0.md)（在模型類）。
- **設計 AI 資安系統**：Foundry Security Spec；skill 發布前的安全政策可參考 [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md)。
