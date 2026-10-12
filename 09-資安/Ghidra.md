# Ghidra

- **分類**：資安 / 逆向工程
- **連結**：https://github.com/NationalSecurityAgency/ghidra

## 原清單說明

NSA 開源的逆向工程框架。

> **查證結果**：與 README 一致。README 說明 Ghidra 是由美國國家安全局（NSA）研究處（Research Directorate）建立並維護的軟體逆向工程（SRE）框架。

## 概述

Ghidra 是一套分析已編譯程式碼的工具集，支援 Windows、macOS、Linux。它可以分析多種處理器指令集與執行檔格式，支援互動與自動化兩種模式，也能用 Java 或 Python 撰寫擴充與腳本。

查閱時 GitHub 頁面顯示約 84.7k stars、9.4k forks、18,699 commits。Releases 頁標示的最新版本是 **Ghidra 12.1.4**（9 月 21 日，頁面未顯示年份），前兩版為 12.1.3（8 月 18 日）與 12.1.2（6 月 5 日）。

## 核心功能／特色

- 反組譯（disassembly）與組譯（assembly）
- 反編譯（decompilation）：把機器碼還原成類 C 的虛擬碼
- 圖形化呈現，例如控制流程圖
- 腳本：可用 Java 或 Python（含 PyGhidra）撰寫腳本與擴充
- 支援多種處理器指令集與執行檔格式（README 未逐一列出，具體清單資料不足）
- README 稱另有「數百項其他功能」
- 開發整合：Eclipse 外掛 GhidraDev（位於 release 的 `Extensions/Eclipse/GhidraDev/`）；也可從 Script Manager 用 VS Code 編輯腳本，或在 CodeBrowser 用 `Tools → Create VSCode Module project` 建立專案

## 技術架構或運作原理

Ghidra 需要 JDK 才能執行；從原始碼建置時還需要 C/C++ 編譯器來建置原生（native）元件（README 中的 `buildNatives`），程式語言比例資料不足。使用者在 CodeBrowser 等工具中載入二進位檔後，Ghidra 會自動分析出函式、資料型別、交叉參照等資訊，並以反組譯與反編譯視圖呈現。PyGhidra 提供 Python 介面，可用於自動化與 headless 分析。其他內部架構細節，README 未說明。

## 安裝與使用方式

**一般安裝**（README）：

1. 安裝 JDK 25（64-bit）。
2. 從 Releases 下載官方多平台套件 `ghidra_<version>_<release>_<date>.zip`（不要下載「Source Code」檔案）。
3. 解壓縮（不要直接覆蓋在舊版安裝上）。
4. 啟動：

```bash
./ghidraRun                 # Windows: ghidraRun.bat
./support/pyghidraRun       # 以 PyGhidra 啟動；Windows: support\pyghidraRun.bat
```

**從原始碼建置**：需 JDK 25、Gradle 9.1.0 以上（或在可上網時用 Gradle wrapper）、Python 3.9–3.14 與 pip，Linux/macOS 需 GCC 或 Clang 加 make，Windows 需 Visual Studio 2017 以上或 Microsoft C++ Build Tools（含 MSVC、Windows SDK、C++ ATL）。

```bash
gradle -I gradle/support/fetchDependencies.gradle
gradle buildGhidra          # 產物在 build/dist/
```

參與核心開發時，README 建議使用 Eclipse，並執行 `gradle prepdev eclipse buildNatives`。

## 適用情境

- 惡意程式分析與事件回應
- 漏洞研究、修補程式比對（防禦與負責任揭露用途）
- 韌體與嵌入式系統分析
- CTF 逆向題與教學
- 軟體互通性研究、遺留系統維護（原始碼已遺失時）
- 作為 AI 輔助逆向工具的後端（例如 GhidraMCP、REA）

## 授權與成本

- **授權**：Apache-2.0。
- **成本**：免費開源。

## 限制與注意事項

- **安全性**：README 警告部分 Ghidra 版本有已知安全漏洞，使用前應閱讀專案的 Security Advisories，並保持更新到修補後的版本。
- 分析不受信任的樣本（例如惡意程式）時，建議在隔離的虛擬機中進行。
- 新版需要 JDK 25；若環境只有舊版 JDK，需先升級。
- 反編譯結果是近似還原，可能有錯誤，需要人工判讀。
- **合法使用**：只分析自己擁有、已取得授權，或法律允許研究的軟體。部分軟體的授權條款（EULA）禁止逆向工程，各地法規（例如著作權法中的互通性例外）也不同，使用前請自行確認。

## 相關工具

- [GhidraMCP](./GhidraMCP.md)：讓 LLM 透過 MCP 操作 Ghidra
- [REA](./REA.md)：可把 Ghidra 當作原生分析引擎的 AI 逆向 MCP
- PyGhidra：Ghidra 的 Python 介面
- 同類工具：IDA Pro、Hopper（商業軟體）

## 資料來源

- https://github.com/NationalSecurityAgency/ghidra
- https://github.com/NationalSecurityAgency/ghidra/releases
