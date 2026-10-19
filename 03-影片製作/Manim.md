# Manim

- **分類**：影片製作 / 程式化影片（程式碼 → 影片）
- **連結**：https://github.com/3b1b/manim
- **文件**：https://3b1b.github.io/manim/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Animation engine for explanatory math videos.* 這是 3Blue1Brown 作者 Grant Sanderson 自用的版本，現稱 **ManimGL**，PyPI 套件名是 `manimgl`（不是 `manim`）。另有 2020 年 fork 出去的社群版 [Manim Community](https://github.com/ManimCommunity/manim)（PyPI 名 `manim`），兩者語法相近但不相容，安裝說明也不能混用。本身不是 AI 工具。授權為 MIT。

## 概述

Manim 是用 Python 寫精準數學動畫的引擎，3Blue1Brown 頻道的影片都是用它做的。你用程式碼描述場景裡的物件（公式、座標軸、圖形、文字）和它們怎麼變化，Manim 再即時預覽或渲染成影片。因為每一幀都由程式決定，很適合 coding agent 產生和修改。

repo 於 2015-03-22 建立，查詢當下（2026-10-19）約 95,300 顆星，最後一次 push 為 2026-09-09；最新 release 是 v1.7.2（2024-12-13）。社群版查詢當下約 41,700 顆星。

## 核心功能／特色

- **程式化動畫**：用 Python 類別定義 `Scene`，以 `self.play(...)` 串接變形、移動、淡入、繪製等動畫。
- **數學排版**：以 LaTeX 渲染公式，可以逐字元做公式變形動畫。
- **OpenGL 即時預覽**：ManimGL 用 OpenGL 渲染，執行時直接跳出視窗播放，可互動式調整場景。
- **CLI 旗標**：`-w` 寫成影片檔、`-o` 寫檔並開啟、`-s` 只看最後一幀、`-n <number>` 跳到第 n 個動畫、`-f` 全螢幕。
- **可自訂設定**：用 `custom_config.yml` 指定輸出位置、素材路徑、畫質與預設樣式。
- **完整範例**：[3b1b/videos](https://github.com/3b1b/videos) 公開了 3Blue1Brown 所有影片的原始碼（舊影片的程式碼不一定能在新版跑）。

## 安裝與使用方式

需要 Python 3.10 以上、FFmpeg、OpenGL；要排公式還需要 LaTeX；Linux 另需 Pango 開發標頭。

```bash
pip install manimgl

# 或從原始碼安裝（要改 manimlib 本身時）
git clone https://github.com/3b1b/manim.git
cd manim
pip install -e .

# 跑範例場景，會跳出視窗播放
manimgl example_scenes.py OpeningManimExample
# 寫成影片檔
manimgl example_scenes.py OpeningManimExample -w
```

- macOS 可用 `brew install ffmpeg mactex`；MacTeX 約 6 GB，可改裝較小的 BasicTeX 再補需要的套件。
- Windows 建議用 MiKTeX 當 LaTeX。

## 適用情境

- 數學、物理、演算法、機器學習的解說影片。
- 課程教材、論文或技術簡報裡的動畫。
- 讓 coding agent 依文字描述寫出可重跑、可修改的教學動畫。

## 授權與成本

- **授權**：MIT。
- **成本**：免費、在本機執行；只需要一般電腦，不需要 GPU 或 API。

## 限制與注意事項

- 有兩個版本：ManimGL（本 repo）和社群版 Manim CE。網路上的教學、AI 生成的程式碼常混用兩者語法，照著跑容易出錯，先決定要用哪一版。
- README 說社群版更穩定、測試更完整、對新手更友善，社群貢獻也較活躍；本 repo 主要跟著 3Blue1Brown 的需求演進。
- LaTeX、Pango、OpenGL 等系統相依套件在部分環境不好裝，是最常見的安裝問題。
- 官方文件仍在撰寫中；另有 manim-kindergarten 維護的[中文文件](https://docs.manim.org.cn/)。

## 相關工具

- [Manim Community](https://github.com/ManimCommunity/manim)：社群版，較適合新手與正式專案
- [3b1b/videos](https://github.com/3b1b/videos)：3Blue1Brown 影片原始碼
- [Remotion](Remotion.md)、[HyperFrames](HyperFrames.md)：用 React 或 HTML 寫影片的程式化影片框架

## 資料來源

- https://github.com/3b1b/manim （README）
- https://api.github.com/repos/3b1b/manim （星數、MIT、建立時間、最後 push）
- https://api.github.com/repos/3b1b/manim/releases/latest （v1.7.2，2024-12-13）
- https://api.github.com/repos/ManimCommunity/manim （社群版星數）
