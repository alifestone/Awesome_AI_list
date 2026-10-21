# 🤖 機器人與具身智慧

讓 AI 理解物理空間、控制機器人的工具與研究：從機器人基礎模型的訓練方法、空間推理 agent，到物理模擬器、操作任務基準測試，用 LLM 直接指揮機器人的工具，以及全開源的人形機器人硬體平台。

## 研究

### [ARC](ARC.md)

一套讓既有機器人基礎模型學會「推理」的訓練方法。它從既有的示範資料中，自動還原出以動作為依據的因果推理軌跡，再拿來微調 π0.5 等 VLA 策略模型，不需要收集新示範。

可以做到：
- 不收新資料，就替既有的 VLA／WAM 策略加強推理密集型的操作任務。
- 參考它的資料標註方法，研究推理軌跡監督與具身思維鏈。
- 目前是匿名審稿中的論文，程式碼與模型尚未釋出。

### [SpatialClaw](SpatialClaw.md)

NVIDIA 與 KAIST 的空間推理 agent（NeurIPS 2026）。主張「程式碼才是空間推理 agent 該用的動作介面」：VLM 在持久的 Jupyter kernel 裡寫 Python，呼叫 SAM3、Depth-Anything-3 等感知工具並檢查中間結果。

可以做到：
- 回答圖片、多視角、影片與 4D 場景的空間問題（距離、方位、視角轉換、動態關係）。
- 不微調模型，就替既有 VLM 加上幾何與感知工具。
- 比較「寫程式」與「結構化 tool call」兩種 agent 動作介面。

## 模擬

### [MuJoCo](MuJoCo.md)

Google DeepMind 維護的通用物理引擎，專門模擬會和環境接觸、互動的多關節結構，是機器人與強化學習研究的標準模擬器。Apache-2.0。

可以做到：
- 機器人控制、強化學習與 sim-to-real 前的策略訓練。
- 生物力學與肌肉骨骼模擬。
- 用 MJX／MuJoCo Warp 在 GPU 上大規模平行訓練。
- 當其他具身 AI 專案的底層模擬器（例如 quackd）。

## 基準測試

### [LIBERO](LIBERO.md)

UT Austin 的機器人操作基準（NeurIPS 2023），原本用來研究終身學習中的知識轉移：130 個語言指令任務分成 LIBERO-Spatial／Object／Goal／100 四組，附人類遙操作示範與基線演算法。建立在 robosuite（MuJoCo）上。程式碼 MIT，資料集 CC BY 4.0。

可以做到：
- 研究機器人依序學新任務時的知識轉移與遺忘問題。
- 評測 VLA 或模仿學習策略，和 OpenVLA、π0 等論文的 LIBERO 成功率直接比較。
- 用 BDDL 自訂新的操作任務，或拿現成示範資料訓練策略。

## LLM 控制

### [quackd](quackd.md)

用 LLM 指揮機器人的命令列工具。先註冊機器人，再從終端機、Claude（MCP）或 `.duck` 任務檔下達目標；LLM 每一步從機器人的技能清單挑一個動作執行，quackd 負責限制允許的技能、步數上限與何時需要人類確認。主要對象是 Pollen Robotics 的 Microduck（原清單誤標為 LeRobot）。

可以做到：
- 用自然語言或和 Claude 對話，指揮機器人完成目標導向的任務。
- 沒有硬體時，先在 2D 或 MuJoCo 模擬器驗證 LLM agent 迴圈。
- 替 LeRobot SO-101 手臂接上 LLM 高層規劃。
- 讓多台機器人組成「flock」分工合作。

## 開源硬體平台

### [RP1](RP1.md)

RoboParty 的全開源人形機器人：身高 1.35 m、約 39 kg、24／30 自由度、跑速 ≤4 m/s。機構 SolidWorks 原始檔、PCB、線材、BOM、自研關節模組與韌體、Linux BSP、ROS 2 部署框架、URDF／MJCF，到 Isaac Lab 的行走與動作模仿訓練全部公開。⚠️ 總覽 repo 只是索引，內容分散在十多個子 repo，授權各不相同，部分沒有授權檔。

可以做到：
- 照著 CAD、PCB 與 BOM 自製或改裝一台人形機器人。
- 用 URDF／MJCF 在 Isaac Lab 或 MuJoCo 訓練行走、AMP、BeyondMimic 等策略，再部署到實機。
- 研究行為基礎模型（UFO、P-BFM、I-BFM）與從意圖到動作的學習（INTACT-JEPA）。

## 怎麼挑

- 想**訓練或研究機器人模型**：看 ARC。
- 想讓 **VLM 理解 3D 空間**：看 SpatialClaw。
- 需要**模擬環境**：MuJoCo；要**評測操作策略或 VLA**：LIBERO；要**寫實的模擬場景**，見 3D 類的 [3DGS for model city](../02-3D-建模與生成/3D-Gaussian-Splatting-for-model-city.md)（實景重建進 Isaac Sim）、[World Labs](../02-3D-建模與生成/World-Labs.md)、[HY-World 2.0](../02-3D-建模與生成/HY-World-2.0.md)（生成可匯出的 3D 世界）與 [Kit USD Agents](../02-3D-建模與生成/Kit-USD-Agents.md)（Isaac Sim 開發）。
- 想**直接用 Claude 指揮機器人**：quackd。
- 想要**整台都能看到原始設計的人形機器人**（硬體、韌體到訓練）：RP1。
