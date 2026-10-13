# Higgsfield MCP

- **分類**：影片製作 / 影像生成 / MCP / 動態設計
- **連結**：https://higgsfield.ai/mcp
- **MCP server**：`https://mcp.higgsfield.ai/mcp`

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 整套影片代理，透過 MCP 讓 Claude 串接影像生成、Blender 與 After Effects，交付可以繼續編輯的專案檔。需要同時訂閱多個服務，使用前要先算清楚總成本。

> **查證結果**：原文沒有附連結。官方 MCP 頁面為 higgsfield.ai/mcp，server URL 為 `https://mcp.higgsfield.ai/mcp`。驅動 After Effects 的部分走另一個 bridge（官方部落格寫的是 `bridge.higgsfield.ai/mcp`），並需要先安裝 Higgsfield 的 Adobe 外掛。這是商業服務，不是開源專案。

## 概述

Higgsfield 是 AI 影像與影片生成平台。它的 MCP server 讓 Claude、Claude Code 等 MCP client 不需要 API key，就能呼叫平台上 30 多個圖像與影片模型。再搭配各桌面軟體的外掛，Claude 可以依照一段 brief 規劃多步驟製作流程：用 Higgsfield 生成素材，在 Blender 建 3D 場景，到 After Effects 做合成，最後交付可繼續編輯的 AE 專案，而不只是一支壓平的 MP4。

AI郵報強調，這並不代表 Claude 多了影片生成模型：Claude 負責編排與呼叫工具，生成、3D、合成與渲染都由各工具執行。

## 核心功能／特色

- **模型**：官方頁面列出 Nano Banana Pro、Google Omni Flash、Seedance 2.5、Seedance 2.0、Seedream 5.0 Lite、Kling 3、GPT Image 2、Soul 2.0 等。
- **桌面軟體工作流程**：Adobe After Effects、Premiere Pro、Illustrator、Photoshop、Blender、TouchDesigner、DaVinci Resolve Studio。
- **After Effects 外掛**（2026-07-21 公告）：同一個面板支援 AE 與 Premiere Pro。agent 可以操作 composition、圖層、關鍵影格、效果與腳本，也能依描述做效果、照參考重建設計、用自然語言產生 expression。外掛本身也能去背、改畫面比例、放大與以提示詞修改畫面。
- **現成 bundle 與 skills**：廣告、動態設計、UGC、faceless 影片等流程。

## 技術架構或運作原理

- **素材生成**：MCP client 連到 `https://mcp.higgsfield.ai/mcp`，呼叫 Higgsfield 雲端模型。
- **操作桌面軟體**：在本機安裝對應外掛（例如 Adobe 外掛），再透過 bridge 讓 Claude 操作開啟中的專案。官方部落格指出，一般的 MCP endpoint 只能生成素材，不能編輯 AE composition。
- AI郵報介紹的完整示範中，還用到 Suno（配樂）與 Soundly（音效）。

## 安裝與使用方式

1. 在 Claude 的 connector 設定中加入 Higgsfield 的 MCP URL，登入並授權。Claude Code 也是使用同一個 server URL。ChatGPT 則改用 Higgsfield 外掛。
2. 要操作 After Effects 時，先安裝 Higgsfield Adobe 外掛（AE 2024／24.0 以上），再依官方說明加入 bridge connector。
3. 在對話中提供 brief 與參考素材。
4. AE 工作流程必須在連著桌面軟體的電腦上執行；手機只能用來準備請求。

> 官方部落格（`bridge.higgsfield.ai/mcp`）與第三方指南（`mcp.higgsfield.ai/mcp`）寫的 URL 不同。前者用於 Adobe bridge，後者是一般生成用的 server，設定前請以官方最新文件為準。

## 適用情境

- 需要可繼續修改的 AE／Premiere 專案檔的動態設計案。
- 結合 3D（Blender）與 2D 合成的品牌短片。
- 讓 Claude 統籌素材生成、剪輯與合成的整套製作流程。

## 授權與成本

- **授權**：商業服務。
- **成本**：
  - 第三方指南指出，使用 MCP 需要付費方案，最便宜的 Starter 方案為年繳每月 $19、270 點。官方頁面未寫明，**未經官方確認**。
  - 外掛使用既有的 Higgsfield 點數；方案中屬於 Unlimited 的模型透過外掛生成時不扣點。
  - 完整流程還可能要付 Claude 用量、Adobe 訂閱、雲端渲染、Suno、Soundly 等費用，AI郵報提醒先估算總成本。

## 限制與注意事項

- 橫跨多個付費服務與桌面軟體，成本難以預估。
- 可重現性低：生成素材每次可能不同，外掛、字型、軟體版本與檔案路徑也會影響結果，團隊需要鎖定版本並保留人工審核。
- 權利問題：logo、字型、照片、生成圖、音樂與音效的授權各不相同，渲染成功不代表取得商用權利。
- 外掛不能離線使用，所有生成都在 Higgsfield 伺服器上執行。
- Blender 整合的細節公開資料很少，**資料不足**。
- AI郵報只有介紹文章，未實測。

## 相關工具

- [cc-blender-skill](../02-3D-建模與生成/cc-blender-skill.md)：讓 Claude Code 操作 Blender
- [Palmier Pro](Palmier-Pro.md)、[ChatCut](ChatCut.md)：同樣可透過 MCP 讓 agent 剪輯
- [OpenMontage](OpenMontage.md)：開源的整套影片製作 agent

## 資料來源

- https://higgsfield.ai/mcp （官方 MCP 頁面：server URL、支援的 client、整合、模型）
- https://higgsfield.ai/blog/higgsfield-after-effects （After Effects 外掛公告，2026-07-21）
- https://creatify.ai/blog/what-is-higgsfield-mcp-what-it-does-what-it-costs-and-how-to-use-it （第三方指南，方案價格）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
- https://www.aiposthub.com/higgsfield-claude-opus-5-5-motion-design-mcp-after-effects/ （AI郵報介紹，2026-09-29）
