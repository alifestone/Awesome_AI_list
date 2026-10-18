# Foundry Security Spec

- **分類**：資安 / AI agent 安全規格 / 治理
- **連結**：https://github.com/CiscoDevNet/foundry-security-spec
- **公告**：https://blogs.cisco.com/ai/announcing-foundry-security-spec

## 原清單說明

原清單寫作「foundry」，附上 Cisco 部落格公告連結，沒有說明。

> **查證結果**：指的是 Cisco 於 2026-05-12 發布的 **Foundry Security Spec**，作者為 Cisco AI Security Engineering 的 Distinguished Engineer Omar Santos。它是一份「如何打造 agentic 安全評估系統」的開放規格，**不是可直接執行的掃描器**。公告中提到的 `CiscoDevNet/foundry` 會轉址到 `foundry-security-spec`，兩者是同一個 repo。

## 概述

Foundry 把 Cisco 內部安全評估系統的設計提煉成一份規格，目標是把「一堆雜訊告警」變成「有界、排序、可驗證的發現」。它是模型與技術堆疊皆中立的藍圖：用 orchestration、角色分工與 guardrail 包住前沿 LLM，由使用者依自己的環境實作。

Repo 刻意不含程式碼，規格本身就是交付物。查閱時 GitHub 顯示 225 stars、34 forks。

## 核心功能／特色

### 規格（`spec.md`）

- **8 個核心 agent 角色**：Orchestrator、Indexer、Cartographer、Detector、Triager、Validator、Coverage-Guide、Reporter
- **5 個擴充角色**（核心穩定後再做）：Deep-Tester、Variant-Hunter、Attack-Mapper、Remediator、Self-Improver
- **發現生命週期**：從偵測、分流、驗證到發布，保留可稽核的來源鏈
- **協調層（coordination substrate）** 與治理要求
- **約 130 條功能需求**，每條附理由；需依組織決定的部分標為 `[NEEDS CLARIFICATION]`
- **明確的「完成」訊號**：操作者設定的覆蓋率下限 + 經濟產出門檻

### 憲章（`constitution.md`）

11 條不可違反的原則，每條都對應 Cisco 自述在實際環境遇過並修正的失敗：

1. Evidence Over Assertion（證據優先於斷言）
2. Surface Only What Survives（只呈現通過驗證的發現）
3. Liveness By Heartbeat, Never By Clock（以心跳而非時間判斷存活）
4. Claims Are Atomic And Mortal（任務認領須原子化且會過期）
5. The Provider Is The Rate Arbiter（由模型供應端決定速率）
6. Coverage Before Yield（先求覆蓋再求產出）
7. Exploited Means Demonstrated（「可利用」必須實際展示）
8. Fingerprints Are Stable Under Edit（發現的指紋在程式碼修改後仍穩定）
9. Sandbox By Infrastructure, Not By Prompt（以基礎設施而非 prompt 做沙箱）
10. The Operator Outranks Every Agent（操作者權限高於任何 agent）
11. Persist Atomically（原子化持久儲存）

### 其他檔案

`GLOSSARY.md`（術語表）、`AGENTS.md`、`docs/`、`CHANGELOG.md`、`CONTRIBUTING.md`、`SECURITY.md` 等。

## 技術架構或運作原理

角色可以用子程序迴圈、圖狀 pipeline、serverless function 或自訂 harness 實作。設計重點是把安全 guardrail 放在基礎設施層，因為模型可能嘗試錯誤的動作，不能只靠 prompt 約束。

Detector 角色設計為使用 **Project CodeGuard** 規則（Cisco 開源、後捐給 CoSAI）。探索型 agent 找到的新問題可轉成新的 CodeGuard 規則，之後在掃描與開發者的 coding assistant 中重複使用。

規格**不包含**偵測規則、調查 prompt、嚴重度評分標準與報告模板，這些需自行撰寫。

## 安裝與使用方式

依 README，搭配 GitHub [spec-kit](https://github.com/github/spec-kit) 與 coding agent（如 Claude Code）使用：

1. 閱讀 `constitution.md`
2. 在專案中安裝 spec-kit
3. 把 `constitution.md` 複製到 `.specify/memory/`，執行 `/speckit.constitution`
4. 把 `spec.md` 複製到 `specs/001-foundry/`
5. 執行 `/speckit.clarify` 回答與自身基礎設施相關的問題，再執行 `/speckit.specify`
6. 重複 clarify 與 specify，直到沒有 `[NEEDS CLARIFICATION]` 標記
7. 執行 `/speckit.plan`、`/speckit.tasks`、`/speckit.implement` 產生實作

README 建議第一次建置時，5 個擴充角色全部選「不要」。

## 適用情境

- 企業資安團隊想自建 AI 程式碼安全評估系統，需要經過實戰檢驗的架構藍圖
- 評估或設計 AI 漏洞研究工具時，作為角色分工、驗證與去重的參考
- 學習 agentic 系統如何處理任務認領、存活偵測、速率限制等工程問題

## 授權與成本

- **授權**：CC BY 4.0（Copyright © 2026 Cisco Systems, Inc.）。
- **成本**：規格免費；實作與 LLM 費用自付。

## 限制與注意事項

- **不是現成工具**：需投入相當的工程量才能變成可用系統。
- 規則、prompt、評分標準都要自行準備。
- Cisco 明言實作、監督與最終決策的責任在使用者，最終安全判斷應保留人工把關。
- 只評估有權評估的軟體。

## 相關工具

- [open-kritt](./open-kritt.md)：已實作的開源 AI 漏洞研究平台，概念相近
- [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md)：skill 層級的安全與權限政策
- GitHub spec-kit、Project CodeGuard：本規格搭配使用的工具

## 資料來源

- https://blogs.cisco.com/ai/announcing-foundry-security-spec
- https://github.com/CiscoDevNet/foundry-security-spec
- https://raw.githubusercontent.com/CiscoDevNet/foundry-security-spec/main/constitution.md
- https://github.com/github/spec-kit
- https://project-codeguard.org/
