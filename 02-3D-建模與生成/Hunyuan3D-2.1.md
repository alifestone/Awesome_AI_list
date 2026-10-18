# Hunyuan3D 2.1

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1 （模型：https://huggingface.co/tencent/Hunyuan3D-2.1 ；線上試用：https://huggingface.co/spaces/tencent/Hunyuan3D-2.1 ；官網：https://3d.hunyuan.tencent.com ）

## 原清單說明

可產出含 PBR 材質、達到「可上線生產（production-ready）」等級的 3D 資產。（來源：Threads @davepoon128 貼文）

> **查證補充**：大致正確。repo 標題就是「From Images to High-Fidelity 3D Assets with Production-Ready PBR Material」，2.1 版把前代的 RGB 貼圖模型換成 PBR 材質管線。不過「production-ready」是騰訊的自我定位，品質是否達生產標準需自行評估。另外原貼文未提到授權：⚠️ 它**不是**一般開源授權，而是有地區與規模限制的「騰訊混元 3D 2.1 社群授權」（在歐盟、英國、南韓不適用，詳見下方）。

## 概述

Hunyuan3D 2.1 是騰訊混元團隊的圖片生成 3D 資產系統，由兩個模型組成：**Hunyuan3D-Shape（DiT）** 生成幾何形狀，**Hunyuan3D-Paint** 生成 PBR 貼圖。官方強調兩個重點：首次釋出完整模型權重與**訓練程式碼**，讓社群可直接微調；以及以物理為基礎的 PBR 材質合成，可呈現金屬反射等光線互動。技術報告為 arXiv 2506.15442。

截至 2026-10-18：GitHub 授權欄顯示 NOASSERTION（實為騰訊自訂社群授權）、約 4.2k 顆星、主要語言 Python；2025-06-13 釋出，repo 最後推送為 2025-10-17。

## 核心功能／特色

- **圖片生成形狀**：Hunyuan3D-Shape-v2-1（3.3B 參數）。
- **PBR 貼圖生成**：Hunyuan3D-Paint-v2-1（2B 參數），可為生成或既有的網格上材質。
- **完整開源訓練流程**：權重＋訓練程式碼，技術報告也以教學形式說明資料處理、訓練與評估。
- **diffusers 風格 API**、Gradio 網頁介面（支援 `--low_vram_mode`）、FastAPI API 伺服器（`api_server.py`）、Docker 檔。
- **評測**：README 的形狀評測（ULIP、Uni3D）與貼圖評測（CLIP-FiD、CMMD、CLIP-I、LPIPS）中，2.1 版優於 TripoSG、Step1X-3D、Trellis（第一代）、Direct3D-S2 等基準（官方自評）。
- **社群整合**：ComfyUI 節點（visualbruno/ComfyUI-Hunyuan3d-2-1）、Unity 支援（VR-Jobs）。

## 技術架構或運作原理

兩階段管線：

1. **Hunyuan3D-DiT**（flow matching）：由單張圖片生成無貼圖網格。
2. **Hunyuan3D-Paint**：以多視角（範例設定 `max_num_view=6`、`resolution=512`）生成 PBR 貼圖並烘焙回網格；另用 Real-ESRGAN 做超解析。

Notice.txt 說明部分第三方元件採 MIT、CreativeML Open RAIL++-M 等各自授權。

## 安裝與使用方式

官方測試環境：Python 3.10、PyTorch 2.5.1+cu124。README 稱支援 macOS、Windows、Linux。

```bash
pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu124
pip install -r requirements.txt

cd hy3dpaint/custom_rasterizer && pip install -e . && cd ../..
cd hy3dpaint/DifferentiableRenderer && bash compile_mesh_painter.sh && cd ../..
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P hy3dpaint/ckpt
```

```python
import sys
sys.path.insert(0, './hy3dshape')
sys.path.insert(0, './hy3dpaint')
from textureGenPipeline import Hunyuan3DPaintPipeline, Hunyuan3DPaintConfig
from hy3dshape.pipelines import Hunyuan3DDiTFlowMatchingPipeline

shape_pipeline = Hunyuan3DDiTFlowMatchingPipeline.from_pretrained('tencent/Hunyuan3D-2.1')
mesh_untextured = shape_pipeline(image='assets/demo.png')[0]

paint_pipeline = Hunyuan3DPaintPipeline(Hunyuan3DPaintConfig(max_num_view=6, resolution=512))
mesh_textured = paint_pipeline(mesh_path, image_path='assets/demo.png')
```

Gradio 介面：

```bash
python3 gradio_app.py --model_path tencent/Hunyuan3D-2.1 --subfolder hunyuan3d-dit-v2-1 \
  --texgen_model_path tencent/Hunyuan3D-2.1 --low_vram_mode
```

**顯存需求**：形狀生成 10GB、貼圖生成 21GB，兩者一起共 29GB。

## 適用情境

- 從單張概念圖產出帶 PBR 材質的遊戲、VR 道具資產。
- 為既有白模自動上 PBR 貼圖。
- 研究或在自有資料上微調 3D 生成模型（有完整訓練程式碼）。
- 搭配 ComfyUI 或 Unity 建立內部資產產線（需符合授權地區與規模限制）。

## 授權與成本

- ⚠️ **授權：TENCENT HUNYUAN 3D 2.1 COMMUNITY LICENSE AGREEMENT（非 OSI 開源授權）**，重點：
  - **地區限制**：授權「不適用於歐盟、英國與南韓」，只在這些地區以外的「Territory」有效；在授權地區以外使用、複製、散布模型**或其輸出**都屬未經授權。Hugging Face 頁面也設定禁止歐盟使用者存取（`extra_gated_eu_disallowed`）。台灣在授權地區內。
  - **規模限制**：若在 2.1 版發布日，被授權人所有產品或服務的前一個月月活躍使用者（MAU）超過 100 萬，須另向騰訊申請授權。
  - **禁止用模型或其輸出改進其他 AI 模型**（Hunyuan3D 2.1 本身及其衍生模型除外）。
  - 需遵守騰訊的可接受使用政策（AUP）；不授予商標權。
  - 在上述條件內，商業使用免授權金。
- **成本**：開源權重免費；自行準備約 29GB 顯存（低顯存模式可降低，實際數值資料不足）。官網雲端服務的價格本次未查證，資料不足。

## 限制與注意事項

- 歐盟、英國、南韓的個人與公司不在授權範圍內；跨國團隊或對這些地區提供服務時須特別注意。
- 開源 repo 只提供**圖片**生成 3D；文字生成 3D 需先用文生圖模型產圖（Hugging Face 標籤有 text-to-3d，但 README 未提供文字輸入流程）。
- 完整流程需約 29GB 顯存，消費級顯卡多半要開低顯存模式或分段執行。
- 貼圖管線需編譯自訂光柵化器與 mesh painter，安裝較繁瑣。
- repo 自 2025-10 後未再推送；騰訊後續版本（如更新的混元 3D 模型）是否開源、授權如何，資料不足。

## 相關工具

- [HunyuanWorld-1.0](https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0)（同團隊的 3D 世界生成）、[ComfyUI-Hunyuan3d-2-1](https://github.com/visualbruno/ComfyUI-Hunyuan3d-2-1)
- 同資料夾：TRELLIS.2（MIT 授權的圖片生成 PBR 3D）、Stable Fast 3D、Meshy MCP Server、Hyper3D（Rodin）

## 資料來源

- https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1 （README）
- https://api.github.com/repos/Tencent-Hunyuan/Hunyuan3D-2.1 （repo 中繼資料）
- https://raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2.1/main/LICENSE （社群授權全文）
- https://raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2.1/main/Notice.txt
- https://raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2.1/main/API_DOCUMENTATION.md
- https://huggingface.co/tencent/Hunyuan3D-2.1 （模型卡中繼資料）
- https://arxiv.org/abs/2506.15442 （技術報告）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原始貼文）
