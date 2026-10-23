# MAC – Multi-Agent CAD

- **分類**：3D 建模與生成 / CAD / 參數化建模
- **連結**：https://github.com/Pan-Chera/Multi-Agent-CAD

## 原清單說明

四個 agent 分工的 text-to-CAD（build123d），直接輸出可列印的 STEP/STL，token 用量約為單一 agent 的 1/116。

> **查證結果**：大致正確，但有兩點需要修正。
> 1. **「四個 agent」**：單零件流程設定檔中確實有四個可分別指定模型的階段（`SPEC_PLANNER`、`ARCHITECT`、`CODER`、`REPAIR`），另以 Aider 做程式修復。但 v2 新增了獨立的 QA Judge，也新增了多零件組裝流程，所以「四個」只適用於早期的單零件流程。
> 2. **「1/116」**：README 原文是「在 Qwen 3.7 設定下，MAC v1 的記錄 token 數比重現的 CAD Skill 基準少 116 倍、估計成本低 13 倍」。比較對象是 earthtojake/text-to-cad（CAD Skills）重現的流程，並非泛指「單一 agent」；而且只是 10 道題、141 個特徵的單零件基準測試結果。換成 Qwen 3.8 加視覺驗證的 MAC v2，則是少 62.7 倍 token、成本低 6.1 倍。
>
> 另外，目前除了 STEP/STL，也可以輸出 GLB；組裝流程還可輸出 URDF。

## 概述

MAC（Multi-Agent CAD）是一個解耦式多 agent 的 text-to-CAD 框架，把自然語言設計需求轉成**可編輯的工程幾何**（build123d 程式碼與 B-rep 模型），而不是只能看的渲染圖。可以產生單一可列印零件；v2 也能把一個機構拆成多個零件分別生成，再組裝、驗證並匯出。專案在清華大學 IEI Lab 開發，引用作者為 Guanxing Qu 與 Xueyan Zou。

截至 2026-10-13：MIT 授權、約 1k 顆星、主要語言 Python。

## 核心功能／特色

- **自然語言輸入**：描述幾何、尺寸、介面、運動，不需寫 CAD 程式碼。
- **零件與組裝**：單零件流程穩定；多零件組裝為技術預覽（實驗性）。
- **可編輯輸出**：STEP、STL、GLB；組裝另輸出 URDF，可接到機器人／物理模擬（README 示範 AI 生成的機械手在模擬中轉動物體、夾取放置）。
- **可稽核**：結構化需求書（CADBrief）、幾何規劃（ArchitectPlan）、生成的 Python、量測值、QA 報告與修復紀錄都保存在磁碟上。
- **自動執行與修復**：執行生成的 CAD 程式並檢查，失敗時進入有上限的修復迴圈。
- **重用**：重複或鏡像零件從同一份幾何衍生，不重新生成。
- **各階段可用不同模型**：介面相容 OpenAI API，預設為阿里雲 DashScope（Qwen）。
- **網頁 UI**：單零件流程有瀏覽器介面，含 3D 預覽與下載。
- **可列印的 print-in-place 機構**：README 展示含多個獨立實體與功能間隙的列印成品。

## 技術架構或運作原理

單零件流程（依 `multi_agent_cad/README.md`）：

```text
自然語言需求／參考圖片
  → Spec Planner（產出 CADBrief）
  → Geometric Architect（產出 ArchitectPlan）
  → 確定性 Python 轉譯（不足處以 Aider 補完）
  → 執行 build123d，匯出 STEP/STL
  → 量測 + QA Judge + 有上限的修復迴圈
```

- 各 agent 之間只交換精簡的結構化產物，不重播整段對話，這是省 token 的主要原因。
- `nodes.py` 的確定性轉譯器可直接處理擠出、旋轉、孔、布林、陣列、鏡像、圓角、倒角、薄殼等常見操作，不需額外呼叫模型；不支援的步驟會留下 `TODO_AIDER` 標記交給 Aider。
- QA Judge 可接受結果、判定需求不可能而停止，或要求修復；可用多模態模型比對渲染視圖，沒有時退回純文字。
- 以 LangGraph 做狀態化編排；幾何核心為 build123d（OpenCascade）；`packages/cadpy` 的 STEP/GLB 執行環境衍生自 earthtojake/text-to-cad（MIT）。

## 安裝與使用方式

```bash
git clone https://github.com/Pan-Chera/Multi-Agent-CAD.git
cd Multi-Agent-CAD
conda env create -f environment.yml
conda activate multi_agent_cad
pip install --no-deps "aider-chat==0.82.3"   # 避免 aider 的 NumPy 1.x 鎖定覆蓋 build123d 需要的 NumPy 2.x
export DASHSCOPE_API_KEY="your-key"
```

產生單一零件（先在 `multi_agent_cad/config.py` 設定 `USER_REQUEST`）：

```bash
python -m multi_agent_cad.graph
```

網頁 UI：

```bash
pip install -e ".[web]"
python -m multi_agent_cad.web     # 預設只聽 127.0.0.1
```

產生組裝：

```bash
MAC_ASSEMBLY_REQUEST="Create a two-part hinged clamp with a fixed base and one rotating jaw." \
python -m mac_assembly
```

其他：

- 換用其他相容 OpenAI 的供應商時，修改 `DS_BASE_URL` 與各階段模型 ID。
- 修改既有設計：`python -m multi_agent_cad.graph_aider`。
- 單零件快取只檢查檔案是否存在，不比對需求內容；換需求前要刪除 `pipeline_cache/cad_brief.json` 與 `pipeline_cache/architect_plan.json`。

## 適用情境

- 機械零件、治具、外殼等可 3D 列印零件的快速設計。
- 生成可匯入模擬器的簡單機構／機器人組裝（URDF）。
- text-to-CAD 與多 agent 架構的研究與基準比較。

## 授權與成本

- **授權**：MIT；`packages/cadpy` 沿用 earthtojake/text-to-cad 的 MIT 授權。
- **成本**：軟體免費，主要花費是 LLM API。README 數據（單零件基準，10 道題）：MAC v1（Qwen 3.7）約 0.90M token、估計 $1.43；MAC v2（Qwen 3.8）約 1.40M token、估計 $4.85。組裝範例從約 30 萬 token（約 $1）到約 580 萬 token（約 $13）不等。

## 限制與注意事項

- 基準數字只涵蓋 10 道題、141 個特徵的單零件測試，不代表對新題目的一般成功率；組裝流程不在基準之內。
- 組裝畫廊是精選結果，不是測得的成功率；用於製造或模擬前必須自行驗證幾何與關節。
- **安全性**：網頁 UI 會以使用者權限執行生成的 Python，不要直接暴露到不受信任的網路。狀態變更 API 需帶 `X-MAC-CSRF: 1` 標頭；子程序環境變數清除只能降低外洩風險，不是沙箱。
- 純 pip 安裝會遇到 aider-chat 與 build123d 的 NumPy 版本衝突，需照 README 的變通步驟處理；Windows 不在 CI 測試範圍。
- 生成的幾何（尤其多實體 print-in-place 零件）仍需依製程檢查。

## 相關工具

- [build123d](https://github.com/gumyr/build123d)、[LangGraph](https://langchain-ai.github.io/langgraph/)、[Aider](https://aider.chat/)
- [earthtojake/text-to-cad](https://github.com/earthtojake/text-to-cad)（CAD Skills，基準比較對象）
- 同資料夾：FreeCAD MCP、Rhino MCP、[text-to-cad](text-to-cad.md)

## 資料來源

- https://github.com/Pan-Chera/Multi-Agent-CAD （README）
- https://raw.githubusercontent.com/Pan-Chera/Multi-Agent-CAD/HEAD/multi_agent_cad/README.md （單零件流程文件）
- https://api.github.com/repos/Pan-Chera/Multi-Agent-CAD （repo 中繼資料：簡介、授權、星數、主題）
