# Hugging Face Nightwatch

- **分類**：資安 / 威脅偵測 / 監控（Hugging Face Hub 企業方案的 AI 安全監控服務）
- **連結**：https://huggingface.co/docs/hub/en/enterprise-nightwatch
- **洽詢**：https://huggingface.co/contact/sales?from=enterprise

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：Hugging Face 官方文件介紹的付費加購服務，只提供給 Enterprise 客戶，需洽業務開通。它是 HF 代為執行的**託管監控服務**，不是可下載或自架的工具；文件沒有公開價格、API 或設定方式。

## 概述

Nightwatch 是 Hugging Face 稱為「Proactive Agent Security」的服務。HF 表示越來越多攻擊利用 AI agent 鎖定推論基礎設施與模型、資料集提供者，並把公開的 Hub 倉庫和其他協作平台當作跳板或攻擊途徑；Nightwatch 是根據 2026 年 7 月 OpenAI／HF 事件的經驗打造的。

它由一個資安 agent 即時掃描你組織在 Hub 上的活動紀錄，發現可疑行為時透過 Slack 通知你的團隊。

## 核心功能／特色

- **即時掃描 Hub 活動**：資料來源包含 Hub 存取紀錄、各項指標，以及外部 OSINT 情資，交給 Nightwatch agent 判斷並標出異常活動供人審查
- **找出可疑模式**：文件示意圖的例子是同一個帳號在同一秒內讀取三個倉庫
- **Slack 告警**：由 Slack agent 用自然語言說明發生了什麼、影響範圍與建議處置，也可以把告警轉送到組織自己的資安事件處理系統
- **主動處置**：文件範例中，HF 偵測到外洩的 access token 後已直接撤銷，並提供受影響倉庫清單與時間軸

### 文件中的告警範例

- **access token 異常使用**：某成員具寫入權限的 token 從兩個可疑 IP 發出請求，讀取了組織 60 個私有倉庫、其中 22 個被 clone；token 已撤銷，可提供完整清單與時間軸
- **私有資料集被公開**：管理員帳號從新加坡的 IP 把私有資料集改為公開，八分鐘前同帳號還在平常的巴黎網路活動；四分鐘後出現第一次組織外的下載，告警會詢問這是否為預定發布，並建議改回私有、檢查該帳號近期活動

## 技術架構或運作原理

- 監控對象是 Hub 上的組織活動紀錄（存取紀錄、指標），再對照外部 OSINT
- 判斷由 LLM agent 進行；HF 說價格反映了持續掃描所用的大量 token，開放與封閉模型都有用到
- 通知管道為 Slack，或接到組織的資安事件 ingestion 系統

## 安裝與使用方式

沒有可安裝的東西。需要：

1. 組織是 Hugging Face Enterprise 方案
2. 透過 [Enterprise 業務聯絡頁](https://huggingface.co/contact/sales?from=enterprise) 申請加購 Nightwatch
3. 設定接收告警的 Slack 或資安事件系統（文件未公開設定細節）

## 適用情境

- 組織在 Hub 上放了私有模型、資料集，擔心 token 外洩或帳號被盜後被大量讀取、clone
- 想及早發現私有倉庫被意外或惡意公開
- 資安團隊人力有限，希望由 agent 先讀完活動紀錄、只把值得看的事件推到 Slack

## 授權與成本

- **授權**：專有的託管服務。
- **成本**：Enterprise 客戶的付費加購，價格未公開，需洽業務。

## 限制與注意事項

- 只監控 Hugging Face Hub 上的活動，不涵蓋你自己的推論伺服器、雲端環境或其他協作平台
- 只有 Enterprise 客戶能用，個人與一般團隊方案無法使用
- 文件只有概念說明與告警範例，沒有公開偵測規則、誤報率、回應時間或 API
- 處置（例如撤銷 token）由 HF 執行，導入前可先確認哪些動作會自動進行、哪些需要你同意

## 相關工具

- [SecurityContext](./SecurityContext.md)：查開源套件、倉庫與 CVE 的資安情資；Nightwatch 則是監控你自己組織帳號的異常活動
- [Foundry Security Spec](./Foundry-Security-Spec.md)：自建 agentic 資安評估系統的開放規格

## 資料來源

- https://huggingface.co/docs/hub/en/enterprise-nightwatch
