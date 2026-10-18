# PaperRead

- **分類**：學習資源 / 學習工具
- **連結**：https://github.com/YuriyLin/PaperRead

## 原清單說明

以繁體中文閱讀學術論文的個人研究工作區：從找論文、管理待讀清單到 PDF 精讀，都在同一個地方完成。

## 概述

PaperRead 是 EasyRead 專案的 fork，把「論文探索」、「閱讀清單管理」與原有的 PDF 閱讀工具整合在一起。介面與文件以繁體中文（zh-TW）為主。README 特別強調：候選清單、整理摘要、閱讀看板、閱讀路徑等狀態彼此分開，不會因為產生摘要就自動標記為已讀，也不會覆蓋既有筆記。

## 核心功能／特色

- **研究探索**：依主題或一個以上的會議／期刊搜尋；結果顯示中繼資料、資料來源、DOI、引用資訊與 PDF 可否取得，並區分預印本與正式發表。
- **候選清單**：先存起來稍後閱讀；摘要在背景排隊產生，大量加入時不會一次塞爆請求。
- **閱讀看板**：可拖放的看板，預設欄位為待讀、閱讀中、待整理、完成；欄位由使用者手動設定。可依分類、PDF 可否取得、收藏、優先度篩選。
- **整理摘要**：以 Markdown 另存，與候選清單分開，論文移出候選後仍會保留；可檢視、重新產生、匯出或移到垃圾桶。
- **閱讀路徑**：針對某主題或起始論文產生有順序的閱讀清單，每一步附閱讀角色與理由；AI 只會重新排列「實際搜尋到」的論文。
- **心智圖**：以 Mermaid 產生繁體中文心智圖，涵蓋研究問題、方法、發現、貢獻與限制。
- **PDF 閱讀**：原文與譯文並排，支援公式、標註、筆記與提問，並連回原文區塊與頁面位置；圖表保留在原位。
- **智慧標註**：AI 可依全文、章節或研究目標建議標註，每項建議逐一審核，不會覆蓋手動標註；顏色有固定意義（例如黃色為核心主張、紅色為限制）。
- **模型選擇**：雲端 API（OpenAI、Anthropic、Gemini、DeepSeek、OpenRouter 等）、本地模型（Ollama、LM Studio），或自訂 OpenAI 相容端點。

## 技術架構／運作原理

- 探索功能查詢公開書目資料來源，主要是 OpenAlex，會議／期刊查詢則輔以 DBLP 與 Crossref；遇到速率限制或服務中斷時會保留前次結果並提供重試，而非顯示空白。
- 後端為 Python（`easyread` 套件與 CLI），前端為原生 HTML／CSS／JavaScript（無建置步驟），桌面版以 Electron 包裝，後端用 PyInstaller 打包；數學式以 KaTeX 顯示。
- 為了相容，內部模組、CLI 與連結協定名稱仍沿用 `easyread`；舊版 EasyRead 資料會在首次啟動時遷移。

## 安裝與使用方式

- **Windows**：到 Releases 下載 `PaperRead-Setup-x.x.x.exe`，已內含 Electron 與後端，不需另裝 Python 或 Node.js。
- **Linux**：下載 `PaperRead-x.x.x.AppImage`，設為可執行後執行（僅 x64）。
- **Docker（瀏覽器）**：

  ```bash
  git clone https://github.com/YuriyLin/PaperRead
  cd PaperRead
  docker compose up -d   # 然後開啟 http://localhost:8765
  ```

  也有發佈到 GitHub Container Registry 的預建映像；資料存在 Docker volume（容器內 `/data/PaperRead`）。
- **從原始碼**：需要 Python 3.10+、Node.js 22+ 與 PyInstaller；`python -m easyread serve` 啟動本地服務，`npm run dev` 啟動桌面版，`npm run dist` 建置安裝檔。
- **資料位置**：Windows 為 `C:\Users\<使用者>\PaperRead`。

## 適用情境

- 需要大量閱讀英文論文、希望以繁體中文輔助理解的學生與研究者。
- 想在同一個工具內完成文獻探索、待讀管理、摘要與精讀的人。
- 想用本地模型（Ollama、LM Studio）處理論文、不想把內容送到雲端的人。

## 授權與成本

- **MIT** 授權（KaTeX 同為 MIT），軟體免費。
- 使用雲端模型時，API 費用由各家服務商決定；使用本地模型則無此費用。

## 限制與注意事項

- Windows 安裝檔未經程式碼簽章，可能出現「未驗證的發行者」警告。
- 只提供 Windows 安裝檔與 Linux x64 AppImage；macOS 沒有桌面版，需改用 Docker。
- AI 功能只能重新整理「已搜尋到」的論文，無法憑空新增，資料不足時結果有限。
- 探索功能依賴外部服務，可能被限速或中斷。
- Docker 版不應直接暴露在公網，需另外加防火牆與認證。
- UI 與文件以繁體中文為主。
- 最後更新日期頁面未顯示（資料不足）；README 範例引用的最新版本為 v1.4.6。

## 相關工具

- [Learn Harness Engineering](Learn-Harness-Engineering.md)：同屬學習資源類。
- EasyRead：PaperRead 的上游專案。
- [Ollama](https://ollama.com/)、LM Studio：可作為本地模型後端。

## 資料來源

- https://github.com/YuriyLin/PaperRead
