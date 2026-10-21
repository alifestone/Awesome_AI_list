# Jellyfish

- **分類**：影片製作
- **連結**：https://github.com/Forget-C/Jellyfish

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：自架的 AI 短劇製作工作台（React＋FastAPI），流程是「劇本 → 分鏡拆解 → 鏡頭準備 → 圖片／影片生成 → 匯出」。本身不含模型，生成全走外部 API；內建供應商只有 OpenAI、火山引擎（圖片／影片）與阿里百鍊（文字）。

## 概述

Jellyfish 是給 AI 短劇／微短劇的製作工作台，不是單純的「AI 出圖／出片」工具。它把劇本拆成鏡頭，抽出角色、場景、道具、服裝與對白，集中管理這些素材以維持跨鏡頭一致，鏡頭確認就緒後再派發圖片與影片生成任務，所有長時間任務都進同一個非同步任務中心追蹤。

作者為 Forget-C。repo 於 2026-03-06 建立，查詢當下（2026-10-21）約 6.8k 顆星、1.1k forks，最新版 v0.3.2（2026-04-17），最後推送 2026-07-30。介面與文件以簡體中文為主，另有英文與日文 README。

## 核心功能／特色

- **劇本理解與分鏡拆解**：把章節劇本拆成鏡頭；抽取角色、場景、道具、服裝、對白；做劇本優化、精簡與一致性檢查。
- **鏡頭準備流程**：`劇本拆解 → 鏡頭準備 → 確認候選 → 鏡頭就緒 → 生成工作區`；可接受／忽略候選素材與對白、連結既有實體，用統一的就緒狀態判斷鏡頭能否生成。
- **素材一致性**：角色／演員、場景、道具、服裝是共用實體，可跨鏡頭重複使用並管理實體圖片。
- **鏡頭級生成**：管理關鍵幀與參考圖、預覽影片 prompt、生成前檢查，支援單鏡與批次生成，結果寫回鏡頭。
- **任務中心**：文字、圖片、影片任務統一追蹤狀態、耗時與結果，可取消，並跳回對應的專案／章節／鏡頭。
- **模型與 prompt 管理**：多供應商、多模型，依類別設預設模型；圖片、影片、鏡頭的 prompt 模板管理。
- **可擴充**：新供應商要在後端註冊能力規格、任務適配器與 HTTP 適配層（有文件說明）。

## 安裝與使用方式

Docker Compose（前端 7788、後端 8000，另起 MySQL、Redis、RustFS 物件儲存）：

```sh
git clone https://github.com/Forget-C/Jellyfish.git && cd Jellyfish
cp deploy/compose/.env.example deploy/compose/.env
docker compose --env-file deploy/compose/.env -f deploy/compose/docker-compose.yml up --build
# 開 http://localhost:7788，API 文件在 http://localhost:8000/docs
```

本機開發：後端 `cd backend && uv sync && uv run uvicorn app.main:app --reload --port 8000`；前端 `cd front && pnpm install && pnpm dev`。進去後要先在模型管理裡設定供應商與 API key。

文件站：https://forget-c.github.io/Jellyfish

## 適用情境

- 短劇／微短劇創作者、批次產出影片內容的 AI 工作室。
- 想把「劇本 → 分鏡 → 生成」管成可追蹤、可重用的製作流程，而不是一次性出片。
- 教育訓練或品牌電商的劇情式影片。
- 當自建 AI 影片流水線的後台參考（FastAPI、非同步任務、OpenAPI 產生前端型別）。

## 授權與成本

- **Apache-2.0**。
- 軟體免費；成本為各供應商的文字、圖片、影片 API 用量，以及自架伺服器。

## 限制與注意事項

- 內建供應商只有 OpenAI、火山引擎、阿里百鍊；要用其他模型（如可靈、Veo 或本機模型）需自行寫適配器。
- 介面與文件以簡體中文為主。
- 版本仍在 0.x，自 2026-04 的 v0.3.2 後未再發版。
- 部署要同時跑 MySQL、Redis 與物件儲存，比單機工具重。

## 相關工具

- [ViMax](ViMax.md)：同樣從劇本或小說做出角色一致的影片，但偏全自動多 agent。
- [PenShot](PenShot.md)：只做「劇本 → 分鏡提示詞」這一段。
- [OpenDirector](OpenDirector.md)：自架的 AI 影片工作室，以一句構想自動跑完整流程。
- [AI video drama platform](AI-video-drama-platform.md)：早期的 AI 短劇後端骨架。

## 資料來源

- https://github.com/Forget-C/Jellyfish （README、`backend/app/services/llm/provider_bootstrap.py`、`site/content/docs/guide/llm-provider-registration.md`）
