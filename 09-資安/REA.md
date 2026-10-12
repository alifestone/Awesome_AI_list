# REA

- **分類**：資安 / 逆向工程
- **連結**：https://github.com/morluto/rea

## 原清單說明

「Reverse Engineer Anything」：讓 agent 逆向分析 macOS 原生 app 並附證據，背後自動安裝與管理 Hopper。

> **查證結果（與原說明有出入）**：
> - 「Reverse Engineer Anything」「讓 agent 逆向分析並附證據」：正確。README 標語為「One MCP for reverse engineering across binaries, applications, and runtime behavior」，每個結論都會附上支持證據與限制說明。
> - 「macOS 原生 app」：**範圍過窄**。目前支援的目標包括各種原生二進位、Go、WASM、EVM bytecode、JavaScript/Electron、.NET、Android APK、網站與 HAR、韌體等，不限 macOS。
> - 「自動安裝與管理 Hopper」：**不精確**。原生分析可用既有的 Hopper、Ghidra 或 IDA。設定流程只會在**使用者核准後**才「選擇性」安裝 Hopper，需要時再自動啟動 Hopper。macOS 首次執行時，可能要手動選擇 demo 模式或啟用授權。README 沒有描述更完整的生命週期管理。

## 概述

REA 是開源專案，把逆向工程能力透過 Model Context Protocol（MCP）提供給 AI agent，同樣的流程也能以 CLI 指令執行。agent 透過 MCP 呼叫 REA 檢查本機目標、追蹤相關程式碼，REA 回傳附證據的發現，agent 再據此回答追問、解釋行為，或撰寫並測試重新實作。README 說明分析在本機執行。

README 已翻譯成約 18 種語言，並列出 DX-Ball、Notion、TH04 等案例研究。查閱時 GitHub 頁面顯示約 142.3k stars、32.7k forks（README 內另提及 11 萬 stars 的里程碑）。

## 核心功能／特色

- **單一 MCP 涵蓋多類目標**：
  - 原生二進位（透過 Hopper、Ghidra 或 IDA）
  - Go 二進位、WASM、EVM bytecode
  - JavaScript/Electron 應用、.NET 組件
  - 網站與儲存的 HAR 網路擷取
  - Android APK、透過 adb 連接的 Android 裝置、JEB 專案
  - Flutter 應用、韌體、套件
  - 行程行為（終端輸出與檔案系統觀察）
- **附證據的結論**：原生目標回傳虛擬碼、組合語言、字串、符號、呼叫與參照；Electron 回傳模組與 IPC 關係；EVM 回傳 dispatch selector 等
- **CLI 快照**：支援 snapshot 與匯入／匯出
- **多 agent 支援**：設定流程可自動設定 Claude Code、Codex、Cursor、Gemini CLI、Grok Build；其他支援本機 MCP 的 agent 可手動註冊，或使用 skills.sh 上的 skill

## 技術架構或運作原理

- 以 Node.js 套件 `rea-agents` 發佈（由 `package.json`、`tsconfig.json` 推測為 TypeScript/Node.js 專案，頁面未直接標示語言）。
- REA 是「協調層」：自己不實作完整反編譯器，而是呼叫既有的分析引擎與工具，包括 Hopper／Ghidra／IDA（原生）、JADX（需 JDK）、Apktool、adb、pwntools、WABT、binwalk／unblob、Chrome 系瀏覽器等，再把結果整理成附證據的結構化發現回傳給 agent。
- 靜態 JavaScript 與 .NET 檢查不需要原生引擎。
- 分為**靜態檢查**（只讀檔案、不執行）與**執行期擷取**（以使用者權限執行目標或與目標互動）兩種模式。

## 安裝與使用方式

需求：Node.js 22.x（22.19 以上）、24.x（24.11 以上）或 26 以上，以及 npm；原生分析需 Hopper、Ghidra 或 IDA 其中之一；其他目標視情況需要上述工具。

```bash
# 為 agent 設定 REA（選擇 agent → 檢視變更 → 核准 → 重啟 agent）
npx rea-agents setup

# 直接在終端分析自己有權分析的 JavaScript 應用
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json

# 全域安裝 CLI
npm install --global rea-agents
rea --help

# 更新
rea update                     # 全域安裝
npx rea-agents@latest setup    # 重新整理 agent 註冊
```

README 也提供 Bun 的對應指令。npm 套件頁的最新版本號與發佈日期資料不足（讀取時遭拒）。

## 適用情境

- 惡意程式分析、事件回應
- 漏洞研究與負責任揭露
- 軟體互通性研究、軟體保存（例如舊遊戲、停止維護的軟體）
- 稽核自己擁有或已獲授權檢查的應用（例如 Electron 應用的 IPC 設計、APK 行為）
- CTF 與逆向工程教學

## 授權與成本

- **授權**：REA 自行撰寫的程式碼採 MIT；第三方元件保留各自授權，見 `THIRD_PARTY_NOTICES.md`。
- **成本**：REA 本身免費。IDA Pro、Hopper、JEB 等商業工具須自行合法取得，REA 不提供任何授權或啟用金鑰。agent 所用的 LLM 費用另計。

## 限制與注意事項

- **合法使用（README 與 DISCLAIMER.md）**：
  - 僅用於合法研究、教育、互通性、軟體保存，以及分析自己擁有或已獲授權檢查的軟體。
  - 專案明言不協助 DRM／授權破解、遊戲外掛、未經授權繞過認證或存取控制、複製專有程式碼、規避 AI 供應商政策等，相關請求可能被關閉，提出者可能被移出社群。
  - 軟體公開可得或端點可以存取，**不代表**已取得分析許可，須自行取得授權並遵守法律、授權條款與服務條款。
  - 盜版工具、竊取的金鑰或繞過授權都不在允許範圍內。
- **執行期風險**：執行、觀察、攔截目標可能影響檔案、帳號、裝置與服務。應審查 agent 產生的計畫與腳本，在合適的隔離環境中處理不受信任的目標，並保護憑證、個資與擷取到的資料。
- **輸出準確性**：反編譯與 AI 輔助的結果可能不完整或錯誤，重要結論須自行驗證；輸出不代表取得原軟體的任何權利。
- **平台限制**：部分功能只限特定主機，例如某些當機與 EVM 功能限 Linux x64、PTY 行程擷取限 Linux 或 macOS、Binwalk/unblob 韌體擷取限 Linux；Windows 上的 Ghidra 支援標為實驗性。
- 大型二進位可能需要用環境變數調長啟動逾時；npm 最新版可能尚未包含 GitHub 上新加的功能。
- 使用的 LLM 供應商有各自的資料政策，分析內容會送到模型端。
- 文件中對 NSA 與商業廠商的致謝不代表背書或合作關係。

## 相關工具

- [Ghidra](./Ghidra.md)：REA 可用的原生分析引擎之一
- [GhidraMCP](./GhidraMCP.md)：專注於 Ghidra 的 MCP server
- Hopper、IDA Pro、JEB（商業軟體）；JADX、Apktool、binwalk、unblob、WABT、pwntools（REA 會呼叫的工具）

## 資料來源

- https://github.com/morluto/rea
- https://github.com/morluto/rea/blob/main/DISCLAIMER.md
- https://www.npmjs.com/package/rea-agents（讀取時回傳 403，未取得內容）
