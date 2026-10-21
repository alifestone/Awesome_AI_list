# Matrix-Game

- **分類**：模型 / 影片生成（互動世界模型）
- **連結**：https://github.com/SkyworkAI/Matrix-Game
- **模型權重**：https://huggingface.co/Skywork/Matrix-Game-3.0 ・ 4.0：https://huggingface.co/Skywork/Matrix-Game-4.0
- **技術報告**：[3.0](https://github.com/SkyworkAI/Matrix-Game/blob/main/Matrix-Game-3/assets/pdf/report.pdf) ・ [4.0](https://github.com/SkyworkAI/Matrix-Game/blob/main/Matrix-Game-4/docs/Matrix_Game_4_0.pdf)
- **專案頁**：https://matrix-game-v3.github.io/ ・ https://matrix-game-v4-0.github.io/page/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：Skywork AI（崑崙萬維）開源的「互動世界模型」系列：給一張圖和一段文字，模型依鍵盤滑鼠動作即時生成接下來的畫面，像在玩一個由影片模型畫出來的遊戲。使用者給的 Hugging Face 連結是 **3.0**；GitHub repo 首頁在 2026-10-15 已改成 **4.0**，3.0 移到 `Matrix-Game-3/` 子資料夾。兩版做法不同（見下），本條目以 3.0 為主、一併整理 4.0。

## 概述

Matrix-Game 3.0（2026-03-27 發布）是加了記憶的互動世界模型，以 Wan2.2-TI2V-5B 為基底，用擴散 Transformer 依「動作＋相機姿態」逐段自回歸生成影片。官方稱經蒸餾、INT8 量化與輕量 VAE 後，5B 模型可做到 720p、40 FPS 即時生成，並在一分鐘以上的序列中維持場景一致。

Matrix-Game 4.0（2026-10-15 發布）換了思路：遊戲邏輯、物理與輸入交給真正的遊戲引擎，模型只負責把低多邊形畫面「神經渲染」成精緻畫面，所以遊戲規則不會被模型「幻想」掉。

GitHub repo 建立於 2025-05-06，查詢當下（2026-10-22）約 2,690 顆星，最後推送 2026-10-19。HF 上 3.0 約 135 likes，4.0 約 49 likes。

## 版本

| 版本 | 發布 | 重點 | 授權 |
| --- | --- | --- | --- |
| 1.0 | 2025-05 | 系列第一個開源世界模型 | MIT |
| 2.0 | 2025-08 | 即時互動長影片生成 | MIT |
| 3.0 | 2026-03 | 長時記憶、720p 即時串流 | Apache-2.0 |
| 4.0 | 2026-10 | 遊戲引擎＋串流神經渲染 | Apache-2.0 |

## 核心功能／特色（3.0）

- **資料引擎**：結合 Unreal Engine 合成場景、自動化收集的 3A 遊戲畫面與真實影片，產生「影片—姿態—動作—提示詞」四元組訓練資料。
- **長時記憶**：用預測殘差與幀重新注入做自我修正，加上依相機位置取用的記憶，讓轉回原處時場景還對得上。
- **即時生成**：以 DMD（Distribution Matching Distillation）做多段自回歸蒸餾，少步取樣（範例用 3 步）＋ INT8 量化＋蒸餾過的 VAE 解碼器；官方稱 720p 40 FPS。
- **互動**：預設用隨機動作生成；加 `--interactive` 可自己輸入動作。
- **已釋出權重**：5B 基礎模型與蒸餾模型，訓練於 Unreal 場景的第一人稱畫面。官方說的「真實＋Unreal 混合資料版」與 28B（2×14B MoE）大模型**查詢當下尚未上架**。

## 核心功能／特色（4.0）

- **引擎負責玩法**：遊戲是 C++20／SDL2 寫的可執行程式，模型把它輸出的低多邊形 RGB 串流渲染成精緻畫面；HUD 與音效在模型之外疊加。
- **三個場景模型**：中世紀城堡、古埃及（第三人稱射擊）、城市賽車（駕駛，可隨場景動態更新提示詞）。
- **離線渲染＋瀏覽器 demo**：`matrix-game render` 把錄好的低多邊形影片轉成渲染版；`serve.sh` 透過 WebRTC 在瀏覽器即時遊玩（單人）。
- **消費級顯卡**：除 A100 80GB 外，另有 RTX 5090／5080／5070 Ti 的最佳化路徑；官方稱 864×480 下 5080 可達 67 FPS、5070 Ti 58 FPS（固定提示詞＋SageAttention，只算模型、不含影片 I/O）。
- **可改遊戲**：不載模型也能直接玩、錄製輸入，或讓 coding agent 改地形、物件、NPC 與規則。

## 安裝與使用方式

**3.0**（Linux，官方只測過 A／H 系列 GPU，64 GB RAM，需 FlashAttention）：

```sh
git clone https://github.com/SkyworkAI/Matrix-Game.git
cd Matrix-Game/Matrix-Game-3
conda create -n matrix-game-3.0 python=3.12 -y && conda activate matrix-game-3.0
pip install -r requirements.txt
hf download Skywork/Matrix-Game-3.0 --local-dir Matrix-Game-3.0

torchrun --nproc_per_node=$NUM_GPUS generate.py --size 704*1280 --dit_fsdp --t5_fsdp \
  --ckpt_dir Matrix-Game-3.0 --fa_version 3 --use_int8 --num_iterations 12 --num_inference_steps 3 \
  --image demo_images/001/image.png --prompt "..." --compile_vae \
  --vae_type mg_lightvae_v2 --lightvae_pruning_rate 0.75 --output_dir ./output
```

- 總幀數 = 57 + (num_iterations − 1) × 40。
- 用基礎模型改加 `--use_base_model --num_inference_steps 50`；多 GPU 可加 `--use_async_vae --async_vae_warmup_iters 1`。
- ⚠️ HF 模型卡與 3.0 README 的指令有兩處錯：clone 的 `SkyworkAI/Matrix-Game-3.0.git` 不存在（應 clone 主 repo 再進 `Matrix-Game-3/`），下載指令少了 `Skywork/` 前綴。上面已改正。
- 權重：5B DiT 約 13 GB、umT5-XXL 文字編碼器約 11.4 GB、Wan2.2 VAE 約 2.8 GB，另有兩版 LightVAE。

**4.0**（Linux、NVIDIA GPU、Python 3.12、PyTorch 2.12／CUDA 13.2）：

```sh
git clone https://github.com/SkyworkAI/Matrix-Game.git
cd Matrix-Game/Matrix-Game-4
python3.12 -m venv .venv && source .venv/bin/activate
pip install torch==2.12.0 torchvision==0.27.0 --index-url https://download.pytorch.org/whl/cu132
pip install -e '.[inference,server,download,test]'
# 依 README 用 matrix-game download 下載場景模型與遊戲資產，再：
matrix-game render --scene ancient-egypt --input lowpoly.mp4 --resources resources \
  --preset realtime --prompt-mode fixed --output outputs/egypt
```

RTX 顯卡要手動選 `--preset rtx5090`／`rtx5080`／`rtx5070ti`，不會自動判斷；5080 與 5070 Ti 只支援固定提示詞。

## 適用情境

- 研究互動世界模型、動作條件影片生成、長時一致性（類似 Genie 的開源路線）。
- 從一張圖生成可「走進去」的第一人稱探索影片（3.0）。
- 用低多邊形遊戲＋神經渲染做原型，在消費級顯卡上試玩 AI 畫面的遊戲（4.0）。
- 為機器人、自駕等模擬需求產生動作可控的影片資料。

## 授權與成本

- **授權**：3.0、4.0 為 Apache-2.0；1.0、2.0 為 MIT。第三方元件與遊戲資產保有各自授權。
- **成本**：開源可自架；3.0 實際上需要資料中心級 GPU，4.0 最低到 RTX 5070 Ti。

## 限制與注意事項

- 3.0 已釋出的權重只訓練在 Unreal 場景，換成真實照片當起始圖效果未知；真實資料版與 28B 版尚未釋出。
- 40 FPS／67 FPS 都是官方自報、只計模型推論；4.0 官方明說 `--fps 40` 是擷取節奏，不保證吞吐或延遲，影片編碼、網路與瀏覽器解碼還會再加延遲。
- 3.0 只在 A／H 系列 GPU 與 Linux 上測過；4.0 的 Windows 入口未驗證。
- 4.0 只附三個場景模型，換別的遊戲需自己訓練。

## 相關工具

- [StreamRender-H3](StreamRender-H3.md)：NVIDIA 的同類研究，引擎輸出語意圖、MiniMax-H3 串流渲染成寫實畫面；畫質更高但需 8 張 GB200
- [Index-AniSora](Index-AniSora.md)：同樣以 Wan 系列為基底的影片生成模型（動漫風格）
- [HY-World 2.0](../02-3D-建模與生成/HY-World-2.0.md)：騰訊的 3D 世界模型，產出可保存的 3D 資產，而不是即時生成的像素畫面
- [World Labs](../02-3D-建模與生成/World-Labs.md)：商業版可探索 3D 世界生成
- [WanGP](../03-影片製作/WanGP.md)：在低階顯卡跑 Wan 等影片模型
- Wan2.2、Self-Forcing、GameFactory、LightX2V（官方致謝的上游專案）

## 資料來源

- https://github.com/SkyworkAI/Matrix-Game （README：版本、更新紀錄、授權）
- https://github.com/SkyworkAI/Matrix-Game/blob/main/Matrix-Game-3/README.md （3.0 需求、安裝、推論參數）
- https://github.com/SkyworkAI/Matrix-Game/blob/main/Matrix-Game-4/README.md （4.0 需求、安裝、RTX 最佳化、場景行為）
- https://huggingface.co/Skywork/Matrix-Game-3.0 （模型卡、檔案大小、基底模型、建立日期）
- https://huggingface.co/api/models/Skywork/Matrix-Game-4.0 （4.0 建立日期、基底模型 Wan2.2-Fun-5B-Control）
- https://api.github.com/repos/SkyworkAI/Matrix-Game （建立日期、星數、最後推送）
- https://api.github.com/repos/SkyworkAI/Matrix-Game-3.0 （回傳 404，確認模型卡的 clone 網址不存在）
