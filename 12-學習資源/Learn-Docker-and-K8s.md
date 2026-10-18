# Learn Docker and K8s

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/ericboy0224/learn-docker-and-k8s

## 原清單說明

Docker 與 Kubernetes 學習教材。

> 查證補充：它的形式比較特別，是一個「在 AI 編輯器裡玩的互動式學習遊戲」，不是網頁課程或影片教材——由 AI 編輯器扮演導師帶你解決情境題。

## 概述

開源、互動式的 Docker、Linux、網路與 Kubernetes 學習遊戲。README 的定位是「No web app. No video courses.」：你在 Claude Code、Cursor 等 AI 編輯器中開啟專案，AI 會扮演導師 Sarah，帶你在虛構咖啡新創公司 NoCappuccino 的 DevOps 情境中解決真實問題。教材語言為英文（歡迎翻譯，但技術名詞要求保留英文）。

## 核心功能／特色

- **AI 導師互動**：AI 以漸進式提示引導，不直接給答案；可用自然語言如「I'm stuck」求助。
- **情境式章節**：每章都是一個故障或需求情境（例如 API 在 staging 崩潰、映像檔太大、重啟後資料消失）。
- **實機操作**：在你電腦上真實的 Docker 與 Kubernetes 環境中執行。
- **自動驗證**：每章有 `verify.sh` 驗證腳本，以及可用來跳關的 `quiz.md`。
- **無需伺服器**：prompt 檔案本身就是「遊戲引擎」。
- **安全清理**：所有遊戲資源都加 `learn-` 前綴，`cleanup.sh` 可一次清除。
- **多編輯器支援**：為多種 AI 編輯器提供入口檔。

## 課程／教材結構

共 7 章、每章 3 課：

| 章 | 標題 | 情境 | 主題 |
|---|---|---|---|
| 1 | It Works on My Machine | API 在 staging 崩潰 | 容器、映像檔、port mapping |
| 2 | The 2GB Espresso | 映像檔太大 | multi-stage build、layer cache、.dockerignore |
| 3 | The Vanishing Beans | 重啟後資料遺失 | volume、bind mount、持久化 |
| 4 | The Silent Grinder | 服務之間無法溝通 | DNS、bridge network、隔離 |
| 5 | The Symphony of Steam | 開發環境建置太慢 | Docker Compose、health check、secrets |
| 6 | The Giant Roaster | 流量暴增壓垮伺服器 | Pod、Deployment、Service、自我修復 |
| 7 | The Great Latte Leak | 停機期間多重故障 | rolling update、Secret、HPA、事故分流 |

過程中也會帶到 Linux 基礎（namespaces、cgroups、mounts）與網路概念（DNS、NAT、子網路、iptables）。

## 安裝與使用方式

前置需求：

- 必要：Docker、Docker Compose v2、一個 AI 編輯器（Claude Code、Cursor、Windsurf、Copilot、Cline、Codex CLI、Gemini CLI 等）。
- 選用（第 6～7 章）：kubectl 與 kind。

開始：

```bash
git clone https://github.com/ericboy0224/learn-docker-and-k8s.git
cd learn-docker-and-k8s
# 用 AI 編輯器開啟資料夾後輸入：let's play
```

遊戲內指令：`/play`、`/env-check`、`/progress`、`/hint`、`/verify`、`/next`、`/skip-to 4`、`/cleanup`。

## 適用情境

- 剛開始學 DevOps、偏好動手解題而非看影片的人。
- 已在使用 AI coding 工具，想順便練習容器化與 K8s 基礎的開發者。
- 想用情境故障排除方式複習 Docker 網路、儲存、Compose 與 K8s 部署概念。

## 授權與成本

- **MIT** 授權。
- 教材本身免費；但需要可用的 AI 編輯器／AI 服務（其費用依你選用的工具而定，非本專案收費）。

## 限制與注意事項

- 教材為英文，無官方中文版（README 歡迎社群翻譯）。
- 學習品質高度依賴所用 AI 模型的表現與是否遵循 prompt 規則。
- 規模尚小：查閱時約 10 個 commit、493 stars；7 章內容屬入門到初階範圍，K8s 部分只涵蓋 Pod/Deployment/Service/HPA 等基礎。
- 會在本機實際建立容器與叢集資源，結束後建議執行 `/cleanup` 或 `cleanup.sh`。

## 相關工具

- [kind](https://kind.sigs.k8s.io/)：第 6～7 章使用的本地 Kubernetes 叢集工具。
- [Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)：本清單另一個學習資源，主題是替 AI coding agent 打造工作環境，與本專案「用 AI 編輯器當導師」的做法可互相參照。

## 資料來源

- https://github.com/ericboy0224/learn-docker-and-k8s
