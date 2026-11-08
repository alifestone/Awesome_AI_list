# Cloudflare Security Audit Skill

- **分類**：資安 / 程式碼漏洞研究
- **連結**：https://github.com/cloudflare/security-audit-skill
- **相關文章**：[Build your own vulnerability harness](https://blog.cloudflare.com/build-your-own-vulnerability-harness)（Cloudflare 部落格）

## 概述

Cloudflare 官方釋出的 coding agent skill（`security-audit`），把 agent 變成程式碼資安稽核員：由一個主控 agent 協調多個彼此隔離的子 agent，依序做偵查、依覆蓋率分配的漏洞搜尋、候選漏洞驗證、結構化輸出、獨立複核與報告產出。定位是防禦性、以原始碼為主的稽核流程。

README 說明這個 skill 是 Cloudflare 內部漏洞挖掘 harness 的起點；之後 harness 長成多階段、全公司規模的系統，這個 repo 則是「單一 repo 版」的起始形態。

查閱時（2026-11-09）GitHub 顯示約 66.5k stars、4.3k forks；repo 建立於 2026-06，最近一次 commit 為 2026-09-14，沒有正式 release。

## 核心功能／特色

### 兩種模式

- **Guidance mode（預設）**：一般資安問題、聚焦審查、分流或調查特定發現時，只用到相關段落，不跑完整流程、不建立輸出目錄。
- **Full audit mode**：使用者明確要求稽核／滲透測試整個 codebase、要求完整審查或要報告檔時才啟用，跑完六個階段並寫出檔案。意圖不明時會先問一個問題。

### 六階段流程

1. **偵查**：整理架構、信任邊界、輸入面與既有證據，寫成 `architecture.md` 與 `coverage-ledger.json`（覆蓋率帳本）。
2. **依覆蓋率搜尋**：依帳本單位分派隔離的 hunter agent，並用 coverage critic 找漏掉的地方。
3. **候選驗證**：每個候選漏洞交給全新的 verifier，目標是「推翻它」。
4. **結構化輸出**：以 `confirmed`、`needs_validation`、`rejected` 三種判定寫入 `findings.json`，並用 `report-schema.json` 驗證。
5. **獨立複核**：再由全新 agent 核對最終的原始碼主張；有實質替換時再加一位獨立 verifier。
6. **報告**：從已驗證紀錄產出 `REPORT.md`、`FINDINGS-DETAIL.md`、`NEEDS-VALIDATION.md`。

### 攻擊類別附檔

依目標類型載入對應的 hunting 指引：記憶體安全與二進位、AI／LLM（prompt injection、agent 工具）、HTTP 協定與認證、前端／瀏覽器、供應鏈與發布、雲端與部署、RPC／訊息佇列、資源耗盡、資料隔離與生命週期、桌面／行動裝置與本機 IPC。

### 設計原則

- **只確認真的跨越邊界的問題**：每個候選必須講清楚低信任主體、輸入、應有的控制、被跨越的邊界、受影響對象與具體結果；缺最佳實務不算漏洞。
- **對抗式驗證**：檢查發現的 agent 永遠不是找到它的那個。
- **嚴重度看衝擊**：可能性 × 衝擊，而不是「偏離檢查清單」。
- **縱深防禦缺口不是漏洞**：A 層已擋住攻擊時，少了 B 層只算強化建議。
- **多跑幾次覆蓋更完整**：README 表示在他們的測試中，單次執行約只找到多次執行總數的一半；重複執行會讀取先前的帳本與發現，針對缺口補強。

### 執行分級與預算

Full audit 可選 `quick`、`standard`（預設）、`deep` 三種 profile，也可限定路徑、子系統或兩個 commit 之間的 diff。可設定「agent 呼叫次數上限」當預算，流程會先保留 critic 與驗證所需的額度，預算不夠時寧可標記未完成，也不會悄悄降低證據門檻。

## 技術架構或運作原理

整個 skill 是 `skills/security-audit/` 底下的一組 Markdown 指引（約 1,800 行）加上兩支零相依的 Node.js 驗證器：

- `SKILL.md`：設定、核心原則、平台用語、流程總覽與反模式
- `RECONNAISSANCE.md`、`HUNTING.md`、`VALIDATION-AND-REPORTING.md`：各階段的 prompt 與規則
- `ATTACK-CLASSES.md` 與十個領域附檔：各類攻擊的搜尋指引
- `report-schema.json`、`validate-findings.cjs`、`validate-coverage-ledger.cjs`（含測試）

Skill 寫成與 agent 無關的形式：用「parent」「Task tool」「research／general agent」等抽象角色，由各平台對應到自己的子 agent 機制。只有主控 agent 能寫共用檔案，每個子 agent 只能寫自己的 `agents/<id>/scratch/`。

驗證器只用 Node 內建的 `fs`、`path`、`util`，查閱時沒看到網路呼叫或遙測。

## 安裝與使用方式

用 [Skills CLI](https://skills.sh) 安裝：

```bash
npx skills add https://github.com/cloudflare/security-audit-skill \
  --skill security-audit

# 安裝到使用者層級
npx skills add https://github.com/cloudflare/security-audit-skill \
  --skill security-audit \
  --global
```

在要稽核的 repo 裡啟動 coding agent，直接說：

```
security audit this codebase
find security vulnerabilities in ./src
do a security review, output to ~/audits/my-project
```

Full audit 的輸出預設寫到 `~/security-audit-skill/<repo-name>/run-<N>`，不寫進目標 repo；只有使用者指定、而且已被版本控制忽略的目錄才會寫在 repo 內。

**需求**：支援工具呼叫與平行子 agent 的 coding agent、Node.js（跑驗證器），以及能隔離目標程式碼的 OS 層級沙箱（見下方注意事項）。

## 適用情境

- 對自家或取得授權的 codebase 做完整的 AI 資安稽核，產出可機器讀取的發現清單
- 日常開發中問資安問題、審查特定模組（guidance mode）
- 定期重跑，利用覆蓋率帳本逐步補齊盲點
- 參考 Cloudflare 如何設計「找漏洞 → 驗證 → 複核」的多 agent 流程，自建漏洞挖掘 harness

## 授權與成本

- **授權**：MIT（Copyright 2025-2026 Cloudflare, Inc.）。
- **成本**：skill 本身免費；full audit 會啟動大量子 agent（每個帳本單位約一次 hunter，每個候選再一到兩次 verifier），token 花費可觀，建議先用 `quick` 或設定預算。

## 限制與注意事項

- **需要沙箱才會執行目標程式碼**：要跑 build、測試、fuzzer 等，必須有 OS 層級沙箱（禁止對外網路、白名單環境變數、資源上限、只能寫 scratch 目錄）。做不到時 skill 不執行目標程式碼，相關線索只會標成 `needs_validation`。
- **不測線上系統**：明確禁止探測已部署的端點、外部服務、正式環境身分或他人資料；僅限原始碼與本機沙箱。
- **單次結果不等於完整**：官方自己說單次大約只找到一半；`quick` 或限定範圍的執行會在報告中標示為部分覆蓋。
- **仰賴平行子 agent**：沒有子 agent 機制的工具較難發揮完整流程。
- 沒有正式 release 或版本標記，建議鎖定 commit 安裝；安裝前仍應閱讀 skill 內容（可參考 [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md) 的 skill 信任政策）。
- 只用在自己擁有或取得授權的程式碼上。

## 相關工具

- [open-kritt](./open-kritt.md)：自架的 AI 漏洞研究平台，同樣拆小任務平行執行再驗證、去重
- [Foundry Security Spec](./Foundry-Security-Spec.md)：Cisco 的 agentic 安全評估系統規格，理念相近（角色分工、驗證、有界的發現）
- [Claude-Red](./Claude-Red.md)：偏攻擊面的資安 skill 集合
- [Superpowers](../06-Agent-框架與編排/Superpowers.md)、[ECC](../06-Agent-框架與編排/ECC.md)：一般開發流程的 coding agent skill 組

## 資料來源

- https://github.com/cloudflare/security-audit-skill
- https://blog.cloudflare.com/build-your-own-vulnerability-harness
