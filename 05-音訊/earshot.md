# earshot

- **分類**：音訊 / 給 coding agent 的聽覺與音效工具
- **連結**：https://github.com/Leonxlnx/earshot

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Ears for coding agents: let AI hear, review and make sound. CPU-only, open source.* 作者是 Leon Lin（Leonxlnx），也是本清單 [Cinetic](../03-影片製作/Cinetic.md) 的作者，Cinetic 已整合 earshot 做音效。README 與 `pyproject.toml` 寫的是 0.3.0，但 GitHub 上最新的 release 只到 v0.2.0（2026-10-16），0.3 的功能（音效庫、`sfx`、`kit`）要從原始碼安裝才有。專案標示為 Alpha。授權為 MIT。

## 概述

earshot 讓 coding agent「聽得到」聲音。agent 已經能寫程式渲染影片、產品 demo 或遊戲，卻聽不出按鍵聲是高級還是廉價、打擊聲是不是比畫面切換晚了 80 ms。earshot 把聲音轉成 agent 能推理的文字與數字：這個檔案聽起來像什麼、和一段描述有多吻合、長錄音裡哪一段最好、是真實錄音還是程式合成的、整支影片逐秒的聆聽紀錄，以及對照專業發表片的評分表。

它也能讓 agent **用程式碼做音效**，再邊聽邊改（`earshot forge`），或把一段錄音**轉成可調參數的程式碼**（`earshot fit`）。全部在本機 CPU 上跑，提供 CLI、Python API 和 MCP server。

repo 於 2026-10-15 建立，查詢當下（2026-10-20）約 1,350 顆星，最後一次 push 為 2026-10-18。

## 核心功能／特色

- **描述與比對**：`describe` 用文字說明聲音像什麼（附校準過的分數與其他可能解讀）；`match` 判斷一段描述是否吻合（strong / plausible / weak / no match）；`rank` 依描述排序多個候選檔。
- **找片段**：`find` 在長錄音裡找出最符合描述的時間段，直接給出剪輯起訖秒數。
- **真假判斷**：`realness` 判斷是真實錄音或專業製作，還是程式合成。
- **影片聆聽**：`timeline` 產生事件、段落、響度、節拍與聲畫同步的逐秒紀錄；`sheet` 輸出附影格、頻譜、波形的標註圖，給能看圖的 agent；`critique` 對照 7 支專業發表片的設定檔打分並列出要修正的時間點。
- **客觀量測**：`measure` 不用模型，算 LUFS、true peak、LRA、頻譜、速度與調性。
- **程式化音效（forge）**：以物理合成寫成 recipe（模態共振、噪音、房間與麥克風模擬，不含錄音），由 earshot 的評審自動打分並用演化搜尋改良。v2 有 34 種動態設計類別（whoosh、riser、impact、click、ding 等）。
- **錄音轉程式碼（fit）**：用分析再合成的方式，把錄音轉成可重新渲染、可調大小／阻尼／音高，也能在兩段錄音之間 morph 的 recipe 模組。
- **音效庫與 kit（0.3）**：內建 201 個以程式碼儲存的音效，依 id 幾秒內渲染、不需模型也不需網路；可指定長度、最響時間點與音高對準畫面；`kit` 一次渲染整支影片的音效並記錄量測到的同步點。
- **Agent skill**：附 `skills/earshot`（教 agent 怎麼聽、何時別信結果）和 `skills/real-sound`（用授權真實錄音做高品質配樂的完整流程）。

## 安裝與使用方式

需要 Python 3.10 以上，PATH 裡要有 ffmpeg / ffprobe。只用 CPU。

```bash
git clone https://github.com/Leonxlnx/earshot && cd earshot
python -m venv .venv
.venv/bin/python -m pip install torch --index-url https://download.pytorch.org/whl/cpu
.venv/bin/python -m pip install -e ".[mcp,llm,dev]"
.venv/bin/python -m earshot doctor --load

# 接到 Claude Code 當 MCP server（模型常駐，不必每次重新載入）
claude mcp add earshot --scope user -e EARSHOT_THREADS=3 -- /path/to/earshot/.venv/bin/python -m earshot mcp
```

```bash
earshot describe enter.ogg
earshot match key.ogg "a deep thocky mechanical keyboard press" --alts "a clicky blue switch keyboard"
earshot find keys.ogg "a single mechanical key press" --top 4
earshot critique film.mp4
earshot sfx render whoosh_fast/crisp -o w.wav --dur 0.8 --apex 0.32
```

- 第一次使用會下載兩個開源模型（約 1.1 GB）：CLAP（`laion/larger_clap_general`）與 AudioSet 分類器 AST，之後只從本機快取載入、不再連網。
- 每次 CLI 呼叫都要重新載入模型（約 20–40 秒），要連續呼叫多次時改用 MCP server 或 Python API（`from earshot import api`）。`measure`、`sfx`、`kit` 不載入模型。

## 適用情境

- 讓 coding agent 替程式做出的影片（Remotion、HyperFrames、Cinetic 等）挑選、對齊、檢查音效。
- 從大量下載的音效檔裡，依文字描述挑出最合適的一個並自動剪好。
- 檢查聲畫同步、響度與混音問題，拿到帶時間戳的修正建議。
- 不用錄音、直接用程式碼產生 UI 音效、轉場 whoosh、logo sting 等。

## 授權與成本

- **授權**：程式碼 MIT；兩個模型各依原作者授權（CLAP Apache-2.0、AST BSD-3-Clause）。
- **成本**：免費、在本機 CPU 執行，不需 GPU。選用的 `llm` 指令會把音訊上傳給 Gemini 做評論，需要自己的 API key 並明確加上 `--yes-upload`。

## 限制與注意事項

- README 自述可信的部分：響度、時間點與聲畫同步、單一清楚音效「是不是我要的那種聲音」、在候選中挑選、明顯的程式合成音源。只能當提示的部分：繁忙混音裡的事件標籤、曲風與情緒。
- 無法判斷品味、情感、來源與授權、語音內容，模型聽不到 14 kHz 以上。
- 發表片評分表只代表那 7 支參考影片的風格，不代表所有好影片。
- forge 是在討好 earshot 自己的模型，可能分數變高但聲音沒變好（作者自己點出的 Goodhart 問題）；盲測只有作者一人、15 次，樣本很小。
- repo 不含任何音訊；forge 的參考錄音有授權限制沒有附上，要用 `--refs` 自備。
- 專案剛建立幾天、標示為 Alpha，介面與預設值仍在變（0.2.0 就改過 CLI 預設）。

## 相關工具

- [Cinetic](../03-影片製作/Cinetic.md)：同作者的 coding agent 導演短片 skill，已整合 earshot 做音效
- [Remotion](../03-影片製作/Remotion.md)、[HyperFrames](../03-影片製作/HyperFrames.md)：程式化影片框架，可搭配 earshot 配音效
- [Basic Pitch](Basic-Pitch.md)：音訊轉 MIDI

## 資料來源

- https://github.com/Leonxlnx/earshot （README）
- https://api.github.com/repos/Leonxlnx/earshot （星數、MIT、建立時間、最後 push）
- https://api.github.com/repos/Leonxlnx/earshot/releases/latest （v0.2.0，2026-10-16）
- https://github.com/Leonxlnx/earshot/blob/main/pyproject.toml （版本 0.3.0、Alpha）
