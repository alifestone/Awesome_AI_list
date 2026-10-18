# Strata Easy TW

- **分類**：推論與訓練引擎
- **連結**：https://github.com/encoreh78951-hub/StrataEasyTW
- **收錄版本**：https://github.com/encoreh78951-hub/StrataEasyTW/releases/tag/v1.3.0-rc1

## 原清單說明

（使用者提供的 release 連結，無附帶說明。）

> **查證結果**：依 repo 文件，這是 [Strata](Strata.md) 的**非官方**繁體中文 Windows 安裝導覽器，不是推論引擎本身。它保留 Strata 官方的 `START-HERE.bat` 互動流程，只在旁邊加上中文說明。v1.3.0-rc1 在 GitHub 標為 pre-release。

## 概述

Strata Easy TW 是用 Python／Tk 寫的 Windows 圖形介面，幫不熟命令列的使用者安裝 Strata。介面分兩欄：左邊是真正跑官方 BAT 的 ConPTY 終端機，右邊依官方英文輸出判斷目前階段，用繁體中文解釋該怎麼選。它不會替使用者自動回答問題。介面裡有一隻叫「小雪」的雪納瑞吉祥物，會隨安裝階段換姿勢。

repo 於 2026-10-18 建立，查詢當下（2026-10-18）3 顆星。v1.3.0-rc1 同日發布，附 `Setup.exe`、免安裝版 ZIP、原始碼 ZIP 與 `SHA256SUMS.txt`。作者為 GitHub 使用者 encoreh78951-hub。

## 核心功能／特色

- **兩種安裝方式**：從官方 GitHub 下載 Strata 原始碼（建立 `Strata-Official`，已存在時不覆蓋），或指定既有的 Strata 資料夾。
- **兩種模型來源**：
  - **官方標準模型（預設）**：完全沿用 Strata 的模型選擇與問答。
  - **SC117 第三方低拒答模型（實驗性）**：從 Hugging Face 下載 [SC117 的 abliterated GGUF](https://huggingface.co/SC117/Qwen3.8-Flash-Next-GSQ-RCO-abliterated-GGUF)（Q2_0／IQ2_XS／IQ3_XXS／IQ3_S），驗證 SHA-256 後交給官方腳本重建 Pack，放在獨立資料夾，不和標準模型共用。中斷可續傳。
- **離線展示**：首次安裝、既有安裝、失敗排除三種情境，不執行 Strata、不下載模型，可先熟悉介面。
- **安全措施**：記錄官方來源 commit、安全解壓（擋路徑穿越等）、8080 埠已被占用時不啟動第二份、停止只結束本次啟動的程序樹、日誌手動匯出且不自動上傳。
- **啟動後檢查**：先打本機 `/health`，再開 `http://127.0.0.1:8080` 的聊天頁。

## 技術架構或運作原理

- `app.py`：介面；`session.py`：管理工作流程；`terminal_backend.py`：Windows ConPTY（pywinpty）；`terminal_screen.py`：VT 解析（pyte）。
- `source_manager.py`：下載與解壓官方原始碼；`guide_rules.py`、`beginner_help.py`：依官方輸出辨識 23 個導覽階段並給中文說明；`mascot.py`：小雪圖集。
- 以 PyInstaller 打包、Inno Setup 產生繁中安裝器，GitHub Actions 在 Windows 2022 上跑測試與建置。

## 安裝與使用方式

- **系統**：Windows 10 1809 以上或 Windows 11（x64）。Linux／macOS 只能跑離線展示與測試。
- **最簡單**：從 release 下載 `StrataEasyTW-1.3.0-rc1-Setup.exe`（每位使用者安裝，不需管理員權限），或解壓免安裝版 ZIP（須保留整個資料夾）。
- **從原始碼**：需 64 位元 CPython 3.10–3.13。

```bat
REM 先看離線展示（第一次會連網安裝相依套件到 .guide-venv）
RUN_DEMO_WINDOWS.bat

REM 真正安裝
RUN_WINDOWS.bat

REM 雙擊 BAT 後視窗立刻消失時
RUN_DIAGNOSTIC.bat
```

模型、GPU、RAM 與磁碟需求以 Strata 官方為準（見 [Strata](Strata.md)），大型模型需數十 GB 以上空間。

## 適用情境

- 想在 Windows 遊戲 PC 上跑 Strata，但看不懂英文安裝問答或不熟命令列。
- 想試 Strata 搭配 SC117 的低拒答版 Qwen3.8-Flash-Next 模型。

## 授權與成本

- **授權**：導覽器原創程式碼為 MIT（GitHub 顯示為 Other，因 LICENSE 末尾加註：不改變 Strata、Qwen、SC117 等元件的授權）。內含的 pyte 為 LGPL-3.0-or-later。
- **模型**：不夾帶任何模型權重。SC117 模型卡標示 Apache-2.0，並要求遵守上游模型授權。
- **成本**：免費；硬體與下載成本同 Strata。

## 限制與注意事項

- ⚠️ **非常新、仍是測試候選版**：repo 與 release 都是 2026-10-18 才建立，GitHub 標為 pre-release。作者在 `RELEASE_STATUS_請先閱讀.md` 自陳：從零安裝 Strata、下載數十 GB 權重、Pack、推論聊天的完整流程**尚未端到端驗證**，不同顯卡、Windows 10 的相容性也還沒測。
- 作者建議只把它當公開測試版，供自願測試者使用。
- 安裝程式未簽章，可能被 SmartScreen 或 Defender 攔下。
- SC117「abliterated」只代表第三方降低了部分拒答傾向，不保證完全不拒答；它不是 Strata 官方提供的權重。
- 右欄是保守解說，不是逐字翻譯；官方問句改版時，以左側英文原文為準。
- 指定既有資料夾時，工具不檢查其中的 BAT 是否被改過，只用可信來源。
- 匯出的日誌可能含路徑、帳號或 Token，分享前要遮蔽。
- repo 內文件版本號有些混雜（例如 `TEST_REPORT.md` 標題仍是 1.2.0-rc1），以 `RELEASE_STATUS_請先閱讀.md` 為最新狀態。

## 相關工具

- [Strata](Strata.md)：它導覽安裝的推論引擎
- [Janas](Janas.md)：另一個在消費級硬體跑大型 MoE 模型的本地引擎

## 資料來源

- https://github.com/encoreh78951-hub/StrataEasyTW （`README_從這裡開始.md`、`RELEASE_STATUS_請先閱讀.md`、`TEST_REPORT.md`、`THIRD_PARTY_NOTICES.md`、`LICENSE`）
- https://api.github.com/repos/encoreh78951-hub/StrataEasyTW （星數、建立時間、授權欄位）
- https://api.github.com/repos/encoreh78951-hub/StrataEasyTW/releases/tags/v1.3.0-rc1 （pre-release、附件）
