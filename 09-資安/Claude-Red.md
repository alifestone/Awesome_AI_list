# Claude-Red

- **分類**：資安 / 滲透測試
- **連結**：https://github.com/SnailSploit/Claude-Red

## 原清單說明

原清單只列名稱與連結，沒有說明。

> **查證結果**：Claude-Red 是攻擊性資安（offensive security）領域的 Claude Skills 集合，由 Kai Aizen（SnailSploit）維護。README 定位為授權紅隊演練、bug bounty、資安研究、CTF 與人員訓練使用。

## 概述

Claude-Red 收錄大量 `SKILL.md`，每個 skill 針對單一攻擊面，提供方法論、工具、邊界情況與升級路徑，目標是讓 Claude 在特定攻擊面上表現得像領域專家。Skill 依對話內容按需載入，例如提到 SQL injection 就會載入 `offensive-sqli`，沒用到的 skill 不佔用 context。

README 表示許多 skill 以 Sahar Shlichov 的攻擊檢查清單為基礎。

查閱時 GitHub 顯示約 7.5k stars、969 forks；最近更新於 2026-10-12。

## 核心功能／特色

README 標示 **78 個 skill、23 個類別**，路線圖目標約 130 個。類別包括：

- **Web**：SQLi、XSS、SSRF、SSTI、XXE、IDOR、request smuggling、GraphQL
- **認證**：JWT、OAuth/OIDC
- **Active Directory**：Kerberoast、ADCS、委派、hybrid AAD
- **無線**：WPA2/WPA3、EAP、WPS、藍牙、Zigbee、Z-Wave、LoRa
- **雲端、行動裝置、IoT**
- **基礎設施與紅隊**：EDR 規避、shellcode、初始入侵
- **Exploit 開發、Fuzzing、提權、後滲透**
- **容器、CI/CD、密碼學、供應鏈、社交工程、網路、AI 安全**
- **工具類**：分流檢查清單與報告撰寫

## 技術架構或運作原理

不是程式，而是一組 Markdown skill 檔：

- `Skills/<類別>/<skill>/SKILL.md`：每個 skill 一個資料夾
- `install.sh`：互動式安裝腳本
- `convert_skills.py`、`claude-skills.json`：轉換與索引
- `MINDMAP.md`、`CHANGELOG.md`、`CONTRIBUTING.md`（含 skill 模板與 frontmatter 規範）

Skill 依 Claude Skills 機制，根據 frontmatter 的描述在相關對話中自動載入。

## 安裝與使用方式

安裝到 Claude Code 的 skills 目錄（README 推薦）：

```bash
git clone https://github.com/SnailSploit/claude-red ~/.claude/skills/claude-red
```

其他方式：

- 只要部分類別：用 sparse checkout，例如只取 `Skills/web`、`Skills/active-directory`
- 安裝腳本：`./install.sh`、`./install.sh --target <dir>`、`./install.sh --category <name>`
- Claude.ai：把 `SKILL.md` 內容貼到 Project 的指示中

README 另提到 `cat Skills/web/offensive-sqli/SKILL.md | claude --system-file -` 的用法，此參數是否存在於目前的 Claude Code CLI 未經查證，使用前請以 `claude --help` 確認。

## 適用情境

- 授權紅隊演練或滲透測試中，讓 Claude 依專業方法論協助分析
- Bug bounty 分流與報告撰寫
- CTF 練習與資安教學
- 作為撰寫自家資安 skill 的範本

## 授權與成本

- **授權**：MIT。
- **成本**：免費；使用 Claude 需自付訂閱或 API 費用。

## 限制與注意事項

- **高度雙重用途**：內容涵蓋 EDR 規避、shellcode、exploit 開發、C2、釣魚與無線攻擊。只能用於已取得書面授權的測試；README 沒有內建授權檢查機制。
- **第三方 skill 的信任問題**：skill 會直接影響 agent 行為，安裝前應閱讀內容，並鎖定 commit 版本，避免日後更新引入不預期的指令。可參考 [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md) 的 skill 信任政策。
- 路線圖中許多類別（例如部分 AD、雲端身分）尚未完成。
- 查閱時 Releases 頁面為空，沒有正式版本標記。

## 相關工具

- [Pentest Copilot](./Pentest-Copilot.md)、[Pentest Swarm AI](./Pentest-Swarm-AI.md)：AI 滲透測試 agent
- [Promptfoo](./Promptfoo.md)：LLM 應用紅隊測試
- [yao-meta-skill](../06-Agent-框架與編排/yao-meta-skill.md)：skill 安全治理政策

## 資料來源

- https://github.com/SnailSploit/Claude-Red
