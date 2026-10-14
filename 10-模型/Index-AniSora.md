# Index-AniSora

- **分類**：模型 / 影片生成（動漫風格）
- **連結**：https://cnb.cool/dfdfsd/anisora （使用者提供，第三方鏡像）
- **官方 repo**：https://github.com/bilibili/Index-anisora
- **模型權重**：https://huggingface.co/IndexTeam/Index-anisora ・ https://www.modelscope.cn/organization/bilibili-index
- **論文**：https://arxiv.org/abs/2412.10255 （IJCAI'25）

## 原清單說明

（使用者提供連結，無附註說明）

> ⚠️ **查證結果**：使用者提供的 `cnb.cool/dfdfsd/anisora` 是騰訊 CNB 平台上的**第三方 fork**（從 `comfyui_goshaI/anisora` fork 而來，最新提交是「添加 GPU 環境依賴安裝腳本」）。內容是 bilibili 開源的 **Index-AniSora**，但只有 V1、V2 與 RL 相關資料夾，**沒有 V3（`anisoraV3`）**。官方 README 明言「這個 GitHub 專案是 AniSora 唯一的官方首頁」，建議以官方 repo 為準。

## 概述

Index-AniSora 是 bilibili 開源的動漫影片生成模型，可以一鍵產生各種動漫風格的鏡頭：番劇、國創動畫、漫改、VTuber、動畫 PV、鬼畜等。背後的論文〈AniSora: Exploring the Frontiers of Animation Video Generation in the Sora Era〉被 IJCAI'25 接受。

官方 repo 於 2024-12-16 建立，查詢當下（2026-10-14）約 2,500 顆星，最後一次推送是 2026-07-16。

## 版本與核心功能

- **AniSora V1**：以 CogVideoX-5B 為基底，支援圖生影片、插幀、局部與時間引導；附訓練程式碼（GPU 與華為昇騰 NPU）。
- **AniSora V2**：以 Wan2.1-14B 為基底，蒸餾加速推論；完整訓練／推論程式碼；原生支援華為昇騰 910B。2025-07 權重改為 Apache 2.0。
- **AniSora V3 系列**（2025-08 起，Apache 2.0）：
  - **角色 3D 影片**：給一張正面角色立繪，生成 360 度旋轉影片，幫助多角度一致或 3D 建模。
  - **任意幀推論**：指定首幀、中間幀或尾幀生成。
  - **影片風格轉換**：用首尾幀生圖加線稿引導，把原影片轉成任意風格。
  - **多模態引導**：姿態、深度、線稿、音訊控制動作。
  - **超低解析度超分**：從 90p 放大到 720p／1080p。
  - 官方稱 V3 可在 8 秒內生成 5 秒 360p 的鏡頭；V3.1 加大動作幅度，V3.2 改以 Wan2.2 訓練、推論步數可降到 8 步；另有可在 12GB 顯存跑的 V3.1 版本。
- **anisora-anymask**（2025-10）：用時間與空間 mask 控制的圖生影片。
- **周邊**：資料清洗流水線、動漫影片評測基準（948 段影片，需簽署申請）、RLHF 框架 AniSoraV1.0_RL，以及做長篇動畫的 agent 研究 AniMe（arXiv 2508.18781）。

## 安裝與使用方式

各版本放在不同資料夾，各有自己的 README 與環境需求（`anisoraV1_infer`、`anisoraV2_gpu`、`anisoraV2_npu`、`anisoraV3` 等）。一般流程：

1. clone 官方 repo（或鏡像），進入要用的版本資料夾。
2. 依該資料夾說明安裝相依套件。
3. 從 Hugging Face 或 ModelScope 下載對應版本的權重。
4. 執行推論腳本，輸入首幀圖片與提示詞。

各版本的確切指令與最低硬體需求請看資料夾內的 README；本條目未逐一查證，**資料不足**。

## 適用情境

- 從角色立繪或關鍵幀產生動漫風格的短鏡頭。
- 動畫前期製作：產生角色轉身影片、插幀、線稿上色風格轉換。
- 研究動漫影片生成、評測與 RLHF。
- 在華為昇騰 NPU 上訓練或推論影片模型。

## 授權與成本

- **授權**：官方 repo 為 Apache-2.0；V2、V3 權重也已改為 Apache 2.0。
- **成本**：開源權重可自行部署，需要 GPU；14B 等級的模型顯存需求較高，V3.1 另有 12GB 顯存版本。

## 限制與注意事項

- 使用者提供的 CNB 鏡像不含 V3，也不保證與官方同步；要用最新功能請改用官方 GitHub。
- 評測基準與生成結果需填表、手寫簽名並寄信申請，不是直接下載。
- 只生成單一鏡頭；要做完整動畫需要另外串分鏡、配音與剪輯（官方的 AniMe 研究在處理這件事）。
- 官方 repo 中繼資料沒有填描述，文件以 README 為主，部分說明只有中文。

## 相關工具

- [ViMax](../03-影片製作/ViMax.md)：多 agent 從點子做到成片，可接各種影片模型
- [PenShot](../03-影片製作/PenShot.md)：把劇本拆成影片模型用的分鏡提示詞（支援動漫劇本）
- [Qwen-Image-2.1](Qwen-Image-2.1.md)：生圖模型，可用來先做首幀
- CogVideoX、Wan2.1／Wan2.2（AniSora 的基底模型）

## 資料來源

- https://cnb.cool/dfdfsd/anisora （使用者提供的鏡像：fork 來源、資料夾結構、最新提交）
- https://github.com/bilibili/Index-anisora （官方 README：版本、功能、更新紀錄、授權）
- https://api.github.com/repos/bilibili/Index-anisora （repo 中繼資料：建立日期、星數、Apache-2.0、最後推送）
- https://arxiv.org/abs/2412.10255 （AniSora 論文）
