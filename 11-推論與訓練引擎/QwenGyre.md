# QwenGyre

- **分類**：推論與訓練引擎
- **連結**：https://arxiv.org/abs/2609.33848

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：阿里巴巴（Alibaba Token Hub）提出的強化學習（RL）**訓練框架論文**，專門用來訓練單次執行要跑好幾小時的 xLong-horizon agent。查詢當下（2026-10-21）**只有論文，沒有公開程式碼或安裝包**，arXiv 頁面與各家報導都沒有 GitHub 連結。

## 概述

QwenGyre 解決的是「用線上 RL 訓練超長任務 agent」的兩個問題：每次 rollout 可能跑數小時、數百次模型與環境互動、用掉約 70 萬～100 萬 token，執行時間差異極大，GPU 常在等慢的 rollout 而閒置；而且 agent 會分支（主 agent、子 agent、摘要），產生大量重複的軌跡，拖慢訓練。

它的做法是讓 GPU 在 rollout 與訓練兩種角色之間彈性切換，而且切換時不中斷正在跑的 agent 執行；另外用軌跡處理器重建分支歷史、替逾時的執行打部分分數、並刪掉重複路徑，控制訓練成本。

論文作者為 Weiqi Wang、Yuxin Zhou、Mouxiang Chen 等 12 人。v1 於 2026-09-27 提交，v2 於 2026-10-20 更新。實驗用的是 Qwen 3.6 122B 與旗艦 Qwen 3.8 2.4T。

## 核心功能／特色

- **彈性排程器（Elastic Scheduler）**：把 GPU 切成 K 個訓練佈局相同的 elastic cell，另可加一個獨立 rollout 池。依「水位」（未完成的執行數）決定各 cell 做 rollout 或訓練。core cell 保存權重與 optimizer 狀態，satellite cell 拉權重後加入進行中的 batch。
- **不中斷的角色切換**：用 proxy 在切換時改導模型呼叫，KV cache 可經 RDMA 搬移，harness 與 sandbox 保持存活。rollout → 訓練約 8.5 秒，訓練 → rollout 約 3.5 秒，相對於數小時的 rollout 可忽略。
- **串流訓練**：packing buffer 產生 micro-step，由各 cell 原子性領取，快的 cell 多做；搭配 1F1B pipeline。
- **軌跡處理器（Trajectory Processor）**：以 token-in／token-out 記錄確切的 token ID 與 log-prob，把執行紀錄存成共享前綴的軌跡樹，不必展開完整歷史。
- **部分評分**：逾時的執行仍評估已完成的部分，並區分「評分器失敗」與「真的 0 分」。
- **去重與取樣上限**：共享前綴只訓練一次，只有 policy 生成的 token 可訓練；每次執行最多取 5 條軌跡（主 agent > 主摘要 > 子 agent > 子摘要），loss 在執行內平均。上限 5 比不設限少 25.2% forward-backward 時間，分數相當。

## 技術架構或運作原理

- 訓練：Megatron；rollout：SGLang；權重傳輸：Mooncake Transfer Engine。
- RL 演算法：改編的 GSPO（token importance weight 上限 5、序列層級 clip [0.995, 1.005]、Adam 固定學習率 1e-6）。
- Agent harness：Claude Code 2.1.220。
- 比較基準：
  - **Colocate**：同一批 GPU 輪流做 rollout 與訓練。
  - **Async**：rollout 與訓練各用固定的 GPU 池。

論文自測結果（48 或 24 步）：

| 設定 | 對 Async | 對 Colocate |
|---|---:|---:|
| Qwen 3.6 122B，NL2RepoBench（32 節點） | 1.42–1.53× | 1.36–1.47× |
| Qwen 3.6 122B，DeepSWE（24 節點） | 1.57× | 1.61–1.82× |
| Qwen 3.6 122B，TerminalBench（24 節點） | 1.38–1.43× | 1.81–1.85× |
| Qwen 3.8 2.4T，NL2RepoBench（4 × 48 節點） | 1.78×（75.4 h vs 134.6 h） | 1.21× |

Qwen 3.8 2.4T 在 NL2RepoBench 的通過率 48 步內從 52.48% 提升到 58.54%；各設定的訓練分數與基準相當。

## 安裝與使用方式

資料不足：目前沒有公開程式碼、套件或安裝說明，只能閱讀論文（arXiv 提供 PDF、HTML、TeX 原始檔）。

## 適用情境

- 研究或設計長時間 agentic RL 的訓練基礎設施（rollout 與訓練的 GPU 排程、分支軌跡處理）。
- 參考其軌跡樹、部分評分、取樣上限等做法，改進自己的 RL 管線。

## 授權與成本

- 論文依 arXiv 授權公開閱讀；框架本身未釋出，無軟體授權可言。
- 論文實驗規模為 24～192 個節點，屬資料中心等級。

## 限制與注意事項

- **沒有程式碼**：目前只是論文，無法直接使用；報導中的數字皆為阿里團隊自測。
- 彈性排程需要多個可獨立切換的 cell，GPU 預算很小時可能無法運作，論文也未評估小規模效率。
- 每次 burst 訓練多步（μ > 1）時，串流訓練無法在 minibatch 間全域打亂資料；樣本順序對學習品質的影響未獨立驗證。
- 論文摘要說每次 rollout 約 70 萬 token，引言說近 100 萬 token，未說明差異。
- 未公開 GPU 型號與互連硬體（只提到 RDMA）。

## 相關工具

- [Unsloth](Unsloth.md)：本清單收錄的開源訓練框架，可在單張 GPU 做 GRPO 等 RL 訓練；規模與用途和 QwenGyre 完全不同。
- 論文引用的相關系統：HybridFlow、ReaL、StreamRL、AReaL-DTE（未逐一查證）。

## 資料來源

- https://arxiv.org/abs/2609.33848 （論文摘要頁，v2 2026-10-20）
- https://arxiv.org/html/2609.33848 （論文 HTML 全文）
- https://www.marktechpost.com/2026/10/12/alibaba-qwen-introduces-qwengyre-elastic-reinforcement-learning-rl-for-xlong-horizon-agents/ （使用者提供；查詢時回 403 無法讀取）
- https://rits.shanghai.nyu.edu/ai/qwen-releases-qwengyre-for-long-horizon-agent-rl-training/
- https://ai-bot.cn/qwengyre/ （指出目前僅發表論文，未公開程式碼）
