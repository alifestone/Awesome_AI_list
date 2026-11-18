# Claude-BugHunter

- **分類**：資安
- **連結**：https://github.com/elementalsouls/Claude-BugHunter

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：給 Claude Code 用的 bug bounty 與外部紅隊 skill 組，作者 Sachin Sharma（ElementalSoul）。README 寫 83 個 skill（repo 描述寫 82）、15 個 slash command，hunt 類 skill 整理自 681 份已公開的 HackerOne 報告（其中 433 份逐條附出處）。範圍只限**外部攻擊面**，內網 AD、C2、後滲透、規避防毒都刻意不收。⚠️ 高度雙重用途，僅限自有或取得書面授權的目標。

## 概述

裝好後，Claude Code 會依你描述的測試內容自動載入對應 skill，不必點名。內容分四層：

- **Think**：`bb-methodology`、`redteam-mindset`，非線性的 5 階段流程與紅隊操作紀律。
- **Hunt webapps**：58 個 `hunt-*` skill，依漏洞類別整理偵測模式、payload、繞過表與串連範本。
- **Hit the perimeter**：M365／Entra ID、Okta、vCenter、SSL VPN 設備、SharePoint、雲端 IAM 等企業平台的 2024–2026 CVE 串連與取得憑證後的提權。
- **Ship it**：`triage-validation`（送出前的 7 問關卡，含是否在範圍內）、依 VRT 定嚴重度、證據去敏（`evidence-hygiene`）與報告撰寫。

repo 於 2026-05-05 建立，最新 release v2.1（2026-06-05），之後仍每天更新；查詢當下（2026-11-18）約 10.8k 顆星、1.5k forks。

## 核心功能／特色

- **83 個 skill**：web 漏洞類別 58、企業平台攻擊 10、報告與驗證 6、偵察與 OSINT 5、方法論 4；可搜尋目錄見 `docs/skills.md`。
- **15 個 slash command**：`/hunt`、`/recon`、`/report` 等；`/hunt` 開場會先聲明授權與範圍。
- **流程**：recon → map & rank → hunt → validate → report，範圍檢查寫在程式裡。
- **`hunt` 案件資料夾產生器**與 **`cbh` CLI**：整理 findings、證據與送件 ID，串起偵察、分類、分流與報告。
- **Engagement engine**（`engine/`）：確定性地盤點目標攻擊面，把每個發現交給對應 skill。
- **整合**：Burp Suite MCP；HackerOne MCP（`mcp/hackerone/`，查重複報告、計畫範圍與統計）；ProjectDiscovery 工具（subfinder、httpx、katana、nuclei）。
- **報告格式**：HackerOne、Bugcrowd（VRT）、Intigriti、Immunefi，以及給企業客戶的紅隊報告範本。
- **多 harness**：skill 是標準 `SKILL.md`，可裝到 Claude Code、OpenCode、Codex CLI、Hermes Agent、Google AntiGravity；slash command 與 `/hunt` engine 只在 Claude Code 上能用。
- 姊妹專案 [Claude-OSINT](https://github.com/elementalsouls/Claude-OSINT)（偵察階段），兩者可同時安裝。

## 安裝與使用方式

```text
# 方式 A：Claude Code 外掛（建議）
/plugin marketplace add elementalsouls/Claude-BugHunter
/plugin install claude-bughunter@elementalsouls
```

```bash
# 方式 B：複製安裝（含 hunt 產生器與 cbh CLI）
git clone https://github.com/elementalsouls/Claude-BugHunter.git
cd Claude-BugHunter
bash scripts/install.sh                     # Windows：pwsh ./scripts/install.ps1
bash scripts/install.sh --all --burp-mcp    # 裝到所有偵測到的 harness 並接 Burp MCP

# 外掛使用者另裝 cbh CLI
pipx install git+https://github.com/elementalsouls/Claude-BugHunter
```

裝好後直接用一般英文描述，例如「Testing acme.com — an in-scope HackerOne target. Run recon and rank the surface.」

## 適用情境

- 有授權的 bug bounty：偵察、排序攻擊面、依漏洞類別找洞、驗證後依平台規則寫報告。
- 外部紅隊／網站滲透測試：企業對外平台（M365、Okta、VPN、vCenter）的初始存取評估與交付報告。
- CTF 與 DVWA、OWASP Juice Shop、Hacker101 等練習平台。

## 授權與成本

- 雙授權：程式碼（`.py`、`.sh`）**MIT**；skill 方法論、字典、文件 **CC BY 4.0**（商用可，需標註作者並連回 repo）。
- 部分 skill 與 15 個 slash command 來自 [shuvonsec/claude-bug-bounty](https://github.com/shuvonsec/claude-bug-bounty)，保留原授權。
- 軟體免費；成本為 Claude Code（或其他 agent）用量，Burp Suite 等工具另計。

## 限制與注意事項

- **只能用在自有或取得書面授權的資產**（bug bounty 範圍內、滲透測試合約、CTF）；作者明確排除對未授權目標武器化 0-day、後滲透工具、惡意程式與大規模掃描。
- 不涵蓋內網 AD（Kerberoasting、DCSync 等）、C2、後滲透／持久化、AV／EDR 規避、iOS、硬體、二進位漏洞利用。
- Anthropic 模型的即時資安防護預設會擋「漏洞利用或攻擊性工具開發」，即使是授權工作也可能被拒；README 建議正當用途申請 Anthropic 的 Cyber Verification Program，**不要**把攻擊性工作改寫成防禦用語繞過分類器。
- README 指出 Opus 5 遇到 exploit 生成、滲透測試等高風險請求時會自動改由 Opus 4.8 回答（有標示），長時間 agent 執行中容易沒注意到。
- README 的示範對話是示意，不是實際錄製。
- README 含贊助商（ApiSmart、ThreatWatch360）推廣內容。

## 相關工具

- [Claude-Red](Claude-Red.md)：另一個攻擊性資安的 Claude Skills 集合，範圍較廣、不限外部攻擊面。
- [Pentest Copilot](Pentest-Copilot.md)、[Pentest Swarm AI](Pentest-Swarm-AI.md)：AI 滲透測試助手與多 agent 自主滲透。
- [Nuclei](Nuclei.md)：本工具的偵察流程會用到的弱點掃描器。

## 資料來源

- https://github.com/elementalsouls/Claude-BugHunter
- https://elementalsouls.github.io/Claude-BugHunter
