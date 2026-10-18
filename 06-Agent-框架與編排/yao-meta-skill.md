# yao-meta-skill

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/yaojingang/yao-meta-skill
- **security 政策**：https://github.com/yaojingang/yao-meta-skill/tree/main/security

## 原清單說明

原清單只列名稱與 `security/` 目錄的連結，沒有說明。

> **查證結果**：連結指向的是 yao-meta-skill 專案中的 `security/` 目錄，裡面是 skill 套件的供應鏈安全政策，而不是獨立的資安工具。yao-meta-skill 本身是「建立、評測、打包與治理 agent skill」的 meta-skill，因此本清單把整個專案歸在 Agent 框架與編排，security 政策當作它的特色介紹。

## 概述

yao-meta-skill（「Yielding AI Outcomes」）是用來製作可重複使用 agent skill 的 meta-skill。1.0 版著重於產生可跨平台安裝的 skill 套件；2.0 版自稱「Skill OS」，涵蓋建模、多目標編譯、測試、發布審查與迭代。輸出目標包括 OpenAI、Claude、通用 Agent Skills 相容套件與 VS Code workflow。README 表示專案已可供 beta 與外部測試。

`security/` 目錄定義 skill 在發布前必須通過的安全與信任政策。它把腳本與對外發布的 skill 套件視為**供應鏈風險**，要求受治理的 skill 在發布前產出信任報告。

查閱時 GitHub 顯示約 2.7k stars、252 forks；作者為 GitHub 帳號 `yaojingang`。

## 核心功能／特色

### `security/` 目錄內容

| 檔案 | 用途 |
| --- | --- |
| `trust_policy.md` | 總體信任政策：哪些情況阻擋發布、哪些只發警告 |
| `permission_policy.json` / `.md` | 高權限能力（網路、檔案寫入、子程序）的核准紀錄 |
| `network_policy.json` / `.md` | 每個可連網腳本允許連線的主機範圍 |
| `script_policy.md` | 腳本規範 |
| `dependency_policy.md` | 相依套件規範 |
| `secret_policy.md` | 機密資訊（金鑰等）規範 |

### 信任報告涵蓋項目（依 `trust_policy.md`）

機密外洩風險、沒有 CLI／help 介面的腳本、`--help` 煙霧測試失敗、互動式或可連網的腳本、每個可連網腳本的主機範圍、高權限能力的審查核准、相依套件是否鎖版、runtime 信任 metadata、套件完整性雜湊。

### 兩級執行

- **阻擋發布**：高風險機密、不受限的遠端 inline 執行、未經有效核准的高權限能力。每筆核准必須寫明審查者、範圍、理由、到期日、證據與對應的目標平台執行方式。
- **警告**：可連網腳本若在 `network_policy.json` 沒有對應條目，會顯示警告，直到宣告主機範圍為止。

### `permission_policy.json` 範例

查閱時的版本（schema 1.0，2026-06-13 由 Yao Team 審查）核准三項能力，到期日皆為 2026-09-30：

- **網路**：只有 `network_policy.json` 列出的腳本可對外連線，用途限於讀取 GitHub 公開 metadata、查找 benchmark、檢查更新、呼叫已審查的評測端點
- **檔案寫入**：限報告、registry metadata、測試暫存、套件產物、更新快取，以及使用者明確確認的 skill 安裝
- **子程序**：限本機驗證、打包、安裝模擬、CI；skill 更新只能透過白名單指令，且需 `--yes` 與更新後驗證

注意：上述核准的到期日（2026-09-30）在查閱本條目時（2026-10）已過，repo 是否已更新請自行確認。

## 技術架構或運作原理

- 主程式入口為 `SKILL.md`，統一 CLI 為 `scripts/yao.py`
- `trust_check.py` 產生信任與安全報告，涵蓋腳本、相依套件、機密風險與網路主機政策
- 其他目錄：`skill-ir/`（平台中立的 skill 中介表示）、`evals/`、`schemas/`、`reports/`、`runtime/conformance/` 等
- 審查結果可輸出為 HTML gate 頁面（Review Studio 2.0），顯示警告、阻擋項、豁免與修正建議

## 安裝與使用方式

```bash
# 安裝到 Codex
npx -y skills add yaojingang/yao-meta-skill -a codex -g -y
# 安裝到所有支援的 agent
npx -y skills add yaojingang/yao-meta-skill -a '*' -g -y
```

重新啟動 client 後，直接要求 agent 建立、改善或評測 skill。本機開發需 Python 3.11+，執行 `make ci-test`。

若只想參考安全政策，可直接閱讀 `security/` 目錄，作為自家 skill／plugin 發布流程的範本。

## 適用情境

- 團隊內部發布 agent skill 前的安全審查流程
- 參考如何把「網路、檔案寫入、子程序」權限寫成可稽核的核准紀錄
- 建立 skill 供應鏈的信任報告與阻擋規則

## 授權與成本

- **授權**：MIT。
- **成本**：免費。

## 限制與注意事項

- `security/` 是政策文件與設定檔，本身不會掃描任何東西；實際檢查由 `trust_check.py` 等腳本執行。
- 政策主要針對 yao-meta-skill 自己的 skill 發布流程，套用到其他專案需自行調整。
- README 的 91.5/100 評分為專案自評。
- README 表示專案處於 beta 階段。

## 相關工具

- [Claude-Red](../09-資安/Claude-Red.md)：資安領域的 Claude skill 集合（可用本政策的思路審查第三方 skill）
- [Foundry Security Spec](../09-資安/Foundry-Security-Spec.md)：同樣強調「以基礎設施而非 prompt 做沙箱」的規格

## 資料來源

- https://github.com/yaojingang/yao-meta-skill
- https://github.com/yaojingang/yao-meta-skill/tree/main/security
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/security/trust_policy.md
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/security/permission_policy.json
