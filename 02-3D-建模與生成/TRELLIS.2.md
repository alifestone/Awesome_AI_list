# TRELLIS.2

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/microsoft/TRELLIS.2 （專案頁：https://microsoft.github.io/TRELLIS.2 ；模型：https://huggingface.co/microsoft/TRELLIS.2-4B ；線上試用：https://huggingface.co/spaces/microsoft/TRELLIS.2 ）

## 原清單說明

圖片 → 完整貼圖的 3D 資產，在 H100 上約 3 秒。（來源：Threads @davepoon128 貼文）

> **查證補充**：大致正確，但「約 3 秒」有前提。README 的速度表（NVIDIA H100 實測）是：512³ 解析度約 3 秒（形狀 2 秒＋材質 1 秒）、1024³ 約 17 秒、1536³ 約 60 秒，所以 3 秒只適用於最低的 512³ 解析度。輸出確實是含 PBR 材質（Base Color、Roughness、Metallic、Opacity）的完整貼圖資產。另外，官方開源版本只做**圖片**生成 3D，不支援文字輸入。

## 概述

TRELLIS.2 是 Microsoft 推出的大型 3D 生成模型（40 億參數），主打高擬真度的**圖片生成 3D（image-to-3D）**。它採用一種名為 **O-Voxel** 的「無場（field-free）」稀疏體素結構，能重建與生成拓撲複雜、有銳利特徵且帶完整 PBR 材質的 3D 資產。論文為〈Native and Compact Structured Latents for 3D Generation〉（arXiv 2512.14692），是前代 TRELLIS 的後繼。

截至 2026-10-18：MIT 授權、約 12.1k 顆星、主要語言 Python；repo 建立於 2025-11-26，最後推送為 2026-07-10。README 的 Roadmap 顯示論文、推論程式碼、4B 權重、HF Spaces 示範、依形狀生成貼圖、訓練程式碼都已釋出。

## 核心功能／特色

- **高解析度、高效率**：4B 參數模型使用一般的 DiT，搭配 16 倍空間降採樣的稀疏 3D VAE，把資產壓縮進精簡的潛在空間；支援 512³–1536³ 解析度。
- **任意拓撲**：O-Voxel 不受等值面（iso-surface）場的限制，可處理開放曲面（衣物、葉片）、非流形幾何、內部封閉結構，不需有損轉換。
- **豐富材質**：除了基本顏色，也建模 Roughness、Metallic、Opacity，支援寫實渲染與透明度。
- **快速資料轉換**：貼圖網格 → O-Voxel 在單一 CPU 上 < 10 秒；O-Voxel → 貼圖網格在 CUDA 上 < 100 毫秒，皆不需渲染或最佳化。
- **PBR 貼圖生成**：另提供「依既有 3D 形狀生成 PBR 貼圖」的推論程式（`example_texturing.py`、`app_texturing.py`）。
- **匯出 GLB**：內建簡化、重新網格化（remesh）與 UV 展開後匯出 GLB，貼圖最高可設 4096。
- **完整訓練程式碼**：可從頭訓練或在自有資料集上微調（SC-VAE、稀疏結構 flow、形狀 flow、貼圖 flow）。

## 技術架構或運作原理

- **O-Voxel**：同時編碼幾何與外觀的「全能體素」表示法，核心函式庫在 repo 的 `o-voxel/`。
- **Sparse Compression VAE（SC-VAE）**：形狀與貼圖各一個，提供高空間壓縮率。
- **三階段 flow-matching 生成**（依訓練設定檔命名推斷）：先生成稀疏結構（`ss_flow_img_dit_1_3B`），再生成形狀潛在（`slat_flow_img2shape_dit_1_3B`），最後依圖片與形狀生成材質潛在（`slat_flow_imgshape2tex_dit_1_3B`）。
- 訓練資料：論文寫「多種公開 3D 資產資料集」，README 範例使用 Objaverse-XL（Sketchfab 部分）。
- 同團隊開發的相依套件：[FlexGEMM](https://github.com/JeffreyXiang/FlexGEMM)（基於 Triton 的稀疏卷積）、[CuMesh](https://github.com/JeffreyXiang/CuMesh)（CUDA 加速的網格後處理、重新網格化、減面、UV 展開）。

## 安裝與使用方式

需求：目前只在 **Linux** 上測試；NVIDIA GPU **至少 24GB 顯存**（已在 A100、H100 驗證）；CUDA Toolkit（建議 12.4）；Python ≥ 3.8；建議用 Conda。

```bash
git clone -b main https://github.com/microsoft/TRELLIS.2.git --recursive
cd TRELLIS.2
. ./setup.sh --new-env --basic --flash-attn --nvdiffrast --nvdiffrec --cumesh --o-voxel --flexgemm
```

```python
from PIL import Image
from trellis2.pipelines import Trellis2ImageTo3DPipeline
import o_voxel

pipeline = Trellis2ImageTo3DPipeline.from_pretrained("microsoft/TRELLIS.2-4B")
pipeline.cuda()
mesh = pipeline.run(Image.open("assets/example_image/T.png"))[0]
mesh.simplify(16777216)

glb = o_voxel.postprocess.to_glb(
    vertices=mesh.vertices, faces=mesh.faces, attr_volume=mesh.attrs,
    coords=mesh.coords, attr_layout=mesh.layout, voxel_size=mesh.voxel_size,
    aabb=[[-0.5, -0.5, -0.5], [0.5, 0.5, 0.5]],
    decimation_target=1000000, texture_size=4096, remesh=True,
)
glb.export("sample.glb", extension_webp=True)
```

- 網頁示範：`python app.py`（圖片生成 3D）、`python app_texturing.py`（PBR 貼圖生成）。
- 不支援 flash-attn 的 GPU（如 V100）可改裝 xformers，並設定 `ATTN_BACKEND=xformers`。
- 不想本機安裝可先用 Hugging Face Spaces 線上示範。

## 適用情境

- 從概念圖、產品照快速產出可用於遊戲引擎或 DCC 工具的 PBR 貼圖 GLB 資產。
- 需要開放曲面、非流形、半透明材質（衣物、植物、玻璃）的物件生成。
- 為既有白模生成 PBR 貼圖。
- 研究或在自有 3D 資料集上微調 3D 生成模型。

## 授權與成本

- **授權**：程式碼與模型權重皆為 MIT（Hugging Face 模型卡也標示 `mit`）。
- ⚠️ **相依套件限制**：README 特別提醒，渲染用的 [nvdiffrast](https://github.com/NVlabs/nvdiffrast) 與 PBR 分割和渲染器 [nvdiffrec](https://github.com/NVlabs/nvdiffrec) 採用各自的 NVIDIA 授權；查閱其 LICENSE.txt，兩者都限定「非商業（僅限研究或評估）」使用。商用前需確認你的流程是否用到這兩個套件（例如影片預覽渲染、`--nvdiffrast --nvdiffrec` 安裝選項），必要時改用替代方案。
- **成本**：免費；自行準備 24GB 以上顯存的 GPU。

## 限制與注意事項

- 「約 3 秒」只適用 512³ 且在 H100 上；高解析度要 17–60 秒，一般消費級 GPU 會更慢（實測數據資料不足）。
- 只測試過 Linux；Windows、macOS 支援資料不足。
- 至少 24GB 顯存，門檻高。
- 匯出的 GLB 預設為 `OPAQUE` 模式：貼圖保留了 alpha 通道但未啟用，需在 3D 軟體中手動把 alpha 接到材質的不透明度。
- 官方開源版只接受圖片輸入；文字生成 3D 需先用文生圖模型產圖。
- 安裝相依套件多、需編譯 CUDA 擴充，可能耗時且容易出錯。

## 相關工具

- [TRELLIS](https://github.com/microsoft/TRELLIS)（前代）、[FlexGEMM](https://github.com/JeffreyXiang/FlexGEMM)、[CuMesh](https://github.com/JeffreyXiang/CuMesh)
- 同資料夾：Hunyuan3D-2.1（同為開源圖片生成 PBR 3D 資產）、Stable Fast 3D（更輕量快速的單圖重建）、Meshy MCP Server（雲端 API 版）、Hyper3D（Rodin）

## 資料來源

- https://github.com/microsoft/TRELLIS.2 （README）
- https://api.github.com/repos/microsoft/TRELLIS.2 （repo 中繼資料：授權、星數、建立與推送日期）
- https://raw.githubusercontent.com/microsoft/TRELLIS.2/main/LICENSE
- https://huggingface.co/microsoft/TRELLIS.2-4B （模型卡授權標示）
- https://arxiv.org/abs/2512.14692 （論文摘要）
- https://github.com/NVlabs/nvdiffrast/blob/main/LICENSE.txt 、https://github.com/NVlabs/nvdiffrec/blob/main/LICENSE.txt （相依套件授權）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原始貼文）
