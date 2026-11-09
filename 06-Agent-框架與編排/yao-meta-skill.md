# yao-meta-skill

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/yaojingang/yao-meta-skill
- **中文 README**：https://github.com/yaojingang/yao-meta-skill/blob/main/docs/README.zh-CN.md

## 概述

yao-meta-skill（中文名「Yao 技能工厂」，YAO 取自「Yielding AI Outcomes」）是一個**用來製作 skill 的 skill**：把重複出現的工作流程、prompt、SOP、對話紀錄或腳本，整理成可重複使用、可跨平台安裝的 agent skill 套件，並負責後續的評測、打包、發布審查與迭代。

- **1.0 版**：重點在把工作流程轉成精簡、可讀、可跨平台安裝的 skill 套件。
- **2.0 版**：自稱「Skill OS」，把 skill 當成需要長期維護的團隊資產，涵蓋整個生命週期：建模 → 多平台編譯 → 測試 → 發布審查 → 上線後追蹤與下一輪迭代。

輸出目標包括 OpenAI、Claude、通用 Agent Skills 相容套件與 VS Code／Copilot workflow，也支援匯入 WorkBuddy。README 表示專案已可供 beta 與外部測試，但「世界級」等較強的宣稱仍要等外部與人工證據補齊。

查閱時（2026-11-09）版本為 2.1.1，GitHub 顯示約 2.7k stars、252 forks；作者為 GitHub 帳號 `yaojingang`（skill 內署名 Yao Team），repo 建立於 2026-03。

## 核心功能／特色

### 製作 skill 的流程

1. **先判斷值不值得做成 skill**：要有「會重複使用」與「可重複使用的輸出格式」兩個條件；一次性需求、摘要、翻譯、純文件、腦力激盪等請求會被排除（附 non-skill 決策樹）。
2. **意圖對話**：先自行推論，只在核心任務、輸出或方向有分歧時才問，每輪一題、最多兩輪，結論記成結構化假設，不保留完整對話。
3. **參考掃描**：預設靜默掃描 GitHub 上的同類熱門 repo 與使用者指定的參考，只有真正衝突時才提出來。
4. **先寫 trigger description**：先把「何時該啟動這個 skill」寫好並測過，再寫內文。
5. **產生套件**：`SKILL.md` 保持精簡，細節放 `references/`、可決定性的邏輯放 `scripts/`、證據放 `reports/`；只建立真的需要的資料夾。
6. **產出報告**：每個新 skill 會附雙語 HTML 解讀報告、總覽評分卡，以及 Review Studio 審查頁，另提出三個下一輪迭代方向。

### 四種模式（依重要性決定要加多少結構）

| 模式 | 適用 | 預設產出 |
| --- | --- | --- |
| Scaffold | 探索性、個人或短期使用 | 只有 `SKILL.md`、`agents/interface.yaml`，必要時少量 references |
| Production | 團隊會重複使用、誤觸發會浪費時間 | 加上 references、必要的 scripts、trigger 評測、`manifest.json` |
| Library | 組織內廣泛共用、需要可攜性與維護 | 加上正例／反例／近似例測試集、打包預期、維護 metadata |
| Governed | 發布關鍵、需要稽核 | 必須有 owner、審查週期、檔案型測試資料、輸出契約、rollback 邊界、信任報告與輸出品質評分卡；缺的證據要標 `missing evidence`，不可捏造 |

### 2.0 版的主要模組

- **Skill IR**：與平台無關的中介表示，描述意圖、觸發條件、輸入輸出、邊界、參考資料與預期產物；各平台的檔案都從這裡編譯出來。
- **Target compiler／adapter**：同一份 IR 產生 OpenAI、Claude、generic、Agent Skills、VS Code 各自的套件，並記錄不支援的功能與權限執行方式。
- **Output Eval Lab**：觸發檢查、輸出斷言、執行時間與 token 證據、可重現的 benchmark、盲測 A/B 評審包與獨立答案卷。
- **Review Studio 2.0**：單一 HTML 審查頁，彙整意圖、觸發、輸出評測、context 成本、執行時期檢查、信任、豁免、審查註記、阻擋項與逐項修正建議。
- **發布治理**：套件驗證、安裝模擬、執行時期權限探測、證據一致性檢查，以及阻擋過早對外宣稱的「claim guard」。
- **SkillOps 迴圈**：只記錄 metadata 的使用與漂移追蹤（不記參數或原始內容）、每日／每週維護報告，以及需人工核准才會寫入的改進提案。

### Trigger 評測

這是專案最著重的部分：用 train／dev／holdout 分組、盲測 holdout、對抗性 holdout、獨立 rubric 評審與「路由搶奪」（route confusion）檢查來驗證 description，全部乾淨才允許升版。README 列出的回歸測試集為 21 類、66 個 prompt。

### Skill 供應鏈安全政策（`security/`）

專案把腳本與對外發布的 skill 套件視為供應鏈風險，`security/` 目錄定義受治理的 skill 發布前要通過的規則，由 `trust_check.py` 產生信任報告：

- **檢查項目**：機密外洩風險、腳本有沒有 CLI／`--help` 且能通過煙霧測試、互動式或可連網的腳本與其允許的主機範圍、高權限能力的核准、相依套件是否鎖版、套件完整性雜湊等。
- **兩級執行**：高風險機密、不受限的遠端 inline 執行、未經有效核准的高權限能力會**阻擋發布**；可連網腳本若沒在 `network_policy.json` 宣告主機範圍則只**警告**。
- **權限核准紀錄**（`permission_policy.json`）：網路、檔案寫入、子程序三項能力各自寫明審查者、範圍、理由、到期日、證據與各目標平台的執行方式。查閱時的版本於 2026-11-09 重新審查，到期日為 2027-02-09。

這套政策也可單獨拿來當自家 skill／plugin 發布流程的範本。

## 技術架構或運作原理

```
輸入（流程筆記／prompt／對話紀錄／文件）
  → 意圖模型（任務、輸出、排除條件、標準）
  → Skill IR
  → skill 套件 ＋ 各平台 adapter
  → Eval Lab（觸發／輸出／benchmark／執行時期）
  → Review Studio（gate、警告、豁免）
  → 發布邊界（套件驗證、安裝模擬、claim guard）
  → SkillOps（回饋、漂移 → 回到意圖模型）
```

- 入口為 `SKILL.md`（依 frontmatter 的 description 路由到最輕的模式），統一 CLI 為 `scripts/yao.py`
- `agents/interface.yaml` 是中立的 metadata 來源，不綁定特定廠商的路徑
- 其他目錄：`references/`（方法論文件）、`skill-ir/`、`evals/`、`examples/`、`failures/`（反模式與可執行的失敗案例）、`templates/`、`security/`、`reports/`
- 啟動時會檢查更新（24 小時最多一次，網路失敗不影響任務）；`self-update` 只對已驗證的安裝管道生效，且必須加 `--yes` 才會變更

## 安裝與使用方式

```bash
# 安裝到 Codex
npx -y skills add yaojingang/yao-meta-skill -a codex -g -y
# 安裝到所有支援的 agent
npx -y skills add yaojingang/yao-meta-skill -a '*' -g -y
```

重新啟動 client 後，直接說「把這個流程做成 skill」「改善這個 skill」「評測這個 skill」「替這個 skill 加評測」即可觸發。產出後建議依序看 `reports/skill-interpretation.html`（雙語解讀，預設簡體中文）、`reports/skill-overview.html`（評分卡）、`reports/review-studio.html`（阻擋項與權限核准）。

也可以直接用 CLI：

```bash
python3 scripts/yao.py init my-skill --description "這個 skill 做什麼"
python3 scripts/yao.py validate my-skill
python3 scripts/yao.py review-studio my-skill
python3 scripts/yao.py package my-skill --platform claude --platform openai --output-dir dist --zip
```

WorkBuddy 使用者可用 `yao.py package . --platform generic --zip --self` 產生 ZIP 後上傳。本機開發需 Python 3.11+，執行 `make ci-test`。

## 適用情境

- 把團隊散落在對話、個人 prompt、口頭習慣裡的流程，整理成可安裝、可維護的 skill
- 把個人用的 skill 升級成團隊資產：補上介面契約、評測、信任檢查與發布紀錄
- 同一個 skill 要同時發給 Claude、Codex、VS Code 等多個平台
- skill 誤觸發或搶走其他 skill 的路由，需要系統化地測試與調整 description
- 建立團隊內部發布 skill 前的安全審查流程

## 授權與成本

- **授權**：MIT。
- **成本**：免費；實際花費取決於所用 agent 與模型。

## 限制與注意事項

- **流程偏重**：2.0 版的指令、報告與 gate 非常多，只是想快速寫一個小 skill 時用 Scaffold 模式即可，或改用更輕量的 skill-creator。
- **評分為自評**：README 的 91.5/100 加權分數是專案自己打的（對照 Anthropic Skill Creator 67.5、OpenAI Skill Creator 50.5）；人工盲測 5/5 勝出也只有一位評審，README 自己也註明這不是獨立的模型執行證據。
- **權限只是 metadata**：README 表示目前四個目標平台都是「metadata 宣告」而非平台原生強制執行，殘餘風險需自行評估。
- 啟動時會連網檢查更新；CLI 使用量統計需設 `YAO_CLI_TELEMETRY=1` 才會開啟。
- 中文互動預設語氣為「柔和、陪伴式」，產出報告預設簡體中文。
- README 表示專案處於 beta 階段。

## 相關工具

- [Superpowers](Superpowers.md)：內含 `writing-skills`，照最佳實踐寫新 skill 並測試，流程較輕
- [Matt Pocock Skills](Matt-Pocock-Skills.md)：輕量、可自行修改的工程紀律 skill 組，可當作被打包的對象
- [ECC](ECC.md)：大量現成 skill、agent 與資安掃描的整合包
- [Claude-Red](../09-資安/Claude-Red.md)：資安領域的 Claude skill 集合（可用本專案的信任政策審查第三方 skill）
- [Foundry Security Spec](../09-資安/Foundry-Security-Spec.md)：同樣強調以基礎設施而非 prompt 做權限控管的規格

## 資料來源

- https://github.com/yaojingang/yao-meta-skill
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/README.md
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/SKILL.md
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/references/operating-modes.md
- https://github.com/yaojingang/yao-meta-skill/tree/main/security
- https://raw.githubusercontent.com/yaojingang/yao-meta-skill/main/security/permission_policy.json
