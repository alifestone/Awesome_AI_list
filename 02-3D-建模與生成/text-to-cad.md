# text-to-cad

- **分類**：3D 建模與生成 / CAD / 參數化建模
- **連結**：https://github.com/earthtojake/text-to-cad

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語是「Give your agent CAD superpowers」。它是給 Claude Code、Codex、Cursor、Gemini、Grok 等 AI agent 用的**外掛／skill 套件**，在本機用 build123d（Open CASCADE 核心）寫程式產生 CAD 模型，本身不是一個 text-to-3D 生成模型。[MAC – Multi-Agent CAD](MAC-–-Multi-Agent-CAD.md) 的 token 用量基準，比較對象就是這個 repo 的 CAD Skills。

## 概述

text-to-cad 讓 agent 在本機用自然語言或參考圖片產生、修改 3D 模型，主要輸出 STEP，也可匯出 GLB、STL、3MF。除了建模，還附製造性檢查（DFM、3D 列印 DfAM）、標註尺寸的工程圖 PDF、2D DXF、機器人描述檔（URDF／SRDF／SDF），以及 OrcaSlicer 切片、Bambu Lab 印表機、SendCutSend 加工服務的串接。

核心是 PyPI 套件 `cadgen`（Python 3.11+，透過 `uv` 執行），內含 build daemon、CAD Viewer 與 MCP 伺服器（`cadgen mcp`）。支援 MCP App 檢視的用戶端（Claude Desktop、Claude Code、Codex app）可以直接在對話中看到可旋轉的模型卡片；其他用戶端則給一個在瀏覽器開啟 CAD Viewer 的連結。

作者為 Jake Fitzgerald（earthtojake）。repo 於 2026-04-22 建立，查詢當下（2026-10-23）約 22.6k 顆星、2.2k fork，最新版本 0.7.26（2026-10-20），幾乎每天都有新版。官方文件站為 https://www.texttocad.dev。

## 核心功能／特色

12 個 skill：

| Skill | 用途 |
| --- | --- |
| CAD | 從文字或圖片建立、編輯 CAD 模型，輸出 STEP，可匯出 STL／3MF／GLB |
| step.parts | 從 step.parts 線上目錄搜尋並下載現成零件（螺絲、軸承、馬達、伺服機、連接器等）的 STEP 檔，附 SHA-256 驗證 |
| Engineering Drawing | 由零件產出含視圖、隱藏線、尺寸、孔標註、標題欄的工程圖 PDF |
| DXF | 產生外形、模板、墊片、切割排版等 2D DXF |
| URDF／SRDF／SDF | 撰寫機器人結構檔、MoveIt 規劃設定、模擬器模型與世界 |
| DfAM Check | 依 3D 列印製程量測壁厚、懸垂、支撐量與擺放方向 |
| DFM | 針對鈑金、CNC、射出成型審查零件，每項發現都附量測證據與引用的規則 |
| G-code | 用 OrcaSlicer 與自己的印表機設定切片 |
| Bambu Labs | 透過 Bambu Connect 或 Bambu Studio 送印到 Bambu Lab 印表機 |
| SendCutSend | 上傳到 SendCutSend 前檢查 DXF 與 STEP |

- **CAD Viewer**：本機網頁檢視器，有選取、量測、剖切（Clip）、標註，以及把選取的幾何當作參考丟回給 agent 的 Quick Edit；介面有五種語言。
- **多種 agent 皆可用**：Claude Code／Codex／Cursor／Grok Build／Gemini 有各自的外掛安裝方式；其他 agent 可用 `npx skills add` 只裝 skill。

## 安裝與使用方式

需要先裝好 [uv](https://docs.astral.sh/uv/)。官方建議直接對 agent 說：

```text
Install text-to-cad from https://github.com/earthtojake/text-to-cad
```

或手動安裝（以 Claude Code 為例，`#latest` 分支只放已發布到 PyPI 的版本）：

```bash
claude plugin marketplace add earthtojake/text-to-cad#latest
claude plugin install text-to-cad@earthtojake
```

Claude Desktop 則在設定檔加入 MCP 伺服器：

```json
{
  "mcpServers": {
    "cad": {
      "command": "uvx",
      "args": ["--no-config", "--managed-python", "--python", "3.13", "--from", "cadgen==0.7.26", "cadgen", "mcp"]
    }
  }
}
```

沒有外掛支援的 agent：

```bash
npx skills add earthtojake/text-to-cad#latest
```

首次啟動會下載 CAD runtime，需要網路。外掛與「只裝 skill」擇一即可，兩者都裝會讓每個 skill 出現兩次。

## 適用情境

- 讓 agent 從一句描述或一張草圖做出可 3D 列印、可加工的機械零件或治具。
- 做機器人或機構時，直接抓現成馬達、伺服機、軸承的 STEP 檔組裝，再產出 URDF 給模擬器。
- 送印或下單加工前，用 DfAM／DFM skill 先檢查可製造性，並產出工程圖。

## 授權與成本

- **MIT**。
- 本體免費、在本機執行；費用來自你使用的 agent／LLM。SendCutSend 等加工服務、Bambu Lab 印表機另計。

## 限制與注意事項

- **預設會送出遙測**：用量統計與當機報告會以隨機 ID 傳到作者的伺服器（存放於 PostHog），官方說明不含檔名、路徑、內容與提示詞。可用 `uvx cadgen telemetry off` 關閉（同時刪除已送出的資料），或設 `DO_NOT_TRACK=1`。另外每天最多檢查一次新版本（`CADGEN_UPDATE_CHECK=0` 可關）。
- CAD Viewer 後端預設綁在 `127.0.0.1` 且**沒有驗證**，本機任何程式都能讀取它開啟的目錄、觸發建置；不要綁到非 loopback 位址。
- Windows 11 開啟 Smart App Control（新安裝的預設值）時，OCP 的原生模組未簽章會被擋，所有 `cadgen` 指令都會失敗；只能關掉 Smart App Control 或改用 WSL。
- step.parts 是線上服務，搜尋零件需要連網。
- 版本更新非常頻繁（0.7.x 幾乎每日發版），介面與指令可能變動。

## 相關工具

- [build123d](https://github.com/gumyr/build123d)、[Open CASCADE](https://dev.opencascade.org)、[OrcaSlicer](https://github.com/SoftFever/OrcaSlicer)
- 同資料夾：[MAC – Multi-Agent CAD](MAC-–-Multi-Agent-CAD.md)（多 agent 的 build123d text-to-CAD，以本專案為基準比較對象）、[FreeCAD MCP](FreeCAD-MCP.md)、[Rhino MCP](Rhino-MCP.md)

## 資料來源

- https://github.com/earthtojake/text-to-cad （README、SECURITY.md、skills/；2026-10-23 查詢時約 22.6k 星）
- https://pypi.org/project/cadgen/ （0.7.26）
- https://www.texttocad.dev
