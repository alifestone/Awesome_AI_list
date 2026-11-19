# MeshAnything

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/buaacyw/MeshAnything （V2：https://github.com/buaacyw/MeshAnythingV2 ；專案頁：https://buaacyw.github.io/mesh-anything/ ；論文：https://arxiv.org/abs/2406.10163 ；權重：https://huggingface.co/Yiwen-ntu/MeshAnything ；線上試用：https://huggingface.co/spaces/Yiwen-ntu/MeshAnything ）

## 原清單說明

把任何 3D 表示轉成「像美術師手做的」網格：ICLR 2025 論文〈MeshAnything: Artist-Created Mesh Generation with Autoregressive Transformers〉的官方實作。（來源：使用者提供的 GitHub repo）

> **查證補充**：正確。要注意它**不是**從文字或圖片直接生成 3D，而是把已有的稠密網格或點雲（掃描、重建、其他生成模型的輸出）轉成低面數、拓撲乾淨的網格，相當於 AI 自動重新拓撲。V1 最多 800 面，V2 提高到 1,600 面。⚠️ 授權為 S-Lab License 1.0，只允許非商業使用。

## 概述

MeshAnything 由 Yiwen Chen（南洋理工 S-Lab，於上海 AI Lab 實習期間完成）等人提出。一般 3D 生成或重建得到的網格多半由 Marching Cubes 產生，面數龐大、三角形雜亂，美術難以修改或做動畫。MeshAnything 用自迴歸 Transformer 依序「一個面一個面」地生成網格，產出接近人工建模、面數少、布線有結構的 Artist-Created Mesh（AM）。

後續版本 **MeshAnything V2**（ICCV 2025）提出 Adjacent Mesh Tokenization（相鄰網格 token 化），讓序列長度約減半，最大面數提高到 1,600，效果也更好，並釋出訓練程式碼。

截至 2026-11-20：V1 約 2,300 顆星、V2 約 1,050 顆星；兩個 repo 最後推送都是 2025-04-28，已不太更新。

## 核心功能／特色

- **網格 → 美術網格**：輸入任何網格（OBJ 等），重新生成低面數、拓撲乾淨的版本。
- **點雲 → 美術網格**：輸入含法向量的點雲（`.npy`，形狀 (N, 6)：前 3 欄座標、後 3 欄法向量）。
- **Marching Cubes 前處理**：`--mc` 先做 Marching Cubes，讓輸入更接近訓練資料分布；V2 建議非 Marching Cubes 產出的網格都加上。
- **可串接其他生成器**：V2 README 建議先用 Rodin 等工具把文字／圖片轉成稠密網格，再交給 MeshAnything 轉成美術網格。
- **Gradio 本機示範**與 Hugging Face Space 線上試用。

## 技術架構或運作原理

- 先把輸入網格或點雲轉成形狀條件（點雲編碼器，參考 Michelangelo），再由只解碼器的自迴歸 Transformer（基於 MeshGPT／meshgpt-pytorch 思路）逐一生成面的 token，最後還原成網格。
- V1 公開權重為 350M 參數版本（`MeshAnything_350m.pth`）。
- V2 的 Adjacent Mesh Tokenization：相鄰的面盡量只用一個新頂點表示，而不是每個面三個頂點，序列更短、訓練與生成更有效率。
- 訓練資料限制在 800 面以下（V1），所以無法生成更多面數的網格。

## 安裝與使用方式

官方測試環境：Ubuntu 22、CUDA 11.8、A100／A800／A6000。

```bash
git clone https://github.com/buaacyw/MeshAnything.git && cd MeshAnything
conda create -n MeshAnything python==3.10.13 -y
conda activate MeshAnything
pip install torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu118
pip install -r requirements.txt
pip install flash-attn --no-build-isolation

# 本機 Gradio 示範
python app.py

# 網格輸入（資料夾或單檔），加 --mc 先做 Marching Cubes
python main.py --input_dir examples --out_dir mesh_output --input_type mesh --mc
python main.py --input_path examples/wand.obj --out_dir mesh_output --input_type mesh

# 點雲輸入（需含法向量）
python main.py --input_path pc_examples/mouse.npy --out_dir pc_output --input_type pc_normal
```

- 也可以 `pip install git+https://github.com/buaacyw/MeshAnything.git` 後在程式中 `import MeshAnything`。
- 想要更多面數或要訓練，改用 MeshAnythingV2（安裝方式相同，另有 `training_requirement.txt`）。

## 適用情境

- 把掃描、照片重建、SDS 類生成的稠密網格，轉成遊戲或動畫可用的低面數網格。
- 替 TRELLIS.2、Hunyuan3D 等生成模型的輸出做自動重新拓撲（但見下方對輸入品質的限制）。
- 研究自迴歸網格生成、網格 token 化方法。

## 授權與成本

- ⚠️ **S-Lab License 1.0**（V1、V2 皆是）：只允許非商業用途的再散布與使用，商用須另洽。
- 免費自行執行；生成一個網格在 A6000 上約 7 GB 顯存、約 30 秒。

## 限制與注意事項

- 面數上限：V1 800 面、V2 1,600 面，只適合簡單到中等複雜的物件；細節多的模型會被大幅簡化。
- 輸入形狀要夠「銳利」：官方提醒前饋式 3D 生成模型的輸出常因形狀品質不足而效果差，建議用 3D 重建、掃描或 SDS 方法（如 DreamCraft3D）的結果當輸入。
- 輸入會被正規化到單位包圍盒；向上方向應為 +Y。
- 相依版本較舊（PyTorch 2.1.1、CUDA 11.8），在新 GPU（如 RTX 50 系列）上可能需要自行調整環境，官方未說明。
- 輸出沒有 UV、貼圖或材質，只有幾何。
- repo 自 2025-04 後幾乎沒有更新。

## 相關工具

- [MeshAnythingV2](https://github.com/buaacyw/MeshAnythingV2)、[MeshGPT](https://nihalsid.github.io/mesh-gpt/)、[meshgpt-pytorch](https://github.com/lucidrains/meshgpt-pytorch)、[Michelangelo](https://github.com/NeuralCarver/Michelangelo)
- 同資料夾：[Hyper3D（Rodin）](Hyper3D（Rodin）.md)（V2 建議的前端生成器）、[TRELLIS.2](TRELLIS.2.md)、[Hunyuan3D 2.1](Hunyuan3D-2.1.md)、[Stable Fast 3D](Stable-Fast-3D.md)（可內建重新網格化）、[Meshy MCP Server](Meshy-MCP-Server.md)（雲端 Smart Topology／重新網格化）

## 資料來源

- https://github.com/buaacyw/MeshAnything （README、LICENSE.txt）
- https://github.com/buaacyw/MeshAnythingV2 （README、LICENSE.txt）
- https://api.github.com/repos/buaacyw/MeshAnything 、https://api.github.com/repos/buaacyw/MeshAnythingV2 （星數、推送日期）
- https://huggingface.co/Yiwen-ntu/MeshAnything （權重檔）
- https://arxiv.org/abs/2406.10163 （論文）
