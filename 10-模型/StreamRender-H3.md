# StreamRender-H3

- **分類**：模型 / 影片生成（互動世界、串流神經渲染）
- **連結**：https://nvlabs.github.io/Sana/Sol-Engine/StreamRender-H3/
- **原始碼**：https://github.com/NVlabs/Sana/tree/sol-engine/models/streamrender_h3
- **模型權重**：https://huggingface.co/Efficient-Large-Model/StreamRender-H3
- **相關論文**：Sol-Engine（Sol Video Inference Engine）https://arxiv.org/abs/2606.23743

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：NVIDIA Research（Sana／Sol-Engine 團隊，含 Song Han、Enze Xie）的研究部落格與開源 runtime。做法是「程式碼跑世界、影片模型畫畫面」：three.js 寫的賽車遊戲負責地圖、物理與輸入，每幀只輸出一張語意分割圖，再由以 MiniMax-H3 Ref2VA 微調、蒸餾成 2 步的串流影片模型即時畫成寫實影片。程式碼、權重都已公開，但**部署需要同一 NVLink 域內的 8 張資料中心級 GPU**（官方數字在 GB200 上量測），一般人無法自己跑；渲染器權重沿用 **MiniMax-H3 社群授權**，不是 Apache，且**不適用於歐盟、英國、南韓與美國**。

## 概述

StreamRender-H3 把互動世界拆成兩半：**Code Game Engine** 保存所有能用程式精確描述的東西（賽道、碰撞、規則、NPC），固定時間步推進，所以同樣輸入一定得到同樣軌跡、回到同一地點看到同一場景；**Streaming Diffusion Render** 只負責外觀，依「開場參考圖＋提示詞」決定材質、光線與風格。兩者之間只傳語意圖（每個像素塗成類別的純色，賽車 demo 有 13 類），因此同一局遊戲換一張參考圖就能從黃昏變成雪景。官方把它比作 NVIDIA DLSS 5 的生成式渲染，但更進一步：模型拿到的只有語意圖，整個畫面都是生成的。

和 [Matrix-Game 4.0](Matrix-Game.md) 的思路幾乎一樣（引擎管玩法、模型做渲染），差別在 Matrix-Game 4.0 輸入低多邊形 RGB、可在消費級顯卡跑；StreamRender-H3 輸入語意圖、用大模型換更高畫質，但要資料中心級硬體。

HF 權重於 2026-10-11 建立；程式碼放在 NVlabs/Sana 的 `sol-engine` 分支（Sana repo 約 9,400 顆星，Apache-2.0）。目前只有賽車一個場景。

## 核心功能／特色

- **串流生成**：每個 chunk（零點幾秒）以 2 步去噪生成；視窗保留「sink」（串流開頭，固定場景與物件身分）與最近歷史（延續動作），參考圖、提示詞與 sink 的 KV 只算一次後重複使用。
- **訓練**：從 MiniMax-H3 Ref2VA 微調，依序 teacher forcing → Resampling Forcing → DMD 蒸餾成 2 步。賽車資料為 39 條賽道、約 5,100 場 AI 駕駛比賽切出的 10,000 段 15 秒片段；參考圖由 GPT-Image-2.5 重繪首幀、提示詞由 Claude Opus 5.5 撰寫，目標影片由原生 H3 生成。
- **速度**：在 8 張 GB200 上每個串流步的擴散渲染 218 ms（PyTorch 基線 799.7 ms，3.67 倍加速，用到 FlashAttention-4、AdaLN 投影快取、持久化 KV 等）；另以 agent 迴圈最佳化的 Fast Causal H3 VAE，單張 GB200 解碼 2 個潛在幀（720p）23.8 ms。
- **外觀控制**：同一條語意串流，只換參考圖與提示詞就能改天氣、時段、車身塗裝；官方展示 20 個場景各一分鐘的連續渲染。
- **瀏覽器遊玩**：本機開 `http://127.0.0.1:5191`，可用 WASD 駕駛或開 autopilot，引擎畫面與生成畫面並排顯示；附 60 個精選範例（20 個不同場景，加上 10 條路線各配 4 種外觀），語意影片與參考圖要另從 GitHub Release 下載。

## 安裝與使用方式

需求：**單一 NVLink 域內 8 張 GPU**（官方叢集設定為 2 節點 × 4 張、NVL72 機櫃）、Python 3.11、FlashAttention（含 FA4 CuTe 後端）、CUTLASS DSL、Triton、Node 22。官方提醒只裝 `requirements.txt` 不夠，CUDA kernel 環境要另外配。

```sh
git clone -b sol-engine https://github.com/NVlabs/Sana.git
cd Sana/models/streamrender_h3
hf download Efficient-Large-Model/StreamRender-H3 --local-dir /your/models/StreamRender-H3   # 約 207 GB
python /your/models/StreamRender-H3/download_assets.py   # 合併骨幹權重，再多 66 GB
npm --prefix coding/threejs-racing ci
python scripts/prepare_example.py --assets /your/models/StreamRender-H3/assets.json
GPUS=8 PYTHON_BIN=python bash scripts/launch_local.sh --assets configs/example.local.json
```

- 加 `BACKEND=passthrough` 可只測傳輸、不跑模型。
- 每個 worker 配置同時只支援一個互動 session。

## 適用情境

- 研究「遊戲引擎＋生成式渲染」、串流影片擴散、少步蒸餾與即時推論最佳化。
- 參考如何把語意圖當成引擎與影片模型之間的通用介面，讓任何能畫純色類別圖的引擎接上渲染器。
- 在有 GB200／NVL72 叢集的環境做互動世界 demo。

## 授權與成本

- **授權**：部署程式碼為 Apache-2.0。權重包不是單一授權：渲染器、因果解碼器與音訊 codec 依 **MiniMax H3 Community License**；Qwen 元件為 Apache-2.0，TAE 為 MIT。賽車引擎保留 TORCS 原始碼聲明與 Free Art License 素材授權。
- ⚠️ **MiniMax H3 授權重點**：
  - 適用地區排除**歐盟、英國、南韓與美國**，這些地區要另向 MiniMax 申請。
  - 商業產品年營收超過 US$2,000 萬需事先取得書面授權，商業產品介面須明顯標示「MiniMax H3」。
  - 不得用模型或其輸出改進 MiniMax H3 以外的 AI 模型。
- **成本**：免費下載，但需同一 NVLink 域內 8 張 GPU（官方用 GB200／NVL72）與約 273 GB 磁碟，實際只適合研究機構或雲端叢集。

## 限制與注意事項

- 目前只有一個場景：渲染器只用賽車資料（第三人稱追車視角）訓練，換別的遊戲需要自己蒐集資料重訓。
- 218 ms／步是官方在 GB200 上自報、只計擴散渲染的數字，實際遊玩還要加上編解碼、網路與瀏覽器的延遲；官方也承認仍在用完整 MiniMax-H3 DiT，下一步是縮小模型、提升畫質。
- 語意圖對所有對手車塗同一色，車輛塗裝只能靠參考圖、提示詞與模型自己的歷史維持。
- 開發端點預設綁 loopback，官方要求不要直接公開到網路。

## 相關工具

- [Matrix-Game](Matrix-Game.md)：Skywork 的同類開源專案，4.0 也是引擎＋串流神經渲染，可在 RTX 5070 Ti 起跑
- [Code Video Model](../03-影片製作/Code-Video-Model.md)：同樣「程式碼場景 → 代理影片 → MiniMax-H3」，但做的是離線影片而非即時互動
- [three.js](../04-設計---前端/three.js.md)：賽車引擎所用的 3D 函式庫
- MiniMax-H3（基底模型）、Qwen3-VL（條件編碼）、TAEHV、LongLive、Self Forcing、DMD

## 資料來源

- https://nvlabs.github.io/Sana/Sol-Engine/StreamRender-H3/ （研究部落格：架構、訓練資料、速度、限制）
- https://github.com/NVlabs/Sana/tree/sol-engine/models/streamrender_h3 （README：runtime 設定、需求、安裝、授權來源）
- https://huggingface.co/Efficient-Large-Model/StreamRender-H3 （模型卡、權重內容、授權標籤、建立日期）
- https://huggingface.co/Efficient-Large-Model/StreamRender-H3/blob/main/LICENSE （MiniMax H3 Community License 全文：排除地區、商業條款、使用限制）
- https://github.com/NVlabs/Sana/blob/sol-engine/models/streamrender_h3/examples/README.md （60 個範例的組成）
- https://huggingface.co/MiniMaxAI/MiniMax-H3 （基底模型與其授權名稱）
- https://api.github.com/repos/NVlabs/Sana （星數、授權）
