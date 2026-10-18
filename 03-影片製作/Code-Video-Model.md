# Code Video Model

- **分類**：影片製作 / AI 影片生成
- **連結**：https://code-video-model.github.io/
- **程式碼**：https://github.com/code-video-model/CodeVideoModel

## 原清單說明

（使用者新增，無原清單說明。）以可編輯程式碼作為影片生成的「條件」，讓場景佈局、運動、時間、鏡位與物理都能用程式修改。

## 概述

Code Video Model（團隊署名 Code Video Model Team，2026 preprint）讓 coding agent 把文字提示寫成 Three.js 場景程式，渲染成「代理影片（proxy video）」，再搭配參考圖與提示交給影片生成模型產出最終影片。因為場景是程式碼，要改鏡位、動作、時間或物理，只要改程式再重跑。作者：Zhiyang Liang、Jiawei Zhang、Guocheng Qian、Dongdong Chen、Ziyu Wan（專案頁顯示 Microsoft 關聯）。

## 核心功能／特色

- **文字 → Three.js 場景**：模型建立場景並經視覺檢查迭代修正。
- **early-step conditioning**：免訓練的做法，只在取樣早期步驟使用代理影片、之後放開，使輸出保有代理影片的結構、外觀則取自參考圖（避免影片模型直接複製代理影片平面化的外觀）。
- **兩種參考圖模式**：嚴格對齊、文字引導。
- **瀏覽器檢視器**：時間軸拖曳、逐格、原始碼瀏覽、軌道／平移／縮放相機。
- **成對生成**：可編輯既有場景。
- **CodeVideoBench**：22 個案例、8 種應用，附可編輯程式、代理影片、參考圖與提示，資料集在 Hugging Face。
- **自動評測**：以 Qwen3.8-27B（經 OpenRouter）評結構、風格、品質。

## 技術架構或運作原理

1. GPT-6 由文字產生 Three.js 程式碼並視覺審查。
2. 渲染成代理影片。
3. 取第一格，用 GPT-Image-2 產生 1536×864 參考圖。
4. 以 MiniMax-H3 依代理影片、參考圖與提示生成最終影片。

## 安裝與使用方式

- 建議 Ubuntu 22.04、相容 CUDA 12.6 的 NVIDIA 驅動；conda（Python 3.10）、ffmpeg ≥ 6、PyTorch 2.7.1（cu126）、`requirements.txt`、Playwright Chromium。
- 執行 `download_h3.py` 從 Hugging Face（MiniMaxAI/MiniMax-H3）取得權重。
- 需設定 `OPENROUTER_API_KEY`（GPT-Image-2 與評測），Three.js 階段另依賴 GPT-6。
- 內附 4 個範例（`sports_car`、`tank_boarding`、`loft_tour`、`robot_navigation`），可由 `inference.generate_video` 快速試跑。

## 適用情境

- 需要精準控制鏡頭、動作、物理的影片生成。
- 研究「程式碼作為影片條件」、代理影片條件化方法。
- 可編輯的 3D 場景到寫實影片的流程。

## 授權與成本

- **授權**：程式碼 Apache-2.0；範例 CC BY 4.0。
- **成本**：程式碼免費，但需 GPU 與多個外部模型／API（GPT-6、GPT-Image-2、OpenRouter、MiniMax-H3），費用自付。

## 限制與注意事項

- 為 preprint；repo 僅約 6 個 commit，無正式 release。
- 流程依賴多個外部模型與 API 金鑰，特定 Linux／CUDA 環境。
- 專案頁未列限制章節；本條目未獨立驗證其生成品質（專案頁當時無法由本環境直接開啟，內容取自 GitHub README 與搜尋摘要）。
- 查詢時 repo 約 529 星、22 forks。

## 相關工具

- [OpenMontage](OpenMontage.md)：agent 驅動的完整影片製作
- [Remotion](Remotion.md)：以程式碼（React）寫影片
- [Index-AniSora](../10-模型/Index-AniSora.md)：開源影片生成模型

## 資料來源

- https://code-video-model.github.io/ （專案頁，搜尋摘要）
- https://github.com/code-video-model/CodeVideoModel （README）
- https://x.com/guocheng_qian/status/2109445639323140401 （發表貼文）
