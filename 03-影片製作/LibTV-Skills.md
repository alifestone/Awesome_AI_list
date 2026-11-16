# LibTV Skills

- **分類**：影片製作 / AI 影片生成
- **連結**：https://github.com/libtv-labs/libtv-skills
- **平台**：https://www.liblib.tv/ （LiblibAI 的 AI 影片創作平台 LibTV）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為「AI Agent Skills for LibLib.tv — 让你的 AI Agent 轻松调用 LibTV 的生图、生视频等 AIGC 能力」。目前只有一個 skill（`libtv-skill`）與 5 支 Python 腳本。MIT 授權（指 skill 腳本本身；生成走 LibTV 付費平台）。截至 2026-11-17 約 1,260 顆星、125 個 fork；repo 建立於 2026-03-16，最後一次 push 為 2026-03-18，之後沒有更新。文件為簡體中文。

## 概述

LibTV 是 LiblibAI（哩布哩布）在 2026 年 3 月推出的 AI 影片平台：人在「無限畫布」上用文字、圖片、影片、音訊、腳本等節點組工作流；agent 則透過這個 skill 用一句話交辦任務。平台後端有自己的 agent，負責理解需求、拆分鏡、選模型、寫 prompt 並編排工作流，SKILL.md 列出的模型包括 Seedance 2.0、Kling 3.0／O3、Wan 2.6、NanoBanana、Midjourney、Seedream 5.0。

所以這個 skill 本身很薄：它只是一個「傳話員」，把使用者的原話送進 LibTV 的對話 API、輪詢結果、再把圖片影片下載回本機。SKILL.md 明確要求用戶端 agent **不要**自己擴寫或翻譯 prompt、不要拆任務，全部交給後端。

## 核心功能／特色

- **一句話交辦**：文生圖、文生影片、圖生影片、影片續寫；局部修改、元素替換、改鏡頭、風格遷移；以及「一句話生成短劇（劇本 → 分鏡 → 成片）」、復刻既有影片做 TVC／宣傳片、用歌做 MV、產品展示片等複合任務。
- **5 支腳本**（只用 Python 標準庫，Python 3.6+）：
  - `create_session.py`：建立會話或在既有會話追加訊息，回傳 `sessionId` 與專案畫布網址。
  - `query_session.py`：拉會話訊息，`--after-seq` 增量輪詢。
  - `upload_file.py`：上傳參考圖片或影片（限 image/*、video/*，200 MB 以下）到 LibTV 的 OSS。
  - `download_results.py`：從會話訊息抽出 `libtv-res.liblib.art` 的圖片影片網址，批次下載到本機（預設 `~/Downloads/libtv_results/`）。
  - `change_project.py`：把 access key 綁到一個新專案，隔離不同任務。
- **觸發範圍很廣**：SKILL.md 的描述要求「只要涉及 AI 圖片或影片的創作、生成、編輯」都觸發，例如「畫隻貓」「做個海報」。
- **輪詢策略寫在 skill 裡**：每 8 秒查一次，3 分鐘沒結果就告訴使用者稍後到畫布看；生成中不給畫布連結，完成後同時給結果網址與畫布連結。

## 安裝與使用方式

```bash
# 安裝到專案（npx skills 支援 Claude Code、Codex、OpenClaw 等）
npx skills add libtv-labs/libtv-skills --skill libtv-skill

# 在 LibTV 網站右上角 Skills 入口的個人中心取得 Access Key
export LIBTV_ACCESS_KEY="your-access-key"
```

之後直接跟 agent 說「生一段動漫影片」「把這支影片裡的紙船換成愛心」等即可。OpenClaw 也可從 ClawHub 安裝。手動除錯：

```bash
python3 skills/libtv-skill/scripts/create_session.py "生一个动漫视频"
python3 skills/libtv-skill/scripts/query_session.py <SESSION_ID> --after-seq 0
python3 skills/libtv-skill/scripts/download_results.py <SESSION_ID> --prefix storyboard
```

API 基底預設 `https://im.liblib.tv`（Bearer token 鑑權），README 列出四個端點：`POST /openapi/session`、`GET /openapi/session/:id`、`POST /openapi/session/change-project`、`POST /openapi/file/upload`。

## 適用情境

- 已經是 LibTV 會員，想讓 Claude Code、Codex、OpenClaw 直接幫忙生圖、生影片並把成品抓回本機。
- 不想自己挑模型、寫 prompt，只想「一句話出短劇／MV／廣告片初稿」，再到 LibTV 畫布上手動修。
- 要在一個 agent 流程裡順便產出分鏡圖、角色設定圖等素材。

## 授權與成本

- skill 腳本 MIT；但每次生成都消耗 LibTV 帳號的**積分**，需要訂閱會員。
- 量子位報導（2026-03-20）引述官方說法：年卡最低 39 折、部分模型再打折，訂閱附最多 150 條可靈 O3 ＋ 150 條可靈 3.0 的影片額度。實際價格以官網為準。

## 限制與注意事項

- **積分消耗不透明**：issue #1 回報讓 Codex 試做一支短片，畫面上什麼都沒看到，積分就從 1,900 掉到 500；skill 不會在動手前估算積分，送出後也無法中斷。後端 agent 一次可能跑很多個生成任務。
- **控制粒度很粗**：不能指定模型、時長、解析度等參數（issues #3、#8）；後端會**改寫你的 prompt**，API 回應也不直接顯示改寫後的版本（issue #12），重現性與一致性難控制。
- **觸發太積極**：描述寫明任何圖片／影片需求都要觸發，若同專案裝了其他生圖工具，可能被它搶走，並直接花掉積分。
- **輪詢 3 分鐘就放棄**：短劇、MV 這類長任務常超過，要自己到畫布或歷史紀錄查；有使用者回報結果已生成但 `query_session` 沒有回傳（官方回覆可先到歷史紀錄看）。
- **`change_project` 不能指定目標專案**，只能切到新專案（issue #2）。
- **`download_results.py` 的 `--output-dir` 可以是任意路徑**，第三方掃描把它標為可能覆蓋檔案的風險；只要不讓 agent 亂填路徑即可。
- **repo 自 2026-03-18 後沒有更新**，issues 都沒處理；LibTV 另有 OAuth 的 remote MCP（`https://mcp.liblib.tv/mcp`，見 issue #13），但 repo 沒有文件，且 issue #13 回報其中 3 個工具的 schema 頂層含 `allOf`，接 Anthropic 官方 API 的 Claude 會整個會話回 400。
- README 把 OpenClaw 連到 `github.com/anthropics/openclaw`，這個 repo 不存在；OpenClaw 實際在 `openclaw/openclaw`，與 Anthropic 無關。
- 介面、文件、平台都以簡體中文為主；上傳的素材會存到 LibTV 的 OSS。

## 相關工具

- [Higgsfield MCP](Higgsfield-MCP.md)：同樣讓 Claude 呼叫多個商用圖像／影片模型，但可以自己選模型，並能交付 AE 專案。
- [BeatDesign](BeatDesign.md)：本機的畫布＋時間軸工作台，開放 MCP，模型與參數可自己選。
- [Jellyfish](Jellyfish.md)、[ViMax](ViMax.md)：自架的短劇／長片流水線，劇本與分鏡可自己掌控。

## 資料來源

- https://github.com/libtv-labs/libtv-skills
- https://github.com/libtv-labs/libtv-skills/blob/main/skills/libtv-skill/SKILL.md
- https://github.com/libtv-labs/libtv-skills/issues （#1、#2、#3、#8、#12、#13）
- https://www.qbitai.com/2026/03/390320.html （量子位，LibTV 發布報導）
- https://mondoo.com/ai-agent-security/skills/clawhub/haofanwang/libtv-skill/1.0.3 （第三方安全掃描）
