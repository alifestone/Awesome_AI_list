# AI Agents for Beginners

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/microsoft/ai-agents-for-beginners
- **網站**：https://aka.ms/ai-agents-beginners
- **繁中版**：https://github.com/microsoft/ai-agents-for-beginners/blob/main/translations/zh-TW/README.md

## 原清單說明

（使用者新增，無原清單說明。使用者另附 AI郵報的中文介紹文章：https://www.aiposthub.com/microsoft-ai-agents-for-beginners-18-lessons-guide/ ）

> **查證結果**：Microsoft 官方 repo，標語為 *18 Lessons to Get Started Building AI Agents*，MIT 授權。查詢當下（2026-11-20）約 8.05 萬顆星、2.6 萬個 fork，repo 建立於 2024-11-28，最後一次 push 為 2026-11-17，仍在持續更新。AI郵報文章（2026-11-18）是第三方整理，內容與 repo README 一致，文章自述影片部分「非本站實測」。

## 概述

Microsoft「for Beginners」系列中的 AI agent 入門課：18 堂課，每堂一個主題，可以從任何一堂開始讀。每堂課包含：

- README 形式的課文（多數附一支短影片）
- 用 Microsoft Agent Framework（MAF）＋ Microsoft Foundry Agent Service V2 寫的 Python notebook（`code_samples/`，檔名 `*-python-agent-framework.ipynb`）
- 延伸閱讀連結

透過 Co-op Translator 自動翻譯成 50 多種語言，**含繁體中文（台灣）**，課文與程式碼註解都有翻譯。

## 課程內容

| # | 主題 |
|---|---|
| 1 | AI agent 入門與使用情境 |
| 2 | Agent 框架介紹 |
| 3 | Agent 設計模式 |
| 4 | Tool Use 設計模式 |
| 5 | Agentic RAG |
| 6 | 打造可信賴的 agent |
| 7 | Planning 設計模式 |
| 8 | Multi-Agent 設計模式 |
| 9 | Metacognition（後設認知）設計模式 |
| 10 | Agent 上線（production） |
| 11 | Agent 協定：MCP、A2A、NLWeb |
| 12 | Agent 的 Context Engineering |
| 13 | Agent 記憶管理 |
| 14 | Microsoft Agent Framework |
| 15 | 電腦操作 agent（CUA，Browser Use／Playwright） |
| 16 | 可擴展的 agent 部署 |
| 17 | 本機 AI agent（Foundry Local） |
| 18 | Agent 安全 |

第 1–13 堂有影片；第 14–18 堂目前只有課文與程式碼。

## 安裝與使用方式

只想讀課文：直接在 GitHub 或網站上讀，不必安裝。

要跑程式碼（依 `00-course-setup`）：

```bash
# 略過 50+ 語言翻譯，下載量小很多
git clone --filter=blob:none --sparse https://github.com/microsoft/ai-agents-for-beginners.git
cd ai-agents-for-beginners
git sparse-checkout set --no-cone '/*' '!translations' '!translated_images'

python3.12 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
az login                 # notebook 用 Azure CLI 登入取得憑證，不放 API key
cp .env.example .env     # 填 AZURE_AI_PROJECT_ENDPOINT 與 AZURE_AI_MODEL_DEPLOYMENT_NAME
```

需求：Python 3.12+、Azure CLI、Azure 訂閱（在 ai.azure.com 建 Foundry 專案並部署模型，預設範例是 `gpt-5-mini`）。

- 第 5、16 堂預設用記憶體內知識庫，不需要 Azure AI Search；要接真的索引才另外設定。
- 第 6、8 堂部分 notebook 直接呼叫 Azure OpenAI（Responses API），要多設 `AZURE_OPENAI_ENDPOINT` 等變數（原本用的 GitHub Models 已停用）。
- 用 `OpenAIChatClient` 的課可改接 OpenAI 相容服務（官方文件舉 MiniMax 為例）；第 17 堂用 Foundry Local 在本機跑模型。

## 適用情境

- 會基本 Python，想有系統地入門 agent 概念：工具呼叫、RAG、規劃、多 agent、記憶、MCP。
- 想看一套中文翻譯完整、免費的官方教材。
- 已經有 LLM API 經驗的人，AI郵報建議可以直接從第 11、12 堂（協定、context engineering）讀起。
- 想用 Microsoft Agent Framework／Azure Foundry 做 agent。

## 授權與成本

- **授權**：MIT。
- **成本**：課文、影片、程式碼免費。跑雲端範例會用到 Azure 資源（模型呼叫、AI Search 等）的費用；用替代服務或本機模型可避開。

## 限制與注意事項

- **範例綁 Microsoft 生態**：程式碼以 MAF＋Azure Foundry 為主，大多數 notebook 需要 Azure 帳號。設計模式與協定概念可以套用到 LangGraph 等其他框架，但程式碼不能直接搬。
- **入門深度**：偏概念與基礎示範，不涵蓋特定框架的進階調校。
- **repo 很大**：完整 clone 會連 50 多種翻譯一起下載，建議用上面的 sparse checkout。
- **機器翻譯**：繁中版由 Co-op Translator 自動產生，用詞偶有不自然，有疑問時對照英文原文。
- 接真實資料庫或瀏覽器之前，先讀第 6、18 堂的安全內容（提示詞注入、權限控管）。

## 相關工具

- [AI Engineering from Scratch](./AI-Engineering-From-Scratch.md)：範圍更大，從數學一路到 agent 上線，不綁特定雲端。
- [EECS 498 AASE](./EECS-498-AASE.md)：大學課程，偏 coding agent 與自己寫 agent 迴圈。
- [Learn Harness Engineering](./Learn-Harness-Engineering.md)：已經在用 coding agent，想讓它更可靠。

## 資料來源

- https://github.com/microsoft/ai-agents-for-beginners
- https://github.com/microsoft/ai-agents-for-beginners/blob/main/00-course-setup/README.md
- https://www.aiposthub.com/microsoft-ai-agents-for-beginners-18-lessons-guide/
