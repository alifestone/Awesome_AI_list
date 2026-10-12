# cc-blender-skill

- **分類**：3D 建模與生成 / Blender × Agent
- **連結**：https://github.com/RobLe3/cc-blender-skill

## 原清單說明

Claude Code skill 外掛，經 Blender MCP 用自然語言建模、上材質、打光、運鏡、渲染、做動畫與匯出。

> **查證補充**：大致正確，但已有更新。目前版本 v1.4.0 自述為「可攜式 agent skill pack」，同一套 skill 供 Codex、Claude Code 與其他相容的 skill 宿主使用，不再只針對 Claude Code；skill 數量已擴充到 30 個（GitHub 簡介仍寫 10 個，為舊資訊）。README 也坦承 v1.4.0 在 Claude Code 上的原生 skill 探索與自動路由「仍需社群測試」，目前主要在 Codex 上驗證。

## 概述

一組可鏈式載入（chain-loadable）的 Blender skill，讓 AI agent 把「做一把劍並用三點打光渲染主視覺」這類自然語言需求，轉成 Blender Python，再透過 Blender MCP 的 `execute_blender_code` 在 Blender 中執行。作者定位為「任務層級的編排」：從自然語言需求一路產出完成的 3D 成品。

截至 2026-10-13：MIT 授權、約 89 顆星，最近一次推送為 2026-10-12。

## 核心功能／特色

- **30 個 skill**，以 `text-to-blender` 為總編排器，依需求載入：建模、材質（Principled BSDF PBR）、打光（三點、HDRI、攝影棚）、攝影機（構圖、景深、運鏡）、渲染（Cycles／EEVEE）、動畫（關鍵影格、F-curve、shape key）、匯出（glTF／FBX／OBJ／USD／STL）等。
- **專門流程**：`wireframe-to-3d`（2D 線稿轉 3D）、`reference-to-3d`（依參考圖鎖定重建）、輪廓轉網格、正交視圖對位、UV／貼圖集擬合、多視角擬合迴圈、修復佇列、參考外觀校準、吉祥物／Logo 重建等。
- **品質迴圈**（v1.3.0 起）：`quality-refinement-autoloop` 在輸出不理想時先凍結成品、診斷失敗面向，再修復；另有 `animation-quality-gate`（以 contact sheet 檢查動畫）。
- **雙 MCP 後端**（v1.4.0）：優先使用官方 Blender Lab MCP，也支援 ahujasid 的 blender-mcp；需要素材下載／生成功能時改用後者，同一任務中不切換後端。
- **Unreal 碰撞匯出前檢**與 Multires 烘焙流程（v1.4.0 新增）。
- **真實尺寸參考**：涵蓋劍、椅、瓶、杯、桌、燈、眼鏡、角色等常見物件尺寸。

## 技術架構或運作原理

- **純 skill 設計**：沒有 Python 包裝類別，也沒有自訂 MCP。宿主 agent 讀取意圖 → 載入相關 SKILL.md → 產生 Blender Python → 呼叫所選後端的 `execute_blender_code` → 檢查回應與 stdout → 回報結果。
- 狀態存在 `bpy.data`（跨呼叫保留）；每次執行都是全新的 Python 命名空間，因此以穩定名稱（如 `bpy.data.objects['GEO-sword']`）識別物件，命名遵循 Blender Studio 慣例（`GEO-`、`MAT-`、`LGT-` 前綴）。
- 開發驗證模式：以便宜的 Haiku 跑確定性測試並寫入結構化結果，再由 Opus 讀取並修補；作者稱約比全程用前沿模型便宜 10 倍。每個 skill 附 `evals/evals.json` 觸發測試（自述總計 100% TP／4% FP）。

## 安裝與使用方式

前置需求：相容的 skill 宿主、已設定好的 Blender MCP 後端、Blender。官方 MCP 需 Blender ≥ 5.1；ahujasid 路線保留 Blender ≥ 4.0（4.x 相容碼未實機測試）。影像處理輔助腳本需 Python 3.9+ 與 `opencv-python numpy scipy Pillow`。README 提醒：只啟用 Blender 外掛還不夠，必須另外跑 MCP 程序。

Codex 個人安裝（README 範例，以符號連結方式安裝每個 skill）：

```bash
git clone git@github.com:RobLe3/cc-blender-skill.git
cd cc-blender-skill
mkdir -p "$HOME/.agents/skills"
for skill in plugin/skills/*/; do
    ln -s "$(pwd)/$skill" "$HOME/.agents/skills/$(basename "$skill")"
done
```

（README 原版另有檢查同名目錄存在就拒絕覆蓋的保護迴圈。）

Claude Code：依 `plugin/skills/text-to-blender/references/agent-hosts.md`，把 skill 目錄放在 `~/.claude/skills/<name>` 或專案的 `.claude/skills/<name>`，以 `/text-to-blender` 或相符的自然語言需求呼叫；MCP 程序需在 Claude Code 自己的設定中另行設定。

使用範例：

```
Make a 3D model of a teapot and render it with three-point lighting.
$wireframe-to-3d ./glasses_front.png      # Codex 的指定 skill 語法
```

## 適用情境

- 用 AI agent 從零產出簡單到中等複雜度的產品／道具場景並渲染。
- 依參考圖、三視圖、貼圖包做較精確的重建。
- 需要匯出 glTF／FBX 等格式給遊戲引擎（含 Unreal 碰撞網格）的流程。

## 授權與成本

- **授權**：MIT。
- **成本**：skill 本身免費；需自行負擔所用 AI 模型的費用，Blender 免費。若透過 ahujasid 後端呼叫 Hyper3D 等外部生成服務，另依該服務計費。

## 限制與注意事項

README 的「目前做不到的事」：

- **設計品質 ≠ 建構正確**：能產出功能正確的物件，但美感細修（如曲面椅背、造型椅腳）仍需人工。
- **用基本幾何拼出的人臉**看起來只像抽象頭像；建議改用 Poly Haven／Sketchfab 匯入、`generate_hyper3d_model_via_text`、雕刻模式或委託美術。
- **細金屬高光**（眼鏡腳、珠寶）容易出現亮條紋。
- **數值驗證通過不代表渲染好看**，最終仍需使用者判斷。
- v1.4.0 只在 Blender 5.1.1 上實測；Blender 4.x、更新版本、Claude Code 原生探索與 Unreal 匯入行為仍待社群測試。

## 相關工具

- [官方 Blender Lab MCP](https://www.blender.org/lab/mcp-server/)、[ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp)
- [ra100/blender-claude-plugin](https://github.com/ra100/blender-claude-plugin)、Dev-GOM/blender-toolkit（README 列出的其他 Claude × Blender skill）
- 同資料夾：TheLongSilence（含 `blender-hardsurface` skill）、Hyper3D（Rodin）

## 資料來源

- https://github.com/RobLe3/cc-blender-skill （README）
- https://api.github.com/repos/RobLe3/cc-blender-skill （repo 中繼資料：簡介、授權、星數、主題）
- https://raw.githubusercontent.com/RobLe3/cc-blender-skill/main/plugin/skills/text-to-blender/references/agent-hosts.md
