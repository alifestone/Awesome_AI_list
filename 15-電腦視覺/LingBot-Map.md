# LingBot-Map

- **分類**：電腦視覺 / 串流 3D 重建（從連續 RGB 影像即時估計相機位姿與深度，產生點雲）
- **連結**：https://github.com/Robbyant/lingbot-map
- **模型權重**：https://huggingface.co/robbyant/lingbot-map （另有 [ModelScope](https://www.modelscope.cn/models/Robbyant/lingbot-map)）
- **專案頁**：https://technology.robbyant.com/lingbot-map
- **論文**：[arXiv 2604.14141](https://arxiv.org/abs/2604.14141)（技術報告）／[會議版 PDF](https://linzhuo.xyz/gct.pdf)（ECCV 2026）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：螞蟻集團旗下具身智慧公司 Robbyant（靈波）團隊的開源專案，2026-04 公開程式碼與權重，論文〈Geometric Context Transformer for Streaming 3D Reconstruction〉收錄於 ECCV 2026（README 標示為最佳論文候選）。程式與權重皆為 Apache-2.0。截至 2026-11 GitHub 約 1.9 萬星、Hugging Face 約 2 萬次下載。2026-11-26 另開 [lingbot-map-v2](https://github.com/Robbyant/lingbot-map-v2) 發布 2.0 版，但 2.0 改用 **CC BY-NC 4.0（不可商用）**。

## 概述

LingBot-Map 是前饋式（feed-forward）的 3D 基礎模型，做「串流 3D 重建」：影片一幀一幀送進來，模型直接輸出每一幀的相機位姿與深度圖，累積成整個場景的點雲與相機軌跡，不需要 COLMAP 那類逐場景迭代最佳化。作者把串流重建看成「記憶問題——該留下什麼、用什麼形式留」，以此設計模型的狀態。

它建立在 Meta 的 VGGT 與 DINOv2 之上，主打長序列：每幀的記憶與運算量幾乎固定，在 518×378 解析度下約 20 FPS，可跑超過 10,000 幀；官方示範了約 25,000 幀（13 分鐘）的室內走動影片。

## 核心功能／特色

- **Geometric Context Attention（GCA）**：串流狀態分三部分——錨點（anchor，固定座標系與尺度）、位姿參考視窗（局部密集幾何）、軌跡記憶（把整段歷史壓成每幀少量 token，用來修正長距離漂移）
- **高效串流推論**：paged KV cache 注意力（建議用 FlashInfer，沒裝則退回 PyTorch SDPA），支援 `--compile` 加速
- **長序列策略**：keyframe 間隔（只把每 N 幀存進 KV cache）與視窗模式（`--mode windowed`，每個視窗重置 cache、相鄰視窗共享 keyframe 對齊）
- **天空遮罩**：用 ONNX 天空分割模型濾掉戶外點雲中的天空點
- **互動檢視**：`demo.py` 以 viser 在瀏覽器（預設 `localhost:8080`）顯示點雲與相機軌跡
- **離線算繪**：`demo_render/batch_demo.py` 一條指令從影片跑推論並輸出點雲飛越 MP4，可用 YAML 設計鏡頭路徑（follow／birdeye／static／pivot）
- **評測腳本**：已釋出 KITTI、Oxford Spires、ETH3D、Tanks and Temples、7-Scenes、TUM 等資料集的評測流程
- 也能重建 AI 生成影片（官方示範重建自家世界模型 LingBot-World 生成的場景）

## 技術架構或運作原理

- DINO 骨幹抽影像特徵 → 交替的 Frame Attention 與 GCA 層 → 任務頭輸出相機位姿與深度
- 以 video RoPE 在 320 個視角上訓練，KV cache 超過 320 幀品質會下降，所以長影片靠 keyframe 與視窗模式
- Checkpoint：
  - `lingbot-map.pt`：平衡版（論文、評測與離線示範使用）
  - `lingbot-map-long.pt`：針對長序列與大場景
  - `lingbot-map-stage1.pt`：第一階段訓練權重，可載入 VGGT 做雙向（非串流）推論

## 安裝與使用方式

需要 NVIDIA GPU（CUDA）。官方建議 Python 3.10、PyTorch 2.8.0＋CUDA 12.8。

```bash
git clone https://github.com/Robbyant/lingbot-map
cd lingbot-map
conda create -n lingbot-map python=3.10 -y && conda activate lingbot-map
pip install torch==2.8.0 torchvision==0.23.0 --index-url https://download.pytorch.org/whl/cu128
pip install -e .
pip install flashinfer-python      # 建議；沒有就加 --use_sdpa
pip install -e ".[vis]"            # 視覺化
```

從 Hugging Face 下載 `lingbot-map.pt` 後，跑內附範例場景：

```bash
python demo.py --model_path /path/to/lingbot-map.pt \
    --image_folder example/courthouse --mask_sky
```

長影片（> 3000 幀）用視窗模式：

```bash
python demo.py --model_path /path/to/lingbot-map.pt \
    --video_path video.mp4 --fps 10 \
    --mode windowed --window_size 128 --overlap_keyframes 16 --keyframe_interval 2
```

顯示卡記憶體不夠時可用 `--num_scale_frames 2`、`--camera_num_iterations 1`（`--offload_to_cpu` 預設已開）；README 另連結了社群在 RTX 4060 8GB 上跑的修改版。離線算繪 MP4 另需 Open3D、NVIDIA Kaolin、ffmpeg 與自行編譯的 CUDA 擴充。

## 適用情境

- 用手機、無人機、行車或手持影片快速重建場景點雲與相機軌跡，不想跑 COLMAP／SfM
- 機器人與具身智慧的即時定位建圖（類 SLAM）研究，或做為下游 3D 任務（如 3DGS）的位姿初始化
- 把長時間的室內走動或空拍影片做成點雲飛越動畫
- 檢查 AI 生成影片（世界模型）的幾何一致性

## 授權與成本

- **授權**：1.0（本 repo 與 Hugging Face 權重）Apache-2.0，可商用。2.0 版（lingbot-map-v2）為 CC BY-NC 4.0，僅限非商業用途。
- **成本**：免費，需自備 NVIDIA GPU。

## 限制與注意事項

- 預設不重置狀態，可推論的距離受訓練資料中最長距離限制，超過會出現位姿崩潰（pose collapse），需改用視窗模式
- KV cache 超過約 320 幀品質下降，長影片要調 `--keyframe_interval`
- 官方未列最低 VRAM，20 FPS 的數字也沒註明是哪張 GPU
- 離線算繪依賴 NVIDIA Kaolin，只有 PyTorch 2.8.0＋cu128 有預編譯 wheel；PyTorch 2.9 需自行從原始碼編譯
- 作者已推出 2.0 並建議改用，但 2.0 授權改為不可商用；商業用途仍只能用 1.0
- 只輸出點雲／深度與位姿，不直接產生網格或 3DGS
