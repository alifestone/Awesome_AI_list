# MoviePy

- **分類**：影片製作 / 程式化影片（程式碼 → 影片）
- **連結**：https://github.com/Zulko/moviepy
- **文件**：https://zulko.github.io/moviepy/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Video editing with Python*。這是用 Python 寫程式剪輯影片的函式庫，原作者為 Zulko，授權為 MIT。本身不是 AI 工具。2.0 版有大幅度不相容的 API 變更，舊版（v1）的教學與程式碼多半不能直接跑。

## 概述

MoviePy 是 Python 的影片剪輯函式庫，能做剪裁、串接、插入標題、多段影片疊合（非線性剪輯）、影片處理與自訂特效。它把影片影格、圖片與聲音讀成 numpy 陣列，所以每個像素都能用程式處理，再編碼回 MP4、WebM、GIF 等格式。底層靠 FFmpeg 讀寫影片。

README 自己也說明代價：因為要把資料搬進搬出 Python，速度比直接用 ffmpeg 慢。

repo 於 2013-08-12 建立，查詢當下（2026-11-06）約 15,100 顆星，最後一次 push 為 2026-08-26；PyPI 與 GitHub 上最新 release 都是 v2.2.1（2025-05-21）。

## 核心功能／特色

- **基本剪輯**：`VideoFileClip` 載入影片、`subclipped()` 取片段、串接多段影片、調整音量。
- **合成**：`CompositeVideoClip` 把多個片段並排或疊在一起，支援透明度；`TextClip` 做標題與字幕。
- **逐像素處理**：影格是 numpy 陣列，可以用幾行程式寫出自訂特效，或完全由程式生成畫面。
- **內建特效**：以 `with_effects()` 套用，特效在 2.0 後都是類別（`Effect`）。
- **格式支援**：讀寫常見影音格式，包括 GIF；跨 Windows、macOS、Linux。
- **預覽**：需要 `ffplay`（通常和 ffmpeg 一起安裝）。

最小範例（取自 README）：

```python
from moviepy import VideoFileClip, TextClip, CompositeVideoClip

clip = (
    VideoFileClip("example.mp4")
    .subclipped(10, 20)          # 取 10–20 秒
    .with_volume_scaled(0.8)     # 音量降到 80%
)

txt_clip = TextClip(
    font="Arial.ttf", text="Hello there!", font_size=70, color="white"
).with_duration(10).with_position("center")

CompositeVideoClip([clip, txt_clip]).write_videofile("result.mp4")
```

## 安裝與使用方式

```bash
pip install moviepy
```

- README 標示支援 Python 3.9 以上。
- FFmpeg 通常不用另外裝：依官方文件，imageio 會在第一次使用時自動下載。要用自己的版本，可設環境變數 `FFMPEG_BINARY`、`FFPLAY_BINARY`（也可寫在工作目錄的 `.env`）。
- 只有要預覽時才需要另外確認 `ffplay` 可用。
- 要改原始碼：`git clone` 後 `pip install -e .`。
- 官方文件有「10 分鐘做出 Big Buck Bunny 預告片」的教學與 Docker 說明。

## 適用情境

- 用 Python 腳本批次處理影片：裁切、串接、加標題與字幕、轉 GIF。
- 讓 coding agent 寫可重跑、可修改的剪輯腳本，而不是手拼 ffmpeg 指令。
- 需要逐像素或逐影格自訂處理的特效與程式化生成畫面。
- 與 TTS、圖片生成等 Python 流程串接，作為最後的合成步驟（不少自動化短影音專案都這樣用）。

## 授權與成本

- **授權**：MIT。
- **成本**：免費、在本機執行，不需要 GPU 或 API。

## 限制與注意事項

- **v1 與 v2 不相容**：2.0 取消 `moviepy.editor`，改成 `from moviepy import ...`；原本的 `.set_*` 改成 `.with_*`，`resize`／`crop`／`rotate` 改成 `resized`／`cropped`／`rotated`；特效從函式變成類別，用 `with_effects()` 套用。網路上的舊教學與 AI 生成的程式碼常用 v1 語法，要先確認版本。
- **2.0 移除的功能**：`video.tools.tracking`、`video.tools.segmenting`、`video.io.sliders`，以及對 ImageMagick、PyGame、OpenCV、scipy 等的依賴；用到的話要自己補。
- **字型**：2.0 的 `TextClip` 需要在建立時給字型檔路徑。
- **速度**：資料要經過 numpy，處理大量或高解析度影片會比直接用 ffmpeg 慢。
- **依賴上限**：PyPI 中繼資料限制 `pillow<12.0`、`imageio<3.0`，與其他套件同環境時可能出現版本衝突。
- 官方文件對 Python 版本的說法不一致（升級指南提到 3.7+，README 標 3.9+）；以 README 為準。

## 相關工具

- [ffmpeg-skill](ffmpeg-skill.md)：給 coding agent 的本地 FFmpeg 剪輯 skill，速度較快，但不是在 Python 裡逐像素處理
- [Manim](Manim.md)：同樣是 Python 寫影片，但專攻數學動畫
- [Remotion](Remotion.md)、[HyperFrames](HyperFrames.md)：用 React 或 HTML 寫影片
- [MoneyPrinterTurbo](MoneyPrinterTurbo.md)：全自動短影音生成器，屬於同一類「用程式組裝影片」的上層應用

## 資料來源

- https://github.com/Zulko/moviepy （README）
- https://api.github.com/repos/Zulko/moviepy （星數、MIT、建立時間、最後 push）
- https://api.github.com/repos/Zulko/moviepy/releases/latest （v2.2.1，2025-05-21）
- https://pypi.org/pypi/moviepy/json （v2.2.1、依賴與版本上限）
- https://zulko.github.io/moviepy/getting_started/install.html （安裝與環境變數）
- https://zulko.github.io/moviepy/getting_started/updating_to_v2.html （v1 → v2 變更）
