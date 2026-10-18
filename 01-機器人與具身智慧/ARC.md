# ARC

- **分類**：機器人與具身智慧 / 研究
- **連結**：https://arc-robot-reasoning.github.io/

## 原清單說明

機器人基礎模型的推理訓練法：自動替既有示範資料標註「以動作為依據的因果推理」，再微調 π0.5 等 VLA，不需收新示範。程式碼與模型待釋出。

## 概述

ARC 的專案頁標題為「A Reasoning Recipe for Robot Foundation Models」，是一套讓既有機器人基礎模型學會推理的訓練方法。它不需要收集新的機器人示範資料，也不需要基礎模型等級的大規模訓練。做法是從既有示範資料中，自動還原出「以動作為依據」（action-grounded）的因果推理軌跡，再拿這些軌跡微調策略模型。

- 專案頁沒有說明 ARC 這個縮寫的全名。
- 作者列為「Anonymous authors」，目前處於匿名審稿階段，所屬機構資料不足。
- 頁面只提供論文 PDF（`assets/paper/arc-paper.pdf`），沒有 arXiv 編號。

## 核心功能／特色

- **不需新示範**：推理標註從現有的 DROID 示範資料自動產生，規模約 75K 個 episode、120 萬個與動作對齊的影格。
- **七段式因果推理軌跡（ARC-Trace）**：每段軌跡包含 state、cause、consequence、effect、action、avoidance、completion 七個部分。
- **適用多種策略架構**：頁面示範了兩種模型：
  - VLA：π0.5-DROID
  - WAM（world action model）：Cosmos3-Nano-Policy
- **反事實訓練**：與事實相符的樣本用 flow matching 訓練；與事實矛盾的推理軌跡則加上 counterfactual margin loss。
- **專案頁公布的成績**（皆為零樣本評測）：
  - RoboLab-120（預設指令）：Cosmos3-Nano-Policy 由 36.8% 升到 48.8%（+12.0 pp）；π0.5 由 28.0% 升到 45.3%（+17.3 pp）。
  - 真實機器人：π0.5 + ARC 成功率 91.7%，原本為 9.5%（+82.2 pp）。
  - RoboLab-Reasoning-50：Cosmos3-Nano-Policy + ARC 達 61.0%（+50.0 pp）。
  - MolmoSpaces：Cosmos3-Nano-Policy + ARC 任務成功率 57.6%（+18.6 pp）。
  - 頁面的主打說法是「推理密集任務成功率提高 5 倍以上」。
- **推論效率**：
  - π0.5 + ARC 只用 1 步 Euler 積分，表現就與 10 步的原始策略相差 0.4 pp 以內。
  - Cosmos3-Nano-Policy + ARC 用 2 步 UniPC 就勝過 4 步的原始策略。
  - 在 RoboLab-120 上，Cosmos3-Nano-Policy + ARC 達到基線 10K 次迭代的表現時，訓練更新次數少了約 4.3 倍。

## 技術架構或運作原理

1. **ARC-Trace 標註管線**：先從示範資料推導出 episode 情境與狀態檢查，再針對挑選出的關鍵影格，產生對齊的因果推理軌跡。消融實驗有比較不同的「外部推理器」（external reasoner），但頁面沒有寫明預設用哪個模型產生軌跡（資料不足）。
2. **聯合微調**：以 π0.5 為例，視覺語言骨幹、trace encoder 與 action expert 三者一起微調。
3. **部署方式**：
   - 背景有一個 VLM，持續根據相機畫面更新推理內容；示範影片中約每秒更新 1 次。
   - 策略本身以 15 Hz 執行，每次輸出 15 個動作的 chunk。

## 安裝與使用方式

資料不足。專案頁把程式碼、模型、資料集（ARC-Trace-DROID）與 RoboLab-Reasoning-50 基準都標為「Coming soon」，並寫明「Models, code, and ARC-Trace-DROID will be released after the review period」。目前沒有任何安裝指令可以使用。

## 適用情境

- 已有 π0.5 或 Cosmos Policy 這類 VLA／WAM 策略與示範資料，想加強推理密集型操作任務的研究者。
- 研究「推理軌跡監督」與「具身思維鏈」的人，可以參考它的資料標註方法。

## 授權與成本

- 授權：專案頁沒有標示（資料不足）。
- 成本：方法本身強調不必收集新示範。但微調 π0.5 等 VLA 需要多少 GPU 資源，頁面沒有說明（資料不足）。

## 限制與注意事項

- 程式碼、權重與資料集都還沒釋出，目前無法重現。
- 作者匿名、論文在審稿中，上面的數字都是作者自己報告的，尚未經同儕審查確認。
- 實驗以 DROID 資料與 Franka 類型的設定為主。能否推廣到其他機器人型態，頁面沒有完整說明（資料不足）。
- 名稱容易與 ARC-AGI 等同名專案混淆。

## 相關工具

- π0.5／openpi（Physical Intelligence 的 VLA）
- NVIDIA Cosmos Policy（Cosmos3-Nano-Policy）
- DROID 資料集
- RoboLab、MolmoSpaces（評測基準）

## 資料來源

- https://arc-robot-reasoning.github.io/
