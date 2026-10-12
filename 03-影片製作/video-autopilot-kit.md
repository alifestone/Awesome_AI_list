# video-autopilot-kit

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/Hao0321/video-autopilot-kit

## 原清單說明

YouTube／短影音自動化框架（繁中文件）：長片、Shorts、訪談三條產線，ffmpeg QA，問卷式填入自己頻道的設定。

> **查證結果**：與 README 相符（README 以繁體中文撰寫，三條產線、ffmpeg QA、`SETUP.md` 問卷都有）。補充一點：GitHub 描述仍寫「CapCut JSON + ffmpeg tooling」，但 README 的現行版本（v0.23.0）已改成以 **Editkin `edit-plan/v4`** 作為唯一的剪輯執行契約。舊的 GUI 與草稿 JSON 流程只保留作為效能比較用的歷史紀錄。

## 概述

video-autopilot-kit 是 Hao0321 Studio 從自己的實戰創作系統中抽出來的開源框架，用於 YouTube 與短影音自動化。它提供三樣東西：

- 方法論與知識庫。
- 「機械閘門」，用程式規則擋下不合格的剪法或腳本。
- 可重現的素材處理與 QA 工具。

使用者透過 `SETUP.md` 回答關於**自己頻道**的問題，把模板填成自己的設定檔。repo 強調不含任何人的私人數據。查詢當下（2026-10-13）約 2.2k 顆星，README 標示的現行版本為 v0.23.0（架構 7.0）。

## 核心功能／特色

- **三條同構的產線**，每一條都是「知識層 → 機械閘門 → 一鍵驅動」：

  | 產線 | 閘門 | 驅動 |
  |---|---|---|
  | 教學長片 | `plan_gate` → `script_gate`（觀眾語言、節奏）→ `delivery_qa` | `src/longform_maker/` |
  | 直式 Shorts | `shorts_gate.py`，九條結構與字幕規則；片長帶依平台區分 | `shorts_autopilot.py`：`scan` → `build` |
  | 線上訪談 | `interview_gate.py`，沒有來源的來賓數據不上鏡 | `interview_autopilot.py`：`invite` → `plan`（產出 7 件套）→ `build` |

- **統一濾鏡庫**：38 組調色、動態、轉場、主體濾鏡，由長片、Shorts、Reels 共用。規則包括：調色只能套用一次，而且必須在字幕之前；轉場必須有剪輯動機。
- **Editor 中立的 QA**（`media_delivery_qa.py`）：頻閃、無聲空檔、字幕同步、全幀掃描、音訊與音畫同步、字幕斷句、BGM 覆蓋率。
- **競品拆解**（`teardown.py`）：把別人的直式短片拆成數字，例如剪輯速度、剪點間距分布、換句速率、LUFS。OCR 為選配。
- **經營層**：`channel_tracker.py`（D2／D7／D28 成效快照排程）、`system_health.py`（一鍵健康檢查）。
- **知識庫**：`knowledge/` 收錄 Shorts、演算法、AI 內容合規、腳本留存等方法論，規則是「沒有出處就不給數字」。
- **安全自動更新**：檢查 semver，以 SHA-256 驗證 release 包與每個檔案，可以 rollback。個人資料（`config.py`、`profiles/`、`videos/` 等）不會被覆蓋，也不會進入公開包。

## 技術架構或運作原理

- 唯一的剪輯執行契約是 Editkin v4：素材證據 → plan → audit → atomic apply → render，可續跑的 DAG 會記錄 receipts。Python 與 ffmpeg 只是跨平台的素材分析、正規化與 QA 支援層。
- Editkin 是什麼工具、在哪裡取得，README 沒有說明，網路搜尋也找不到公開資料，**資料不足**。
- 閘門共用 `gate_core.py` 外殼，自訂閘門只需 import 三個函式。
- `src/platform_compat.py` 會自動偵測 Mac／Linux 的系統路徑與中日韓字型。

## 安裝與使用方式

```bash
# 自包含的示範，不需要真實素材
python examples/01_vertical_short.py   # 合成素材 → 1080x1920 直式 Short（需要 ffmpeg）
python examples/04_shorts_gate.py      # Shorts 閘門示範，純 Python
python examples/05_interview_plan.py   # 訪談閘門示範，純 Python
python examples/06_teardown.py         # 競品拆解數學，純 Python

# 安裝或從舊版升級（macOS／Linux）
curl -fLO https://github.com/Hao0321/video-autopilot-kit/releases/latest/download/install_or_upgrade.py
python3 install_or_upgrade.py --install-root . --check
python3 install_or_upgrade.py --install-root . --apply --install-skill

# 濾鏡庫
python src/filter_runtime.py list
python src/filter_runtime.py apply input.mp4 output.mp4 --preset vlog_bright_clean

# 健康檢查
python src/system_health.py --quick
```

上手流程：

1. 讀 `SETUP.md`，把 `templates/*.template.md` 填成 `profiles/*.md`。也可以把 repo 交給 Claude 或 ChatGPT，請它照著問卷問你問題。
2. 執行 `cp config.example.py config.py`，填入路徑。
3. 用 `python scripts/hao_autopilot.py workflow ...` 建立 run。

需求：

- Python 3.9 以上、ffmpeg／ffprobe。
- 完整媒體功能需執行 `pip install -r requirements-media.txt`（Pillow、numpy、opencv-contrib-python-headless）。

## 適用情境

- 經營 YouTube 教學頻道、Shorts、Reels 或訪談節目，想把剪輯規範與品質檢查自動化。
- 想用「機械閘門」在發布前擋下常見錯誤，例如片長、字幕、沒有來源的數據。
- 想量化分析競品短片的節奏。
- 想參考繁體中文的創作方法論與 AI 內容合規清單。

## 授權與成本

- **授權**：MIT。README 寫明保留標註即可自由使用、修改與商用。
- **成本**：框架本身免費。OCR 等選配套件也是免費開源。Editkin 執行環境的取得方式與費用，**資料不足**。

## 限制與注意事項

- 閘門中的門檻數字（Shorts 片長帶、首刀秒數等）都是**範例校準值**，README 要求用自己的 3–5 支影片重新計算。
- 腳本閘門的詞表出貨時是空的，需要從自己的逐字稿整理。
- 可編輯時間軸的實際剪輯，依賴 Editkin 的 structured tool 環境，支援範圍依 Editkin 的 release 而定。這部分的公開資訊不足。
- OCR 只讀得動燒錄字幕。README 指出它讀實景招牌的準確率約為 0，而且讀錯時信心值仍有 0.85–0.92，所以不可以用來自動產生自己影片的品名或價格字幕。
- 重大或不相容的版本不會自動升級，第一次採用舊資料夾時，必須明確執行 `--apply`。

## 相關工具

- [ffmpeg-skill](ffmpeg-skill.md)：本地 FFmpeg 剪輯 agent skill
- [MoneyPrinterTurbo](MoneyPrinterTurbo.md)、[OpenMontage](OpenMontage.md)：從主題到成片的自動化系統
- CapCut（GitHub 描述中提及的舊流程）、RapidOCR、OpenCC

## 資料來源

- https://github.com/Hao0321/video-autopilot-kit （README，以 GitHub API 取得原文）
- https://api.github.com/repos/Hao0321/video-autopilot-kit （repo 中繼資料：描述、星數、MIT 授權）
- WebSearch「Editkin video editing structured tool edit-plan」（找不到 Editkin 的公開資料）
