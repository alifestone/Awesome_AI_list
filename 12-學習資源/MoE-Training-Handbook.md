# The Ultimate MoE Training Handbook

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://huggingface.co/spaces/huggingface/moe-blogpost
- **發布貼文**：https://www.linkedin.com/posts/thom-wolf_18-of-the-20-best-open-models-today-are-mixture-of-experts-activity-7524199942492631040-orOZ （Thomas Wolf，LinkedIn）

## 原清單說明

（使用者新增，無原清單說明。使用者提供 HF Space 連結與 Thomas Wolf 的 LinkedIn 發布貼文。）

> **查證結果**：Hugging Face 官方 Space，標題 *The Ultimate MoE Training Handbook*，副標 *How to train a Mixture-of-Experts model at scale, setting by setting, with the runs that back each choice*。作者 Nouamane Tazi、Leandro von Werra、Thomas Wolf（Hugging Face），2026-11-05 發布。依原始碼統計正文約 7.2 萬英文字（作者稱約 7 萬字、55 個互動圖表），以 Megatron-LM 為主要訓練框架。Thomas Wolf 的貼文稱團隊為此跑了約 80 萬 GPU 小時的實驗。查詢當下（2026-11-06）Space 約 196 個讚；Space 未標示授權。

## 概述

Hugging Face 繼 *Ultra-Scale Playbook*（分散式訓練）與 *Smol Training Playbook*（訓練 dense 的 SmolLM3）之後的第三本長篇訓練手冊，這次專講 Mixture-of-Experts。出發點是：Artificial Analysis 開放權重榜前 20 名中有 18 個是 MoE，但把 MoE 訓練好的實務知識集中在少數團隊手上。

從 dense 換到 MoE 會多出三個新問題：決定每個 token 走哪些專家的 router、要保持平衡的專家負載，以及專家分散到不同 GPU 後每層都要做的 all-to-all token 交換。手冊把這些設定一個一個拆開，大多附上自家叢集實驗的結果、可執行的程式碼與互動圖表。開頭還有一張「症狀 → 第一個異常訊號 → 該讀哪一節」的除錯地圖，訓練出問題時可以回頭查。

作者建議閱讀時間 1–2 天，且不建議用手機讀。

## 核心功能／特色

- **從零動手**：第 2 章帶你測試叢集網路（nccl-tests）、用 enroot／pyxis 建 Megatron 映像、tokenize、先跑 dense baseline，再在單節點上訓練一個 6.86B 總參數、1.22B 活躍參數的小 MoE。也說明沒有叢集時怎麼在 Hugging Face Jobs 租 8×H200 節點，或只用一張 GPU／不用 GPU 跟著讀。
- **MoE 設計逐項拆解**（第 3 章，篇幅最大）：
  - Router 評分：gating function（softmax、sigmoid、sqrt(softplus)）、輸出縮放、銳利度、用 fp32 算 router。
  - 路由策略：token 選專家或專家選 token、hash layers。
  - 負載平衡：不平衡的代價、aux loss 與其作用範圍、DeepSeek 的 loss-free bias、quantile 方法。
  - 專家：數量與大小、latent MoE、共享專家、可變計算量、激活函數。
  - 區塊配置：前幾層保留 dense、區塊接線方式。
  - 訓練：從 dense checkpoint upcycling 或從頭訓練、optimizer、MTP、穩定性。
  - 系統：profiling、互連、通訊與計算重疊、記憶體、group-limited routing、capacity 與專家副本、精度。
- **從訓練到部署**（第 4 章）：推論時用比訓練少的 k 個專家、低位元專家、推論端的 expert parallelism、attention／FFN 分離部署、RL 階段的路由問題。
- **附錄**：監控指標細節（router 統計、路由診斷、專家活化、整體健康），以及依症狀查找的除錯索引。
- **互動圖表**：數十個可操作的視覺化（大多在第 3 章），例如一個訓練步驟在 1,024 張 GPU 上如何分配專家與 pipeline。

## 課程／教材結構

| 章 | 主題 | 內容 |
|---|---|---|
| 1 | Introduction | 為什麼 MoE 是主流、三大新挑戰、除錯地圖與閱讀路線 |
| 2 | Setup and your first run | 硬體檢測、建映像、tokenize、dense baseline、第一個 MoE |
| 3 | Anatomy of MoE training | 監控、router、路由、負載平衡、專家、區塊配置、訓練、系統（3.0–3.7） |
| 4 | From training to serving | 推論時的 k、量化、EP、分離部署、RL routing |
| 5 | Conclusion | 總結與致謝 |
| A | Appendix | 監控細節與除錯索引 |

只想了解 MoE 怎麼運作、前沿模型怎麼設計，而不打算自己跑的人，作者建議跳過第 2 章直接讀第 3 章。

## 安裝與使用方式

線上閱讀，不用安裝：打開 https://huggingface.co/spaces/huggingface/moe-blogpost 即可。

想照著跑的話需要：GPU 叢集（指令以 Slurm + enroot／pyxis、H100／H200 節點、AWS EFA 網路為前提）、Megatron-LM、以及要訓練的資料。沒有叢集可以在 Hugging Face Jobs 租節點（手冊列出 `h200x8` 每小時約 40 美元）。

## 適用情境

- 已經在 GPU 叢集上訓練過 dense 模型、下一步想訓練 MoE 的工程師（作者設定的主要讀者）。
- MoE 訓練跑壞了（loss 爆掉、專家塌縮、吞吐量莫名下降），想對照症狀找原因的人。
- 想看懂 DeepSeek、Kimi、GLM 等前沿 MoE 為什麼這樣設計 router、共享專家與負載平衡的研究者或學生。

## 授權與成本

- 線上免費閱讀；Space 未標示授權。
- 親手跑需要多 GPU 節點，成本不低；第 2 章的單節點 MoE 是最低門檻。

## 限制與注意事項

- 篇幅很長（約 7 萬字），偏實戰，預設讀者已懂 dense 訓練、分散式平行化與 Megatron-LM。入門讀者可能需要先讀 Ultra-Scale Playbook。
- 實驗與結論大多來自 Hugging Face 自家叢集，換不同硬體、互連或框架時數字未必一樣。
- 指令以 Megatron-LM、Slurm、AWS EFA 環境為主，其他框架（如 DeepSpeed、TorchTitan）需自行對應。
- 「80 萬 GPU 小時」出自 Thomas Wolf 的 LinkedIn 貼文，手冊本身未見此數字。
- 不建議在手機上閱讀（互動圖表多）；英文。

## 相關工具

- [Train LLM From Scratch](Train-LLM-From-Scratch.md)：用純 PyTorch 手寫小型 MoE 與完整訓練流程，適合先理解原理；本條目則是叢集規模的實戰。
- [DeepInfer](../11-推論與訓練引擎/DeepInfer.md)：DeepSeek 的 MoE 推論框架，手冊第 4 章部署部分多次引用。
- [edge0](../11-推論與訓練引擎/edge0.md)：推論端的 MoE 專家卸載，可對照第 4 章「推論時的專家處理」。

## 資料來源

- https://huggingface.co/spaces/huggingface/moe-blogpost
- https://huggingface.co/spaces/huggingface/moe-blogpost/tree/main/app/src/content （手冊原始碼：article.mdx 與各章 .mdx）
- https://www.linkedin.com/posts/thom-wolf_18-of-the-20-best-open-models-today-are-mixture-of-experts-activity-7524199942492631040-orOZ
