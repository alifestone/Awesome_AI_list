# Promptfoo

- **分類**：資安 / LLM 測試 / 紅隊
- **連結**：https://github.com/promptfoo/promptfoo

## 原清單說明

LLM 應用的評測、回歸測試與紅隊工具。

> **查證結果**：與 README 一致。README 描述它是用來評測與紅隊測試 LLM 應用的 CLI 與函式庫（「Test your prompts, agents, and RAGs. Red teaming/pentesting/vulnerability scanning for AI」）。**補充**：README 表示 Promptfoo「已成為 OpenAI 的一部分」，仍維持開源與 MIT 授權。官方部落格公告日期為 2026-03-09。

## 概述

Promptfoo 是開發者導向的 LLM 測試工具。用宣告式設定檔（YAML）定義 prompt、模型與測試案例後，可以並排比較 GPT、Claude、Gemini、DeepSeek 等模型的輸出，並把評測放進 CI/CD 做回歸測試。它也提供紅隊功能，自動產生對抗性輸入來掃描 LLM 應用的安全弱點，並產出漏洞報告。

依 README，評測在本機執行，prompt 不會離開使用者的電腦；它可搭配任何 LLM API 或程式語言。README 稱已用於服務 1,000 萬以上使用者的正式應用。查閱時 GitHub 頁面顯示約 25.9k stars、2.5k forks、10,360 commits。

## 核心功能／特色

- **評測（Evals）**：自動測試 prompt 與模型，提供並排比較的檢視介面
- **紅隊測試**：針對 LLM 應用做安全測試
- **漏洞掃描**：產生安全漏洞報告
- **程式碼掃描**：審查 pull request 中與 LLM 相關的安全與合規問題
- **CI/CD 整合**：在 pipeline 中自動執行檢查
- **結果分享**：團隊共享評測結果
- **多 provider**：OpenAI、Anthropic、Azure、Bedrock、Ollama 等
- 即時重載（live reload）與快取

## 技術架構或運作原理

- **評測流程**：以宣告式設定檔描述要測的 prompt、模型（provider）與測試案例，`promptfoo eval` 執行評測，`promptfoo view` 開啟並排比較的結果檢視。斷言類型與評分機制的細節，本條目未逐一查證。
- **紅隊流程**（依紅隊 quickstart 文件）：
  - **Plugins**：對抗性輸入產生器，各自對應一類失效模式，例如有害內容、BOLA（物件層級授權失效）、BFLA（功能層級授權失效）、推薦競爭對手等。文件稱涵蓋 50 種以上漏洞類型，橫跨資安／隱私與合規／倫理，也可自訂政策。
  - **Strategies**：把產生的輸入包裝成特定攻擊模式（例如越獄、注入），測試防護是否足夠。
  - 產生的測試案例存成 `redteam.yaml`，對目標執行後產出報告。
  - 合規面提到 OWASP LLM Top 10、NIST AI RMF、EU AI Act 等標準。
- 文件說明掃描器在本機執行，因此能測到本機或內網可存取的端點；攻擊輸入的產生預設會用到 OpenAI（所以建議設定 `OPENAI_API_KEY`）。是否有其他遠端產生服務、細節為何，資料不足。

## 安裝與使用方式

```bash
# 安裝（擇一）
npm install -g promptfoo
brew install promptfoo
pip install promptfoo
npx promptfoo@latest <command>     # 免安裝直接執行

# 評測快速開始
promptfoo init --example getting-started
export OPENAI_API_KEY=sk-...
cd getting-started
promptfoo eval
promptfoo view

# 紅隊快速開始（對自己的應用）
npx promptfoo@latest redteam setup     # Web UI 設定精靈
promptfoo redteam init --no-gui        # 不開 UI 初始化
promptfoo redteam run                  # 產生並執行對抗測試
promptfoo redteam report               # 檢視報告
```

紅隊 quickstart 文件列出的前置需求：Node.js `>=22.22.0`，以及選用的 `OPENAI_API_KEY`。

## 適用情境

- 選擇模型或調整 prompt 時，做量化比較
- 把 LLM 應用的品質回歸測試放進 CI/CD
- 上線前對自家 chatbot、RAG、agent 做紅隊測試（prompt injection、資料外洩、越權存取、有害輸出）
- 為 OWASP LLM Top 10 或 NIST AI RMF 等合規需求準備測試證據
- 在 PR 階段掃描 LLM 相關程式碼的安全問題

## 授權與成本

- **授權**：MIT（README 明載，併入 OpenAI 後仍維持）。
- **成本**：開源版免費；呼叫被測模型與產生攻擊所用的 LLM API 需自付。紅隊文件提醒，自動化攻擊策略可能消耗大量 token，單次執行費用可從幾美分到數百美元。官網另有 Enterprise 方案，價格資料不足。

## 限制與注意事項

- **只測試自己擁有或已獲授權的系統**：紅隊功能會對目標送出大量對抗性與有害內容的 prompt。對第三方服務執行，可能違反其服務條款或法律。
- 對商用 LLM API 大量送出攻擊性 prompt，可能觸發供應商的濫用偵測，應事先確認供應商政策。
- token 費用可能偏高，建議先小規模試跑。
- 自動評分（例如以 LLM 當評審）可能有誤判，關鍵結果應人工複核。
- 併入 OpenAI 後的長期發展方向，以官方公告為準；公告表示會繼續支援多家 provider 與模型。

## 相關工具

- [Pentest Copilot](./Pentest-Copilot.md)、[ARTEX](./ARTEX.md)：用 AI 測試傳統系統（Promptfoo 則是測試 AI 系統本身）
- [DeepEval](../06-Agent-框架與編排/DeepEval.md)：Python／Pytest 風格的 LLM 評測框架，agent 與 RAG 指標較多
- 同類 LLM 紅隊工具：garak、PyRIT（僅供參考，本條目未查證其細節）

## 資料來源

- https://github.com/promptfoo/promptfoo
- https://github.com/promptfoo/promptfoo/blob/main/README.md
- https://www.promptfoo.dev/docs/red-team/
- https://www.promptfoo.dev/docs/red-team/quickstart/
- https://www.promptfoo.dev/blog/promptfoo-joining-openai/
- 收購相關報導（僅參考搜尋結果摘要，未讀內文）：https://securityboulevard.com/2026/03/openai-acquires-security-startup-promptfoo-to-fortify-ai-agents
