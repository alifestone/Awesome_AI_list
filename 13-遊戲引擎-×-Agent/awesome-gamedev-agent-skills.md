# awesome-gamedev-agent-skills

- **分類**：遊戲引擎 × Agent / 遊戲開發 Skill 組
- **連結**：https://github.com/gamedev-skills/awesome-gamedev-agent-skills
- **網頁版目錄**：https://gamedev-skills.github.io/awesome-gamedev-agent-skills/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：名字叫 awesome，但**不是連結清單**，而是一整套自己撰寫的 Agent Skills（`SKILL.md` 格式）：74 個遊戲開發 skill 加 1 個 router，repo 內實際有 75 個 `SKILL.md`，與 README 數字相符。它**不連接、不操作**引擎編輯器，只在 agent 寫程式前載入對應引擎與主題的知識，和本資料夾其他 MCP 工具是互補關係。NOTICE 聲明所有 skill 皆依官方文件原創撰寫，並註明與各引擎廠商無關聯。

## 概述

給 Claude Code、Cursor、Codex、Gemini CLI、GitHub Copilot、Kiro、Windsurf、Cline 等 coding agent 用的遊戲開發 skill 庫，涵蓋 10 個引擎：Godot、Unity、Unreal、Phaser、PixiJS、three.js、Bevy、pygame、LÖVE、Roblox。使用者不必指定 skill 名稱，router 會從專案檔判斷引擎、從需求判斷主題，只載入需要的 skill。例如「幫我的 Godot 角色加二段跳」會載入 `godot-2d-movement` + `platformer`。

截至 2026-10-23：Apache-2.0 授權、約 3.0k 顆星，repo 建立於 2026-06-24，GitHub Release 最新為 v1.1.0（2026-06-26），但 main 分支持續更新，最近一次推送為 2026-10-22。維護者為 Abhishek Barali。

## 核心功能／特色

- **Router**：依 `project.godot`、`*.uproject`、`package.json`、`Cargo.toml` 等檔案判斷引擎（一次只選一個引擎），判斷不出來就詢問；再疊加主題、類型與流程 skill，依「引擎基礎 → 概念 → 類型」的順序載入，換主題時重新路由。
- **引擎 skill（46 個）**：Godot 16（GDScript、場景樹、TileMap、shader、多人連線、C#、headless 測試等）、Unity 8（Input System、ScriptableObject、NavMesh、Build pipeline 等）、Unreal 6（Blueprint、C++ Gameplay Framework、Enhanced Input、Behavior Tree、Niagara、打包）、網頁引擎 6（Phaser、PixiJS、three.js）、其他 10（Bevy ECS、pygame、LÖVE、Roblox 的 Luau／DataStore／UI／網路／物理／Studio 流程等）。
- **跨引擎主題（15 個）**：遊戲 AI、行為樹與 Utility AI、程序生成、對話系統、存檔、音訊、shader、物理手感、關卡設計、輸入系統、game feel、遊戲 UI/UX、相機、效能最佳化，以及 `create-game-assets`。
- **類型模板（9 個）**：平台跳躍、roguelike、RPG、FPS、塔防、卡牌、視覺小說、生存製作、解謎；只負責組合引擎與主題 skill，不重教基礎。
- **流程（4 個）**：Game Jam、快速原型、Steam 上架、itch.io 發布（`butler`）。
- **美術資產流程（`create-game-assets`）**：先鎖定美術方向與技術規格（視角、解析度、調色盤、像素比例），做出一個代表資產確認後再成批產出同系列資產，再用確定性的工具裁切、對齊、檢查透明度，最後在遊戲實際畫面中驗收並記錄來源與授權。附 `art-direction-brief.md`、`asset-manifest.json` 範本與兩支 Python QA 腳本（資產報告、contact sheet）。本身不生成圖片：有 `imagegen` 之類的生圖 skill 時才交給它，沒有就產出規格書與清單或用佔位圖。
- **版本釘選**：每個 skill 以指定版本為準撰寫（Godot 4.7、Unity 6.3 LTS、Unreal 5.8、Phaser 4.2、PixiJS 8.21、three.js r186、Bevy 0.20、pygame-ce 2.5.8、LÖVE 11.5），既有專案沿用其鎖定版本，不會擅自升級；`docs/VERSION-SUPPORT.md` 規定至少每季複查。
- **品質檢查**：`scripts/validate-skills.py` 驗證每個 skill 的格式，並附回歸測試；網頁版目錄由 `SKILL.md` 自動產生。

## 技術架構或運作原理

```text
router/SKILL.md            ← 判斷引擎 + 任務，決定要載入哪些 skill
skills/<引擎>/…/SKILL.md    ← 引擎專屬（一次只選一個）
skills/disciplines/…       ← 跨引擎主題（可疊加）
skills/genres/…            ← 類型模板（可疊加）
skills/workflows/…         ← 發布與開發流程（可疊加）
```

每個 skill 是一個資料夾：YAML 前言（name、description）加 Markdown 操作說明，部分附 `references/`、`assets/`、`scripts/`。agent 平時只看到描述，需要時才讀全文，因此不會一次塞滿 context。

## 安裝與使用方式

任一 agent（用 [`skills`](https://www.npmjs.com/package/skills) CLI 自動偵測並安裝到正確位置）：

```bash
npx skills add gamedev-skills/awesome-gamedev-agent-skills
# --list 先預覽；-g 裝成全域；-a claude-code / -a cursor 指定 agent
```

Claude Code 外掛市集：

```bash
claude plugin marketplace add gamedev-skills/awesome-gamedev-agent-skills
claude plugin install gamedev@awesome-gamedev-agent-skills
# 只用單一引擎：裝 router 再加 godot / unity / unreal / web-engines / other-engines
```

裝好後直接用白話描述需求，例如「幫我的 Unity RPG 做背包」「用 Godot 做程序生成地城的 roguelike」「用 butler 把遊戲發到 itch」。手動複製路徑見 `docs/INSTALLATION.md`。

## 適用情境

- 用 coding agent 寫遊戲程式時，讓它照目前引擎版本的正確 API 與慣例寫，而不是混用舊版寫法。
- 獨立開發者或 Game Jam 快速做出可玩原型，並套用平台跳躍、roguelike 等類型的常見結構。
- 需要風格一致的像素圖、tileset、UI 圖示等資產時，用 `create-game-assets` 管理美術方向與驗收流程。
- 準備上架 Steam 或 itch.io 的檢查清單。

## 授權與成本

- **授權**：Apache-2.0（NOTICE 著作權人為 Abhishek Barali 與貢獻者）。
- **成本**：免費；只需負擔所用 agent／模型的費用。`create-game-assets` 的 QA 腳本需 Python 與 `requirements.txt` 中的套件。

## 限制與注意事項

- 只提供知識與流程，**不會**自己開編輯器、跑遊戲或截圖驗證；要 agent 直接操作引擎，需搭配同資料夾的 MCP 工具。
- 內容以 2026 年的新版引擎為基準（如 Godot 4.7、Unreal 5.8、Unity 6.3），舊專案需注意 API 差異；作者已說明不會自動遷移。
- 各引擎深度不一：Godot 16 個，Unreal 只有 6 個，PixiJS、Phaser 各只有 1～2 個。
- GitHub Release 停在 2026-06 的 v1.1.0，實際內容以 main 分支為準；README 目錄表 Bevy 仍寫 0.19，skill 本體已改為 0.20。
- 專案很新（2026-06 建立），skill 由單一主要維護者撰寫，品質主要靠自訂 validator 與審查規範，並非引擎官方內容。

## 相關工具

- 同資料夾：[Unity MCP](Unity-MCP.md)、[Godot AI](Godot-AI.md)、[Unreal Engine MCP](Unreal-Engine-MCP.md)、[PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)：讓 agent 直接操作編輯器，可和本 skill 組搭配
- [Claude Code Game Studios](../06-Agent-框架與編排/Claude-Code-Game-Studios.md)：以多個角色 agent 模擬整個遊戲工作室流程
- [threejs-skills](../04-設計---前端/threejs-skills.md)：專注 three.js 的 skill 組

## 資料來源

- https://github.com/gamedev-skills/awesome-gamedev-agent-skills （README）
- https://api.github.com/repos/gamedev-skills/awesome-gamedev-agent-skills （repo 中繼資料：授權、星數、建立與推送日期）
- https://api.github.com/repos/gamedev-skills/awesome-gamedev-agent-skills/releases （v1.0.0、v1.1.0）
- https://api.github.com/repos/gamedev-skills/awesome-gamedev-agent-skills/git/trees/main?recursive=1 （75 個 `SKILL.md`）
- https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/NOTICE
- https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/docs/VERSION-SUPPORT.md
- https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/disciplines/create-game-assets/SKILL.md
- https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/other-engines/bevy-ecs/SKILL.md
