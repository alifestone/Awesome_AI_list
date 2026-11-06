# ViMax

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/HKUDS/ViMax
- **論文**：https://arxiv.org/abs/2606.07649

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：香港大學資料智能實驗室（HKUDS）的開源專案，repo 描述為「Agentic Video Generation（導演、編劇、製片與影片生成一體化）」。技術報告〈ViMax: Agentic Video Generation〉於 2026-06-02 發表在 arXiv（2606.07649）。MIT 授權。

## 概述

ViMax 是多 agent 的影片創作框架：輸入一個點子、一份劇本或一部小說，它會自動完成故事結構、角色設定、腳本、分鏡、逐鏡生成與最後合成，目標是做出幾分鐘以上、角色與場景前後一致的長片，而不是幾秒鐘的片段。

repo 於 2025-03-30 建立，查詢當下（2026-10-14）約 12,700 顆星，最後一次推送是 2026-09-30，目前版本 v1.2.0（2026-07-20，加入 Web UI）。

## 核心功能／特色

- **四種輸入流程**：
  - **Idea2Video**：一句構想 → 故事、角色、腳本、分鏡、成片。
  - **Script2Video**：給定劇本（標準劇本格式），轉成多場景、多鏡頭影片，盡量保留原意。
  - **Novel2Video**：把長篇小說壓縮改編成分集的影像敘事，追蹤角色與規劃場景。
  - **AutoCameo**：上傳一張人或寵物的照片，讓他出現在生成的故事裡並維持長相一致。
- **一致性機制**：管理參考圖、首幀與運鏡連續性；每個關鍵幀預設平行產 2 張候選，再由有視覺能力的 LLM 挑一張（可設為 1 關閉，省 API 費）。
- **互動介面**：
  - **Agent Loop + TUI**：在終端機和 agent 討論點子、修改企劃、控制渲染、續接舊 session。
  - **Web UI**（v1.2.0）：具名專案、agent 對話、上傳檔案、預覽分鏡與渲染結果、設定模型供應商，有深色模式。
- **平行生成**：彼此獨立的鏡頭與素材同時產生，加快多鏡頭影片的製作。
- **可換的模型後端**：LLM 走 OpenAI 相容介面（範例用 OpenRouter 上的 Gemini 2.5 Flash Lite；也支援 MiniMax）；生圖支援 Nano Banana、GPT Image 2；生影片支援 Veo、Google Omni、Seedance 2.0 Fast。

## 技術架構或運作原理

ViMax 把傳統影片製作的分工拆成 agent：編劇寫故事與腳本、導演設計分鏡與鏡頭、製片管理參考素材與一致性檢查，最後由影片生成器逐鏡產出並合成。流程大致是：

1. 解析輸入（點子、劇本或小說），產出故事結構與角色設定。
2. 寫腳本並拆成場景與鏡頭，設計運鏡與節奏。
3. 為角色、場景準備參考圖，生成每個鏡頭的首幀（多候選 + 自動挑選）。
4. 以首幀與參考圖呼叫影片模型逐鏡生成，再合成完整影片，配上角色語音與音效。

## 安裝與使用方式

環境：Linux 或 Windows，Python 3.12，用 uv 管理。

```bash
git clone https://github.com/HKUDS/ViMax.git
cd ViMax
uv sync
```

**互動式（TUI）**：複製設定檔並填入 LLM、生圖、生影片三組模型與 API key，也可以改用 `VIMAX_LLM_API_KEY` 等環境變數。

```bash
cp configs/agent.example.yaml configs/agent.local.yaml
vimax tui            # 開新 session
vimax tui resume     # 續接上一個 session
```

**Web UI**（需要 Node.js 18+，預設只綁 `127.0.0.1:4173`）：

```bash
cd web
npm install
npm run dev
```

**直接跑流水線**：在 `configs/idea2video.yaml` 或 `configs/script2video.yaml` 設好模型，把點子或劇本寫進 `main_idea2video.py`／`main_script2video.py` 後執行。

## 適用情境

- 從一句構想做出有角色、多場景的短片或童話動畫。
- 把現成劇本或小說章節轉成影片初稿，當動態分鏡（animatic）用。
- 把自己或寵物放進故事裡做客串影片。
- 研究長片的跨鏡頭一致性與多 agent 分工。

## 授權與成本

- **授權**：程式碼 MIT。
- **成本**：本身不含模型，全部透過 API 呼叫雲端的 LLM、生圖與生影片服務，費用依所選模型與鏡頭數而定；README 未給每支影片的估算，**資料不足**。開啟關鍵幀多候選會讓生圖費用加倍。

## 限制與注意事項

- 重度依賴付費的影片生成 API（Veo、Seedance 等），長片的鏡頭數一多費用就高。
- 成片品質受限於所選影片模型；角色一致性靠參考圖與自動挑選，不保證每一鏡都對。
- README 只列 Linux 與 Windows，沒有提到 macOS。
- Roadmap 中 MiniMax H3 影片模型與 skill 式工作流擴充尚未完成。

## 相關工具

- [OpenDirector](OpenDirector.md)：同樣從一句話做出分鏡影片，自架網頁工作室
- [PenShot](PenShot.md)：只做「劇本 → 分鏡提示詞」這一段，可接任何影片模型
- [AutoMV](AutoMV.md)：多 agent 做音樂 MV，同樣處理長片角色一致性
- [Index-AniSora](Index-AniSora.md)：動漫風格的影片生成模型

## 資料來源

- https://github.com/HKUDS/ViMax （README：功能、更新紀錄、安裝與設定）
- https://arxiv.org/abs/2606.07649 （技術報告標題與發表日期）
- https://api.github.com/repos/HKUDS/ViMax （repo 中繼資料：建立日期、星數、MIT、最後推送）
