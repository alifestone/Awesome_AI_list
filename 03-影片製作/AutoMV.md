# AutoMV

- **分類**：影片製作 / Agent 影片製作系統（從歌曲到 MV）
- **連結**：https://github.com/multimodal-art-projection/AutoMV
- **專案頁**：https://m-a-p.ai/AutoMV/
- **論文**：https://arxiv.org/abs/2512.12196

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：repo 對應論文〈AutoMV: An Automatic Multi-Agent System for Music Video Generation〉（arXiv 2512.12196，2025-12-13），作者來自 Multimodal Art Projection（M-A-P）社群與多所大學。Apache-2.0。

## 概述

AutoMV 是免訓練的多 agent 系統，輸入一整首歌，直接產出連貫的長篇音樂 MV。現有的音樂轉影片方法多半只能做短而零碎的片段，對不上歌曲結構、節拍與歌詞，角色也前後不一致。AutoMV 先用音樂分析工具抽出段落、人聲與帶時間戳的歌詞，再由編劇、導演 agent 寫腳本與鏡頭指示，呼叫圖片與影片生成模型，最後由驗證 agent 檢查品質。

論文同時提出一套整首歌 MV 的評測基準。repo 於 2025-12-09 建立，查詢當下（2026-10-14）約 137 顆星，最後一次推送是 2026-03-29。

## 核心功能／特色

- **音樂理解與前處理**：
  - 節拍追蹤與段落切分（SongFormer）。
  - 人聲／伴奏分離（htdemucs）。
  - 帶時間戳的歌詞轉錄（Whisper）。
  - 音樂描述：曲風、情緒、歌手特徵（Qwen2.5-Omni）。
- **多 agent 流水線**：
  - **Screenwriter Agent**：寫敘事、場景摘要與角色設定。
  - **Director Agent**：寫逐鏡腳本、運鏡指示與生成提示詞。
  - **Verifier Agent**：檢查物理合理性、是否照指示、角色是否一致。
- **角色庫（Character Bank）**：用結構化資料記錄每個角色的臉、髮型、膚色、服裝、性別、年齡等，讓同一角色在不同鏡頭中長得一樣。
- **依鏡頭類型切換生成後端**：
  - 一般的故事鏡頭：Doubao（豆包）影片 API。
  - 對嘴的演唱鏡頭：用分離出的人聲驅動 Qwen-Wan 2.2（S2V）。
  - 以關鍵幀引導生成，維持鏡頭之間的連續性。
- **整首歌 MV 評測基準**：4 大類（技術、後製、音樂內容、藝術）共 12 項細項，用 LLM 評審（Gemini-2.5-Pro／Flash）與人類專家評分，另有 ImageBind 跨模態相似度指標。

## 技術架構或運作原理

四個階段：

1. **音樂前處理**：切段落、分離人聲、轉錄歌詞、產生音樂描述，作為後續 agent 的上下文。
2. **編劇與導演 agent**：寫短腳本，把角色寫進共用角色庫，指定每段的運鏡。
3. **關鍵幀與影片片段生成**：先為每段產生首幀圖片，再依「故事」或「演唱」鏡頭呼叫不同的影片生成模型。
4. **Gemini 驗證與最終合成**：驗證 agent 檢查片段，合格後串接成完整 MV。

論文的實驗結果（30 首正式發行的歌曲）：

| 方法 | 成本 | 時間 | ImageBind ↑ | 人類評分 ↑ |
|---|---|---|---|---|
| Revid.ai-base | 約 $10 | 5–10 分鐘 | 19.9 | 1.06 |
| OpenArt-story | $20–40 | 10–20 分鐘 | 18.5 | 1.45 |
| **AutoMV** | $10–20 | 約 30 分鐘 | **24.4** | **2.42** |
| 人類專家 | ≥ $10k | 數週 | 24.1 | 2.90 |

論文也測試用多模態大模型當自動評審，結論是有潛力但仍落後人類專家。

## 安裝與使用方式

```bash
git clone https://github.com/multimodal-art-projection/AutoMV.git
cd AutoMV
pip install -r SongFormer_requirements.txt
conda install -c conda-forge ffmpeg
pip install -r requirements.txt
```

1. **設定環境變數**：`GEMINI_API_KEY`、`DOUBAO_API_KEY`、阿里雲 OSS 的 `ALIYUN_OSS_ACCESS_KEY_ID`／`ALIYUN_OSS_ACCESS_KEY_SECRET`／`ALIYUN_OSS_BUCKET_NAME`、火山引擎的 `HUOSHAN_ACCESS_KEY`／`HUOSHAN_SECRET_KEY`，以及 `WHISPER_MODEL`、`QWEN_OMNI_MODEL`、`GPU_ID`（選用）。
2. **下載模型**：Qwen2.5-Omni-7B（ModelScope）、Whisper Large-v2，路徑寫進 `config.py`；SongFormer 預訓練權重用 `python utils/fetch_pretrained.py` 下載（中國大陸可設 `HF_ENDPOINT=https://hf-mirror.com`）。
3. **（選用）本機對嘴生成**：下載 Wan2.2-S2V-14B，另建 conda 環境，並在 `generate_pipeline.py` 註解掉呼叫即夢 API 的 `gen_lip_sync_video_jimeng(...)`。README 說一首歌在 A800 上約需 4–5 小時，但比 API 便宜很多。
4. **放音檔**：`./result/{music_name}/{music_name}.mp3`，並在 `config.py` 填入 `music_name`（只能用英文字母、數字、底線）。
5. **執行**：

```bash
python -m picture_generate.main   # 產生每段的首幀圖片
python generate_pipeline.py       # 產生所有片段並合成 MV
```

成品在 `result/{music_name}/mv_{music_name}.mp4`。同一資料夾還有 `story.json`（完整分鏡）、`label.json`（角色庫）、`camera/`（運鏡指示）、`picture/`（首幀）、`piece/`（切好的音訊段）。

## 適用情境

- 為獨立音樂人的歌曲快速做出有故事、有對嘴鏡頭的完整 MV 初稿。
- 研究音樂轉影片（M2V）、長篇影片的角色一致性與多 agent 協作。
- 用論文的 12 項基準評測自己的 MV 生成系統。

## 授權與成本

- **授權**：程式碼 Apache-2.0。使用的模型與 API（Qwen2.5-Omni、Whisper、Wan2.2、Doubao、即夢、Gemini）各有自己的授權與服務條款。
- **成本**：論文估計每首歌約 $10–20 的 API 費用、約 30 分鐘。改用本機 Wan2.2-S2V 做對嘴可省 API 費，但需要高階 GPU（README 以 A800 為例）。

## 限制與注意事項

- 高度依賴中國的雲端服務：Doubao 影片 API、火山引擎（即夢）、阿里雲 OSS，海外使用者申請帳號可能較麻煩；另需 Gemini API。
- 安裝步驟偏研究程式碼風格：要手動下載多個模型、改 `config.py`，換成本機對嘴還得自己註解程式碼。README 部分段落排版有誤（例如 `pip install requirements.txt` 漏了 `-r`）。
- 本機跑 Qwen2.5-Omni-7B 與 Wan2.2-S2V-14B 需要大顯存 GPU；具體最低需求 README 沒有寫，**資料不足**。
- 人類評分 2.42 仍明顯低於專業 MV 的 2.90（滿分 5），適合當初稿而非直接發布。
- 2026-03-29 之後沒有更新。2026-03 曾移除寫死在 `llm_judge.py` 裡的 API key，使用舊版本時要留意。

## 相關工具

- [PDoomVideo](PDoomVideo.md)：用 Claude Code 寫程式畫出整支 MV，路線完全不同（程式化動畫，不用影片生成模型）
- [OpenDirector](OpenDirector.md)：多 agent 從一句話做出分鏡影片
- [Basic Pitch](../05-音訊/Basic-Pitch.md)：音訊轉 MIDI，同屬音樂資訊檢索（MIR）工具
- SongFormer、htdemucs、Whisper、Qwen2.5-Omni、Wan2.2-S2V

## 資料來源

- https://github.com/multimodal-art-projection/AutoMV （README：功能、安裝、使用、實驗結果）
- https://arxiv.org/abs/2512.12196 （論文摘要、作者、發表日期）
- https://m-a-p.ai/AutoMV/ （專案頁；原 multimodal-art-projection.github.io/AutoMV 轉址至此）
- https://api.github.com/repos/multimodal-art-projection/AutoMV （repo 中繼資料：建立日期、星數、Apache-2.0）
- https://api.github.com/repos/multimodal-art-projection/AutoMV/commits （最近提交：移除寫死的 API key）
