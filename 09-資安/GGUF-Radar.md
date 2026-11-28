# GGUF Radar

- **分類**：資安 / 模型檔供應鏈掃描（不執行模型就檢查 GGUF／Safetensors／PyTorch 模型檔有沒有藏惡意程式或被下毒的 chat template）
- **連結**：https://github.com/Root0ne/gguf-radar
- **研究文章**：https://malspark.com/blog/malicious-gguf-models-hugging-face/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：作者 Root0ne（GitHub 個人頁連到 malspark.com，也就是附帶研究文章的網站）。倉庫 2026-11-27 建立，同日發 v0.1.0，隔天發 v0.1.1；MIT 授權（logo 等素材另有 `LICENSE-ASSETS`）。截至 2026-11-29 約 120 星。有 CI、測試、CHANGELOG、`SECURITY.md` 與詳細文件，pyproject 標為 Beta。還沒上 PyPI，要從 GitHub 安裝。

## 概述

GGUF 檔裡除了權重，還放著 chat template，也就是每次對話前都會跑的一小段 Jinja2 程式。研究文章整理了 Hugging Face 上真的出現過的兩種攻擊：

1. **把程式藏在權重後面**：llama.cpp 等載入器只照 tensor 表讀固定範圍，表外的位元組根本不看，可以塞一個 Windows 執行檔或 ZIP。
2. **改 chat template**：插入使用者看不到的指令，讓模型在回答裡叫使用者執行指令，或在出現某個觸發字時叫 coding agent 下載並執行腳本；也可以寫成會在模板裡解開、寫出藏在檔尾的程式。

GGUF Radar 對這兩種攻擊做靜態檢查，**從頭到尾都不執行模型，也不渲染模板**。如果發現 GGUF 檔有問題，還能重建一份權重完全相同的乾淨副本（CDR，content disarm and reconstruction）。

## 核心功能／特色

- **掃本機檔或資料夾**：遞迴找 GGUF，也會順便讀 Safetensors／PyTorch 模型旁邊的 `tokenizer_config.json`、`chat_template.json`、`chat_template.jinja`
- **直接掃 Hugging Face 倉庫**：只用 range request 抓檔頭（metadata＋模板）和檔尾，幾 GB 的模型也只下載幾 MB；每個倉庫預設檢查 20 個 GGUF（`--max-files` 可調），支援私有／gated 模型（`HF_TOKEN`）
- **批次**：`--list targets.txt` 混著放 HF 位址與本機路徑，預設 4 個同時跑（`--workers`）
- **四種判定**：`CLEAN`／`SUSPICIOUS`／`MALICIOUS`／`ERROR`，退出碼 0／2／1，可直接卡 CI；`--json` 存完整報告
- **`sanitize` 重建乾淨副本**：丟掉檔尾資料、padding 補零、清掉 zero-scale 區塊裡用不到的位元組、`-0` 改成 `0`、重複的 metadata key 只留一份；可用 `--replace-template` 換回原版模板或 `--strip-template` 拿掉模板
- **YARA 規則**：`rules/gguf_supply_chain_threats.yar` 涵蓋研究文章裡的實際樣本，可以丟進任何讀 YARA 的工具
- **Python API**：`scan_local_gguf`、`scan_targets`、`sanitize_gguf_file`

## 技術架構或運作原理

依照 GGUF 的固定結構（檔頭＋metadata → tensor 表 → 對齊 padding → 權重）算出「應該」有哪些位元組，再比對實際檔案：

- **檔尾多出的資料**：最後一個 tensor 結束後檔案就該結束。多出來的部分會回報大小、熵值與是否有已知檔案簽章（PE、ZIP 等）；有簽章、很隨機或超過 64 KiB 判 `MALICIOUS`。Safetensors 載入器本身會拒絕多餘位元組，所以這項只針對 GGUF。
- **Padding**：允許很大的對齊值，但 padding 裡只要有非零位元組就回報。
- **Zero-scale 區塊**：量化區塊的 scale 是 0 時，裡面的值不會影響模型，可以拿來藏資料；但這也是量化的正常副產物（極小權重的 scale 轉成 fp16 後變 0）。所以平常只當成 note，只有出現以下跡象才升級：`Q8_0` 出現量化器不可能寫出的值（例如 -128）、4096 位元組視窗內分佈平到像加密資料、含檔案簽章或可讀文字、scale 存成 `-0`。只支援 `Q8_0` 與 `Q4_K`，而且需要整個檔案，所以只對本機檔執行。
- **Chat template**：用 Jinja2 解析成語法樹而不渲染，比對檔案／行程操作、對 agent 下的隱藏指令（`agentic_tool_hijack`）、等觸發字的條件分支（`conditional_logic_bomb`）、Python SSTI 逃逸與其混淆寫法、覆寫指令的語句、shell 指令名、敏感路徑、寫死的 URL 等，每個模板給 0–100 的風險分數與指紋。出現在觸發字分支裡的發現會加上 `conditional_` 前綴。

相依只有 `numpy` 與 `jinja2`，Python 3.10+。

## 安裝與使用方式

```bash
pip install git+https://github.com/Root0ne/gguf-radar

# 掃本機檔或整個資料夾
gguf-radar scan ./model.gguf
gguf-radar scan ./models/

# 掃 Hugging Face 倉庫（也可給完整 URL 或單一檔案的 blob URL）
gguf-radar scan Qwen/Qwen2.5-0.5B-Instruct-GGUF

# 批次
gguf-radar scan --list targets.txt --json report.json

# 重建乾淨副本，並換回原版模板
gguf-radar sanitize suspicious.gguf -o clean.gguf --replace-template original_template.jinja
gguf-radar scan clean.gguf
```

CI 裡建議釘版本（例如 `@v0.1.1`），遇到 `SUSPICIOUS`／`MALICIOUS` 會以退出碼 2 讓 job 失敗。

## 適用情境

- 從 Hugging Face 下載第三方量化的 GGUF（尤其是非官方上傳者）前先掃一次
- 公司內部模型倉庫或 CI 上架前的關卡，擋掉藏有程式或被改模板的檔案
- 讓 coding agent 用本地模型前，確認 chat template 沒有對 agent 下隱藏指令
- 已經下載的可疑檔案，用 `sanitize` 清掉藏匿空間再用
- 把 YARA 規則接進既有的惡意程式掃描流程

## 授權與成本

- **授權**：MIT（程式碼）；logo 等素材另見 `LICENSE-ASSETS`。
- **成本**：免費，本機執行。掃 HF 倉庫只下載檔頭與檔尾。

## 限制與注意事項

- **模板檢查是比對已知模式**：刻意繞過的模板可能過關，正常模板（例如含官方 URL）也可能被標 `SUSPICIOUS`；`SUSPICIOUS` 代表「要人看一下」，不是攻擊證據
- **不檢查模型學到了什麼**：被訓練成會給有害回答的模型，檔案結構與模板可能完全正常
- **Zero-scale 檢查只跑本機檔**，只看 `Q8_0`／`Q4_K` 的前 128 個 tensor；刻意模仿權重分佈的資料、小於 4096 位元組的加密資料都抓不到（但 `sanitize` 會把這些位元組全部清掉）
- 權重是均勻分佈的極小值時，可能誤判為像加密資料
- `sanitize` 不會修好有害的模板，要另外換掉或移除
- `CLEAN` 不是保證；倉庫裡的檔案之後還可能被換掉，要持續掃
- 專案剛發布兩天（v0.1.x），規則與判定標準可能還會調整

## 相關工具

- [Qwen Fixed Chat Templates](../11-推論與訓練引擎/Qwen-Fixed-Chat-Templates.md)：修正版 Qwen chat template；用 `sanitize --replace-template` 換模板時可參考
- [Hugging Face Nightwatch](./HF-Nightwatch.md)：監控組織在 Hub 上的異常活動，屬於另一層防護
- Hugging Face 內建的 malware／pickle 掃描、ProtectAI ModelScan：偏重 pickle 等可執行格式，GGUF Radar 專攻 GGUF 結構與 chat template

## 資料來源

- https://github.com/Root0ne/gguf-radar
- https://github.com/Root0ne/gguf-radar/tree/main/docs
- https://malspark.com/blog/malicious-gguf-models-hugging-face/
