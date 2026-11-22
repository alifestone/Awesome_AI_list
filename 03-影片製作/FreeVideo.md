# FreeVideo

- **分類**：影片製作 / AI 影片生成
- **連結**：https://github.com/FlashML-org/FreeVideo
- **社群作品集**：https://freevideo-community.pages.dev/#gallery
- **教學文章**：https://www.aiposthub.com/freevideo-local-video-8gb-hardware/

## 概述

FreeVideo 是 FlashML-org 開源的 MiniMax H3 本機推論引擎，主打「用你已經有的電腦做影片」：最低 **8 GB VRAM＋16 GB 系統記憶體** 就能跑 MiniMax H3 影片模型。它底層用的不是 MiniMax 原版權重，而是 OpenVDN 以 Video DeltaNet（VDN）混合注意力改寫、蒸餾成 8 步的 [VDN-H3](https://huggingface.co/OpenVDN/vdn-minimax-h3)（論文 arXiv 2609.20744）。

形式上是一個 **ComfyUI 外掛**，外加 Windows／macOS／Linux 啟動器：啟動器會幫你裝好 ComfyUI、執行環境與模型，打開瀏覽器就是 FreeVideo 自己的創作介面；要細調時可切回 ComfyUI 節點圖加 LoRA 或改 workflow。

repo 於 2026-09-13 建立、10-02 正式開源；查證時（2026-11-22）約 4,200 星，最新 release 為 v0.6.7（2026-11-21），更新非常頻繁。

## 核心功能／特色

- **依硬體自動規劃執行**：每次生成前量測可用 VRAM、系統記憶體與磁碟，決定 50 個 transformer block 放在 VRAM／鎖頁記憶體／磁碟的配置、權重格式（GeForce 與 RTX 30 系列用 int8，工作站與資料中心卡用 FP8）與注意力 kernel（依序嘗試 SageAttention 2、PyTorch flash、cuDNN、FlashAttention 2／4）。
- **低記憶體推論**：權重串流、非同步預取、分塊計算；顯存不足（OOM）時會在新程序內自動減輕配置重試，最多兩次。`freevideo plan --vram-gib 8 --ram-gib 16` 可在不載入權重的情況下印出某規格的執行計畫。
- **多模態輸入**：文字、首尾幀，以及圖片、影片、音訊參考。
- **四種品質等級**：Light／Medium／High／Max，越高越慢；可先出半解析度預覽，滿意再跑完整解析度（兩段式取樣）。
- **長影片與剪輯**（v0.4.0 起）：時間軸剪輯介面（文字、字幕、變速、倒放），可一段接一段生成超過一分鐘的影片；可放大合併後的影片，匯出時可選無損音訊 .mov（v0.6.7）。
- **AI agent 連接**（v0.4.0 起）：讓 Claude Code、Codex 等 agent 自行生成、剪輯、匯出影片。
- **其他**：社群 MiniMax H3 LoRA、批次生成與歷史紀錄、生成的影片內嵌 workflow（拖回 ComfyUI 即還原 prompt／seed／設定）、區網存取；v0.5.0 起也能跑 H3 Image 生圖（最高 16 MP），v0.6.x 另支援 Qwen-Image、MOSS-Image。

## 安裝與使用方式

**桌面啟動器**（Windows 10／11＋NVIDIA、Linux x86_64＋NVIDIA、macOS 14+ Apple Silicon）：從 [Releases](https://github.com/FlashML-org/FreeVideo/releases/latest) 下載 `FreeVideo.exe`／`FreeVideo-Mac-arm64.dmg`／`FreeVideo-Linux-x86_64.AppImage` → 選既有 ComfyUI 資料夾或新裝一個（可加入既有模型資料夾重用）→ 按 **Install & launch**，缺的模型會自動下載。

```bash
# 已有 ComfyUI：裝成 custom node
cd ComfyUI/custom_nodes
git clone https://github.com/FlashML-org/FreeVideo.git
# 重啟 ComfyUI → Workflow → Browse Templates → FreeVideo → FreeVideo-All-in-One

# Linux 終端機／伺服器
git clone https://github.com/FlashML-org/FreeVideo.git && cd FreeVideo
./setup.sh
freevideo                            # 之後再次開啟
freevideo server --listen 0.0.0.0    # 在區網提供存取連結
```

- 首次啟動要下載環境與模型，需要時間與大量磁碟空間；有離線安裝包（夸克網盤、ModelScope），完整離線需 4 個模型包＋環境包。
- Windows 的 exe 有程式碼簽章；若被防毒擋下，先比對 release 頁面的 SHA-256 再加入排除清單。
- Mac 需先裝 Xcode Command Line Tools；預覽版尚未經 Apple 公證，首次開啟要用 `shasum -a 256` 比對 `SHA256SUMS.txt`，再到「隱私權與安全性」按「強制打開」（只放行 FreeVideo，不必關閉 Gatekeeper）。

## Mac 生成時間（官方數據）

M5、24 GB 統一記憶體（約 14 GB 可用）、Light 等級：

| 解析度 | 長度 | 時間 |
|---|---|---|
| 1344 × 768 | 10 秒 | 約 42 分鐘 |
| 960 × 544 | 10 秒 | 約 22 分鐘 |
| 512 × 512 | 1.6 秒 | 約 3 分鐘 |

M5 用 Metal 4 tensor 單元跑 int8；M5 之前的 Mac 改以 BF16 計算，會更慢。Mac 版只支援文字、首幀與兩段式取樣，功能範圍比 NVIDIA 版窄。

## 教學文章重點

aiposthub 的文章整理了官方規格、平台差異與授權條件，重點如下：

- 作者**沒有實際安裝或生成測試**，內容是轉述官方條件；生成時間也是引用官方 Mac 數據。
- 最低規格只代表「能跑」，不保證速度或長影片穩定；結果依硬體、解析度、長度與品質等級而異。
- Windows 示範不能直接套到 Mac；Mac 版要自行驗證來源與 checksum，不要為了打開而關閉系統安全機制。
- 模型授權與軟體授權分開看（見下）。文章提到的 X 貼文介紹的是較舊的 v0.5.0。
- 文章寫查詢時 4,127 星；本條目查證時約 4,200 星。文章沒提到底層是 OpenVDN 的 VDN-H3 蒸餾模型。

## 適用情境

- 只有 8～16 GB 顯卡的家用電腦，想在本機跑 MiniMax H3 做文生影片、首尾幀影片。
- 已經在用 ComfyUI，想要一個不用自己接節點、但仍可切回節點圖細調的 H3 工作區。
- 讓 Claude Code 等 agent 在本機生成並剪輯影片。
- 有 Apple Silicon Mac、能接受較慢速度的嘗鮮使用。

## 授權與成本

- **程式碼**：Apache-2.0，免費。
- **模型權重**：MiniMax H3 Community License（另有使用規範）：
  - **地區限制**：不適用於歐盟、英國、南韓與美國，在這些地區不得使用、散布模型**或其產出**（台灣不在排除名單）。
  - 商業產品／服務年營收超過 **US$2,000 萬** 須先取得 MiniMax 書面授權。
  - 再散布需符合標示等條件；另受 Acceptable Use Policy 約束。
- **成本**：本機執行免費；需自備硬體與電費。

## 限制與注意事項

- 需要 NVIDIA GPU（Windows／Linux）或 Apple Silicon（實驗性）；README 沒提 AMD 支援。
- 8 GB VRAM 時大部分權重要在每一步從系統記憶體甚至磁碟搬到 GPU，速度明顯較慢；PCIe、SSD 與系統記憶體都會影響。
- Mac 版為實驗性預覽、未公證、功能較少、生成很慢（10 秒影片約 22～42 分鐘）。
- 更新節奏極快（不到三個月從 v0.1 到 v0.6.7），介面與功能常變。
- 模型授權的地區限制連「產出」都涵蓋，位於排除地區或服務排除地區客戶時要特別注意。

## 相關工具

- [WanGP](WanGP.md)：同樣主打低階顯卡的本機生成 App，也支援 MiniMax H3，另含 Wan、LTX、Hunyuan Video 等多種模型與 MCP server。
- [MiniMax-H3-Image](../10-模型/MiniMax-H3-Image.md)：MiniMax H3 系列的文生圖模型。
- [OpenMontage](OpenMontage.md)：可接本地 ComfyUI 的 agent 影片製作系統。

## 資料來源

- https://github.com/FlashML-org/FreeVideo（README、docs/Mac.md、docs/execution-planning.md、releases v0.4.0／v0.6.7、repo 資訊）
- https://huggingface.co/OpenVDN/vdn-minimax-h3-edge/raw/main/LICENSE
- https://www.aiposthub.com/freevideo-local-video-8gb-hardware/
