# LlamaFactory

- **分類**：推論與訓練引擎
- **連結**：https://github.com/hiyouga/LlamaFactory
- **文件**：https://llamafactory.readthedocs.io
- **教學文章**：https://www.aiposthub.com/llamafactory-no-code-webui-fine-tuning-lora-qlora-guide/

## 概述

LlamaFactory（舊稱 LLaMA-Factory）是 hiyouga 維護的開源 LLM／VLM 微調框架，GitHub 描述為「Unified Efficient Fine-Tuning of 100+ LLMs & VLMs (ACL 2024)」。主打「零程式碼」：用 YAML 設定檔搭配 `llamafactory-cli`，或用 Gradio 做的 **LLaMA Board** 網頁介面，在瀏覽器裡選模型、資料集、微調方法與超參數就能開始訓練，訓練完在同一個介面對話測試、合併匯出。README 列出 Amazon（SageMaker）、NVIDIA、阿里雲 PAI 等使用案例。

查證時（2026-11-22）約 7.6 萬星，最新 release 為 v0.9.5（2026-05-30），主分支仍持續更新。

## 核心功能／特色

- **模型**：Llama、LLaVA、Mistral／Mixtral、Qwen3／Qwen3-VL、DeepSeek、Gemma、GLM、Phi、gpt-oss、InternVL 等 100+ 種；README 標示部分新模型 Day 0／Day 1 支援。
- **訓練階段**：（持續）預訓練、（多模態）監督式微調、獎勵模型、PPO、DPO、KTO、ORPO、SimPO。
- **微調方式**：16-bit 全參數、凍結層微調、LoRA、2／3／4／5／6／8-bit QLoRA（AQLM／AWQ／GPTQ／LLM.int8／HQQ／EETQ）、OFT／QOFT。
- **進階演算法**：GaLore、BAdam、APOLLO、Adam-mini、Muon、DoRA、LongLoRA、LLaMA Pro、LoRA+、LoftQ、PiSSA 等。
- **加速**：FlashAttention-2、Unsloth、Liger Kernel、KTransformers、DeepSpeed，以及 Megatron-core 後端（mcore_adapter）。
- **任務**：多輪對話、工具呼叫、圖像理解、視覺定位、影片辨識、音訊理解。
- **實驗監控**：LlamaBoard、TensorBoard、W&B、MLflow、SwanLab。
- **推論／部署**：CLI、Gradio UI、OpenAI 相容 API，可用 vLLM 或 SGLang 當推論後端；匯出時可順便產生 Ollama modelfile。
- **硬體**：NVIDIA GPU、AMD GPU（ROCm 文件）、華為昇騰 NPU（有官方 Docker 映像）。
- **雲端試用**：免費 Colab notebook、阿里雲 PAI-DSW 試用、AMD GPU Cloud 免費額度。

## 顯存需求（官方估計值）

README 的 Hardware Requirement 表格（標示為 *estimated*）：

| 方法 | 位元 | 7B | 14B | 30B | 70B |
|---|---|---|---|---|---|
| 全參數（bf16／fp16） | 32 | 120GB | 240GB | 600GB | 1200GB |
| 全參數（pure_bf16） | 16 | 60GB | 120GB | 300GB | 600GB |
| 凍結／LoRA／GaLore／APOLLO／BAdam／OFT | 16 | 16GB | 32GB | 64GB | 160GB |
| QLoRA／QOFT | 8 | 10GB | 20GB | 40GB | 80GB |
| QLoRA／QOFT | 4 | 6GB | 12GB | 24GB | 48GB |
| QLoRA／QOFT | 2 | 4GB | 8GB | 16GB | 24GB |

換算：4-bit QLoRA 微調 7B 約 6GB，8GB 消費級顯卡就可嘗試；LoRA 微調 7B 約需 16GB。

## 安裝與使用方式

```bash
# 從原始碼安裝
git clone --depth 1 https://github.com/hiyouga/LlamaFactory.git
cd LlamaFactory
pip install -e .
pip install -r requirements/metrics.txt   # 選用：deepspeed 等在 requirements/ 內

# 開啟 LLaMA Board 網頁介面（零程式碼微調）
llamafactory-cli webui

# 或用 YAML 設定檔：LoRA 微調、對話測試、合併匯出（以 Qwen3-4B 為例）
llamafactory-cli train  examples/train_lora/qwen3_lora_sft.yaml
llamafactory-cli chat   examples/inference/qwen3_lora_sft.yaml
llamafactory-cli export examples/merge_lora/qwen3_lora_sft.yaml

# 以 vLLM 為後端提供 OpenAI 相容 API
API_PORT=8000 llamafactory-cli api examples/inference/qwen3.yaml infer_backend=vllm vllm_enforce_eager=true
```

- 需求：Python ≥ 3.11、PyTorch ≥ 2.0（建議 2.6）、transformers ≥ 4.49；CUDA 選用（建議 12.2）。
- 自訂資料集需登記在 `data/dataset_info.json`；資料格式見 `data/README.md`。可直接用 Hugging Face／ModelScope／Modelers 上的資料集，或 S3／GCS 路徑。
- 也提供 Docker 映像（CUDA、昇騰 NPU、ROCm）。

## WebUI 微調流程（整理自教學文章）

aiposthub 的中文教學把 WebUI 流程整理成四步：

1. **準備資料**：Alpaca（單輪指令）或 ShareGPT（多輪對話）格式的 JSON，放進 `data/` 並登記到 `dataset_info.json`。建議 500～2000 筆人工審過的高品質資料。
2. **啟動介面**：`llamafactory-cli webui`，選基底模型；顯存只有 8～12GB 時把量化等級設成 `4`，就是 QLoRA。
3. **設定超參數**：LoRA 學習率 `1e-4`～`2e-4`；約 1000 筆資料訓練 3～5 個 epoch；顯存小時 batch size 1～2、梯度累積 8～16；看 loss 曲線是否平穩下降。
4. **驗收與匯出**：在 Chat 分頁載入 adapter 測試，滿意後合併匯出；文章提到可再轉成 GGUF 給本地推論工具使用（README 未把 GGUF 轉換列為內建功能，通常需另用 llama.cpp 轉換）。

文章提醒的常見坑：

- **過擬合**：loss 很低不代表成功；建議不超過 5 個 epoch，切約 10% 當驗證集，驗證 loss 回升就停。
- **災難性遺忘**：純領域資料會讓模型失去通用能力；建議約 8 成領域資料搭 2 成通用對話資料。
- **對話模板選錯**：模板與基底模型家族不符會導致模型停不下來（如 Qwen 用 `<|im_end|>`、Llama 3 用 `<|eot_id|>`）。
- **RAG 與微調分工**：會變動的事實（價格、庫存）用 RAG；固定語氣與輸出格式才適合微調。

## 適用情境

- 不想寫訓練腳本，想用網頁介面在單張消費級顯卡上以 LoRA／QLoRA 微調開源模型。
- 需要同一套工具涵蓋 SFT、獎勵模型、PPO／DPO／KTO／ORPO 等完整後訓練流程。
- 微調多模態模型（圖像、影片、音訊理解）。
- 在昇騰 NPU 或 AMD GPU 上微調。
- 微調完直接以 OpenAI 相容 API 或 Ollama 部署。

## 授權與成本

- **程式碼**：Apache-2.0，免費。
- **模型權重**：依各基底模型授權（Llama、Qwen、Gemma、DeepSeek 等各自條款）；微調後能否商用取決於基底模型授權。

## 限制與注意事項

- 顯存表是官方**估計值**；實際用量會隨序列長度、batch size、是否開 FlashAttention／DeepSpeed 而變。教學文章給的數字（如 LoRA 7B 約 16～20GB）略高於官方表格。
- 教學文章稱整合加速技術後「速度約翻倍、顯存省三到五成」，未附實測依據；文章寫的「4 萬星」也已過時（查證時約 7.6 萬）。
- Windows 需手動安裝 CUDA 版 PyTorch；要用 QLoRA 得另裝 bitsandbytes 並注意 CUDA 版本（RTX 50 系列需 CUDA 12.8～12.9 的版本）；FlashAttention-2 需自行編譯。
- 教學文章說支援 Apple Silicon（建議統一記憶體 ≥ 16GB，速度不如 NVIDIA）；README 未說明 macOS 支援程度（本條目未查證 → 資料不足）。
- README 提醒：除官方列出的連結外，其他網站都是未授權的第三方網站。
- 官方文件仍標示 WIP。

## 相關工具

- [Unsloth](Unsloth.md)：同類的微調框架，也有 Studio 圖形介面；LlamaFactory 可選用 Unsloth 當加速後端。
- [dLLM](dLLM.md)：擴散語言模型的訓練函式庫。
- [EasyR1](https://github.com/hiyouga/EasyR1)：同作者的多模態 RL（GRPO）訓練框架（本條目未查證細節）。
- [Easy Dataset](https://github.com/ConardLi/easy-dataset)：README 推薦用來產生微調用的合成資料。

## 資料來源

- https://github.com/hiyouga/LlamaFactory（README、repo 資訊、releases）
- https://llamafactory.readthedocs.io
- https://www.aiposthub.com/llamafactory-no-code-webui-fine-tuning-lora-qlora-guide/
