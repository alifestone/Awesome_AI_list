# Keshin2D

- **分類**：影片製作 / 虛擬主播 / 2D 虛擬形象（瀏覽器裡跑的 2D 角色 avatar，附「一張圖做出自己的模型」工具）
- **連結**：https://github.com/rotejin/Keshin2D
- **線上試玩**：https://rotejin.github.io/Keshin2D/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：日本開發者 rotejin 的開源專案，2026-11-25 發布 v0.1.0（首個公開版），MIT。README 以日文為主，另有英文版。檢視器只要 Python 標準函式庫與支援 WebGL2 的瀏覽器；做新角色的工具（partsgen）則需要 OpenAI Codex CLI 的影像生成與 Real-ESRGAN，作者只在 Windows 上驗證過。

## 概述

Keshin2D（化身 2D）把切成部件的角色插圖，用 WebGL2 做網格變形，每一幀畫出臉的轉向、視線、眨眼、表情、嘴型，以及頭髮與飾品的擺動，效果類似 Live2D 的 2D 虛擬形象，但不需要專用建模軟體。可以用滑鼠、網路攝影機或自動演出來驅動，也能透明背景輸出到 OBS 當直播／錄影用的 PNGTuber／VTuber 角色。

另一半是 `partsgen/`：從**一張角色圖**出發，讓 Codex CLI 的影像生成重畫各部件（基準圖、無頭髮圖、髮束、眼口差分表等 40～50 張），再用附帶的工具切圖、對位、做成「key shape」，輸出成模型。流程很長，設計成交給 AI coding agent（例如 Claude Code）照 `MASTER_PROMPT.md` 執行，人只在三個點確認。

## 核心功能／特色

- **三種驅動方式**：滑鼠（看向游標）、網路攝影機（MediaPipe 臉部追蹤，已內附，可離線）、自動（約 14 秒的獨角戲循環）
- **22 種表情**，數字鍵 1～8 快速切換常用表情
- **麥克風對嘴**：依音量與母音（あいうえお）改變嘴型，可「讓它記住你的聲音」校正
- **頭髮與飾品擺動**：每束頭髮、緞帶、耳環、呆毛等，強度可個別調整
- **OBS 輸出**：一鍵複製含目前配置與調整值的 URL，貼到 OBS 瀏覽器來源；`?ui=0&bg=transparent` 隱藏面板、透明背景
- **URL 參數**：可指定模型、背景、驅動方式、表情、固定角度（yaw/pitch/roll）、位置與縮放
- **隱私**：攝影機與麥克風只在瀏覽器內處理，不錄製也不上傳；檢視器不對外連線
- **一張圖做新角色**：partsgen 的指令文、完整流程文件（階段 0～8）、品質基準與除錯知識庫，以及自動驗證工具（40 項 UI 自動檢查、固定姿勢截圖比對、錄影、擺動次數計算）

## 技術架構或運作原理

- `index.html`＋`js/avatar.js`：檢視器與引擎，部件 PNG 在 WebGL2 上做網格變形
- `js/keyshape.js`：眼睛和嘴巴用「畫好的 key 形狀」變形驅動
- `js/lipsync.js`：麥克風對嘴（音量與母音判斷）
- `vendor/mediapipe/`：MediaPipe Tasks Vision 0.10.14 與 Face Landmarker 模型
- 模型格式：`models/<名稱>/model.json`＋`parts/*.png`
- `tools/serve.py`：只用 Python 標準函式庫的本機伺服器（預設 port 8770）；也可直接放到 GitHub Pages 這類靜態主機
- `partsgen/tools/pipeline.py`：呼叫 `codex exec` 生圖、Real-ESRGAN 放大 3 倍、OpenCV 切圖對位、輸出模型；用 Node.js 驅動 headless Chrome 截圖驗證

## 安裝與使用方式

### 跑內附的模型

需要 Python 3.8+ 與 Chrome／Edge（WebGL2）。

```bash
git clone https://github.com/rotejin/Keshin2D
cd Keshin2D
./start.sh                 # Windows 用 start.bat；或 python tools/serve.py
./start.sh --model chiwa   # 一開始就用另一個角色
```

不能直接雙擊 `index.html`（瀏覽器會擋本機檔案讀取）。內附兩個角色：水母妹（`kurage02`）與吉娃娃妹（`chiwa`，從一張圖完整走過 partsgen 流程做出來的）。

OBS 最短 URL：

```text
http://127.0.0.1:8770/index.html?model=kurage02&ui=0&bg=transparent
```

### 做自己的角色

另需 Python 3.10+（numpy、opencv-python、pillow）、Node.js 22+、可生圖的 Codex CLI（需 OpenAI 訂閱，依張數計費）、Real-ESRGAN（需支援 Vulkan 的 GPU，有指令自動下載）、AI coding agent。

```bash
python3 -m venv .venv
./.venv/bin/python -m pip install -r tools/requirements.txt
./.venv/bin/python -I partsgen/tools/pipeline.py install-upscaler
./.venv/bin/python -I partsgen/tools/pipeline.py check
```

`check` 全部 ok 後，在 repo 根目錄開 agent，貼上 `partsgen/MASTER_PROMPT.md` 的指令文，只改「圖檔位置」與「角色名稱（英數字）」兩行。agent 會在三處停下來讓你確認：基準圖像不像該角色、髮型設計案、實際動起來的手感。完成的模型放在 `models/<名稱>/`。

## 適用情境

- 想要一個免安裝、離線可用的 2D 虛擬形象做直播或錄影，不想學 Live2D Cubism
- 手上有一張原創角色圖，想讓 AI agent 幫忙拆成可動的模型
- 研究 WebGL2 網格變形、key shape 表情、瀏覽器內臉部追蹤與對嘴的實作
- 參考「把長流程交給 coding agent、人只在關鍵點把關」的 agent 工作流設計

## 授權與成本

- **授權**：MIT（程式與兩個內附模型皆是）。第三方元件見 `THIRD_PARTY_NOTICES.md`。
- **成本**：檢視器免費。做新角色需要 OpenAI 訂閱（Codex 依生圖張數計用量）與 GPU。

## 限制與注意事項

- 檢視器只在 Windows 實機驗證；macOS／Linux 只在 GitHub Actions（headless Chrome、無 GPU）跑過啟動與畫面測試，Firefox、Safari 未驗證
- partsgen 只在 Windows 驗證；作者寫明 2026 年 11 月時只有 **Windows Codex 應用程式內附的 `codex.exe`** 能生圖，npm 版與 `~/.local/bin` 版不行，macOS／Linux 能否生圖未確認
- 作者明說還沒驗證「一條指令就能穩定做出同樣品質」：目前每個角色都是邊做邊修工具與流程文件，修好後的流程還沒從頭重跑過新角色；生成結果每次不同
- 一個角色的工作資料夾會有數百 MB 到數 GB
- **在 OBS 上的運作尚未驗證**（含滑鼠、攝影機、麥克風能否在 OBS 瀏覽器來源裡用）；不行時可用綠幕背景加視窗擷取
- 攝影機追蹤與麥克風對嘴只用測試影音驗證過，真人臉與聲音的準度還沒充分確認
- 內附角色有已知的大角度變形瑕疵
- 介面與文件以日文為主；Linux 沒裝日文字型時面板文字會變方塊
- 餵給 partsgen 的圖必須是你有權使用的圖

## 相關工具

- [AIモデル顔データベース](./AI-Model-Face-Database.md)：AI 生成的虛構人像參考圖庫，用於生圖／影片保持角色一致
- [AutoMV](./AutoMV.md)：AI 生成畫面與對嘴的 MV 製作，偏離線成片；Keshin2D 是即時驅動的角色

## 資料來源

- https://github.com/rotejin/Keshin2D
- https://github.com/rotejin/Keshin2D/blob/main/partsgen/README.md
- https://github.com/rotejin/Keshin2D/blob/main/CHANGELOG.md
