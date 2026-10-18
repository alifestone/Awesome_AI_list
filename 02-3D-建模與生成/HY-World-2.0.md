# HY-World 2.0

- **分類**：3D 建模與生成 / AI 生成 3D 世界
- **連結**：https://github.com/Tencent-Hunyuan/HY-World-2.0 （專案頁：https://3d-models.hunyuan.tencent.com/world/ ；線上試用：https://3d.hunyuan.tencent.com/sceneTo3D ；模型：https://huggingface.co/tencent/HY-World-2.0 ）

## 原清單說明

從文字或圖片生成可自由走動的 3D 世界。

> **查證補充**：正確，但只說了一半。HY-World 2.0 是騰訊混元的多模態「3D 世界模型」框架，有兩大能力：(1) **世界生成**：文字或單張圖片 → 可導航的 3D 世界（輸出 3DGS／網格），即原清單所說；(2) **世界重建**：多視角照片或影片 → 3D（深度、法線、相機參數、點雲、3DGS），由 WorldMirror 2.0 一次前向推論完成。另外要注意：⚠️ 授權為騰訊自訂的社群授權，**不適用於歐盟、英國與南韓**，並非 Apache／MIT 之類的開源授權。

## 概述

騰訊混元（Tencent Hunyuan）團隊開發的 3D 世界模型，2026-04-16 發布技術報告（arXiv:2604.14268）並陸續開源各模組。與 Genie 3、Cosmos、HY-World 1.5（WorldPlay）這類「生成像素影片」的世界模型不同，HY-World 2.0 直接產出**可編輯、可永久保存的 3D 資產**（網格／3D 高斯點雲），可匯入 Blender、Unity、Unreal Engine、Isaac Sim。官方以「看完就沒了的影片 vs. 建好就能一直玩的世界」來對比兩者。

截至 2026-10-18：約 2.7k 顆星、主要語言 Python，最近一次推送為 2026-08-12。README 消息：2026-05-18 開源完整世界生成推論程式與 WorldStereo 2.0 權重；2026-07 線上產品更新為 HY World 2.1（2.1 是否開源，資料不足）。

## 核心功能／特色

- **真正的 3D 世界，而非影片**：從一句文字或一張圖生成 3DGS、網格、點雲，風格可為寫實、卡通、遊戲等，可自由探索、編輯並匯入遊戲引擎。
- **照片／影片即時重建**：WorldMirror 2.0 從多視角照片或隨手拍的影片，一次前向推論同時預測稠密點雲、深度圖、表面法線、相機參數與 3DGS；支援 50K–500K 像素的彈性解析度，可額外注入相機與深度先驗提升精度。
- **互動角色探索**：線上產品支援第一人稱導航與第三人稱角色模式，具物理碰撞，可在生成的街道、建築、地景中走動（官方稱可免費試用）。
- **全景生成**：HY-Pano 2.0 從文字或圖片生成 360° 全景，提供 HunyuanImage-3（含思維鏈改寫提示）與較輕量的 Qwen-Image-Edit 兩種後端。
- **WorldMirror 2.0 Gradio 網頁介面**：上傳圖片或影片，在瀏覽器中檢視 3DGS、點雲、深度圖、法線圖與相機參數。

## 技術架構或運作原理

世界生成為四階段管線：

1. **全景生成**（HY-Pano 2.0）：文字／圖片 → 360° 全景。
2. **軌跡規劃**（WorldNav）：由 VLM（如 Qwen3-VL-8B）辨識場景中值得探索的目標，規劃避開障礙物的相機路徑（使用 Recast navmesh）。
3. **世界擴展**（WorldStereo 2.0）：沿軌跡生成具記憶一致性的關鍵影格（PanoramaMemoryBank 維持跨軌跡一致性；預設用 DMD 加速的四步推論）。
4. **世界組合**（WorldMirror 2.0 + 3DGS 訓練）：抽影格、對齊深度與法線、求相機，最後訓練並匯出 3D 高斯點雲世界。

開源模型一覽（README Model Zoo）：

| 模型 | 用途 | 參數量 | 授權（Hugging Face 標示） |
| --- | --- | --- | --- |
| WorldMirror 2.0 | 多視角／影片 → 3D 重建 | 約 1.2B | Tencent HY-World 2.0 Community |
| HY-Pano 2.0 | 文字／圖片 → 360° 全景 | 約 80B | Tencent HY-World 2.0 Community |
| HY-Pano 2.0（Qwen LoRA） | 同上，輕量版 | 約 425M | Tencent HY-World 2.0 Community |
| WorldStereo 2.0 | 全景 → 3DGS 世界 | 約 17B | 權重放在 `hanshanxue/WorldStereo`，該 HF repo 標示 MIT（與主 repo 授權不同，使用前請自行確認） |

## 安裝與使用方式

建議 CUDA 12.8、Python 3.11 以上。官方建議先讓重建（WorldMirror 2.0）跑起來，再加裝世界生成所需元件：

```bash
git clone https://github.com/Tencent-Hunyuan/HY-World-2.0
cd HY-World-2.0
conda create -n hyworld2 python=3.11.15
conda activate hyworld2
pip install -r requirements.txt
# 另需安裝自訂 gsplat 與 FlashAttention（2 或 3）
```

WorldMirror 2.0 重建（權重首次執行時自動從 Hugging Face 下載）：

```python
from hyworld2.worldrecon.pipeline import WorldMirrorPipeline

pipeline = WorldMirrorPipeline.from_pretrained('tencent/HY-World-2.0')
result = pipeline('path/to/images')
```

```bash
python -m hyworld2.worldrecon.pipeline --input_path path/to/images   # CLI
python -m hyworld2.worldrecon.gradio_app                             # 網頁介面
```

世界生成：依序執行 `traj_generate.py` → `traj_render.py` → `video_gen.py` → `gen_gs_data.py` → `world_gs_trainer.py` 五個腳本，詳見 `hyworld2/worldgen/README.md`。

不想自架：直接用線上產品 https://3d.hunyuan.tencent.com/sceneTo3D 。

## 適用情境

- 從概念圖或一句描述，生成可走動的遊戲關卡、虛擬場景原型。
- 用手機影片或多張照片快速重建實景數位分身。
- 為機器人模擬（Isaac Sim）或 VR 產生 3D 環境。
- 研究 3D 世界模型、前饋式 3D 重建的學術用途。

## 授權與成本

- ⚠️ **授權**：**Tencent HY-WORLD 2.0 Community License Agreement**（GitHub 顯示為 NOASSERTION，即非標準授權）。重點條款：
  - **地域限制**：授權範圍「Territory」為全球**排除歐盟、英國與南韓**；在這些地區使用、重製、修改、散布、展示模型**或其輸出**皆未獲授權。
  - **大型商用門檻**：若被授權人在版本發布日（2026-04-15）前一個月，旗下所有產品或服務的月活躍用戶**超過 100 萬**，必須另向騰訊申請授權。
  - **不得用輸出改進其他 AI 模型**（HY-World 2.0 及其衍生模型除外）。
  - 散布時需附授權副本與 Notice 檔、標示修改；提供服務時需明確揭露實際提供者並聲明與騰訊無關；需遵守附件的可接受使用政策（AUP）。
  - 騰訊不主張對輸出的權利；準據法為香港法律。
- **成本**：開源權重免費；自架世界生成需大量 GPU（見下方限制）。線上產品官方稱可免費試用，付費方案與額度資料不足。

## 限制與注意事項

- ⚠️ 台灣使用者不受地域排除條款影響，但若產品或輸出會提供給歐盟、英國、南韓用戶，需特別注意授權不涵蓋。
- **硬體門檻高**：世界生成建議 ≥4 張 GPU（官方以 8 張 H20 測試），另需一個 vLLM 伺服器跑 VLM（如 Qwen3-VL-8B）做軌跡規劃；3DGS 訓練以 8 卡為基準，卡數減半需加倍訓練步數。HY-Pano 2.0 完整版約 80B 參數。
- 多 GPU 重建時，輸入圖片數必須 ≥ GPU 數。
- 安裝涉及自訂 gsplat、FlashAttention、git submodule 等編譯步驟，環境建置較繁瑣。
- 生成世界的尺度精度、網格品質是否適合工程用途，官方未提供量化資料，資料不足。

## 相關工具

- 同資料夾：[World Labs](World-Labs.md)（商業版的可探索 3D 世界生成，Marble）、[3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)（從影片重建 3DGS 並放進 Isaac Sim）、[SuperSplat](SuperSplat.md)（在瀏覽器中清理、編輯生成的 3DGS）、[Hyper3D（Rodin）](Hyper3D（Rodin）.md)（生成單一 3D 物件）
- 前作：[HunyuanWorld 1.0](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0)、[HunyuanWorld-Mirror](https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror)、[HY-WorldPlay](https://github.com/Tencent-Hunyuan/HY-WorldPlay)、[WorldStereo](https://github.com/FuchengSu/WorldStereo)

## 資料來源

- 原清單來源：Threads @davepoon128 貼文 https://www.threads.com/@davepoon128/post/DenVxBCkyaN
- https://github.com/Tencent-Hunyuan/HY-World-2.0 （README）
- https://github.com/Tencent-Hunyuan/HY-World-2.0/blob/main/License.txt （授權全文）
- https://github.com/Tencent-Hunyuan/HY-World-2.0/blob/main/hyworld2/worldgen/README.md （世界生成管線與硬體需求）
- https://github.com/Tencent-Hunyuan/HY-World-2.0/blob/main/hyworld2/panogen/README.md （HY-Pano 2.0 兩種後端）
- https://api.github.com/repos/Tencent-Hunyuan/HY-World-2.0 （星數、推送日期）
- https://huggingface.co/tencent/HY-World-2.0 、https://huggingface.co/hanshanxue/WorldStereo （模型卡授權標示）
- https://arxiv.org/abs/2604.14268 （技術報告）
