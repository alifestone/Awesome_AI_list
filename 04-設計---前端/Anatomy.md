# Anatomy

- **分類**：設計 / 前端 / 網頁 3D
- **連結**：https://github.com/thebuggeddev/anatomy

## 原清單說明

用 Three.js 做的互動式 3D 人體解剖瀏覽器（由 GPT 生成），偏參考作品而非工具。

> **查證補充**：repo 簡介原文為「An interactive 3D human anatomy explorer built using threejs with GPT 5.6 Sol」，即作者自述以 GPT 5.6 Sol 協助建置。從原始碼看，它是「逐一器官」的 3D 檢視器（目前 9 個器官），並非完整全身解剖模型；「偏參考作品而非工具」的判斷成立。

## 概述

一個以 Next.js（透過 vinext 在 Vite／Cloudflare 環境執行）+ Three.js 打造的互動式人體器官 3D 教學網站。使用者可選擇器官、旋轉檢視 3D 模型、點選標註熱點（hotspot）查看結構名稱，並有標註測驗模式與多語系介面。

repo 於 2026-08 建立、主要語言 TypeScript，截至 2026-10-13 約 3.5k 顆星、主分支 9 個 commit。

## 核心功能／特色

依 `app/lib/anatomy-data.ts`、`app/components/*.tsx`、`app/i18n/config.ts` 原始碼確認：

- **9 個器官的 3D 模型**：心臟、腦、肺、肝、腎、眼球、腸、胰臟、皮膚，各自載入一個 `.glb` 模型（如 `/models/heart.glb`）。
- **解剖熱點標註**：每個器官有多個結構熱點（例如心臟的主動脈、左右心房、左右心室、二尖瓣），以 Terminologia Anatomica（TA2）拉丁術語為跨語系的標準鍵值。
- **標註測驗（LabelQuiz）**：隨機順序詢問每個結構，點錯時會同時標示正確位置並計分。
- **其他介面元素**：課程（lesson）、動畫、系統介紹等彈窗；自動旋轉、對照（compare）模式；部分器官附有顯微、位置、比較等插圖（`.webp`）。
- **12 種語系**：英、西、印地、中（簡體）、阿拉伯（RTL）、葡、法、德、日、俄、印尼、韓；並處理 RTL 文字中數字範圍的顯示方向。

## 技術架構或運作原理

- 前端：React 19 + Next.js 16，以 vinext 0.0.50 建置；Three.js 0.185 負責 3D 檢視（`app/lib/three/viewer`）；GSAP 動畫；Tailwind CSS 4；lucide-react 圖示。
- 後端／部署骨架：沿用一個「vinext-starter」範本（含可選的 Cloudflare D1、Drizzle ORM、`.openai/hosting.json` 綁定設定與 ChatGPT 登入輔助函式）。**README 內容就是這份範本的說明，並未介紹解剖瀏覽器本身。**
- 器官資料結構與翻譯內容分離：結構（位置、顏色、模型路徑）放在 `anatomy-data.ts`，文字放在各語系字典。

## 安裝與使用方式

README（範本）提供的指令，需 Node.js ≥ 22.13.0：

```bash
git clone https://github.com/thebuggeddev/anatomy.git
cd anatomy
npm install
npm run dev      # 本機開發
npm run build    # 建置
```

- repo 標示的線上展示網址 https://anatomyatelier.vercel.app 在 2026-10-13 查詢時回傳 HTTP 402（Vercel `DEPLOYMENT_DISABLED`），目前無法線上瀏覽。
- 是否能在不設定 Cloudflare D1／R2 綁定的情況下直接本機執行：資料不足（未實測）。

## 適用情境

- 參考「用 AI 程式助手產出 Three.js 互動 3D 教學網站」的成果與程式結構。
- 參考 3D 模型熱點標註、測驗互動、多語系（含 RTL）處理的實作方式。
- 不適合直接作為醫學教學或臨床參考工具使用。

## 授權與成本

- **授權**：repo 未附 LICENSE 檔，GitHub 未偵測到授權。依預設即保留所有權利，重用程式碼或模型前應先向作者確認。
- **3D 模型與插圖來源**：`.glb` 模型與 `.webp` 插圖的出處與授權資料不足。
- **成本**：原始碼可免費閱讀；自行部署的主機費用依平台而定。

## 限制與注意事項

- README 是範本說明，缺乏專案本身的使用文件。
- 線上展示已停用（HTTP 402）。
- 只有 9 個器官，不是完整人體系統（骨骼、肌肉、神經等全身結構未涵蓋）。
- 解剖內容的正確性未經專業審核的資料，使用時請自行查證。
- 由 AI 協助產生的程式碼，維護與長期更新狀況資料不足。

## 相關工具

- [Three.js](https://threejs.org/)、[GSAP](https://gsap.com/)
- [vinext](https://github.com/cloudflare/vinext)（Cloudflare 的 Vite 版 Next.js 相容層）
- 同資料夾：TheLongSilence（另一個由 AI 打造的瀏覽器 3D 作品）

## 資料來源

- https://github.com/thebuggeddev/anatomy （repo 首頁、README、目錄結構）
- https://api.github.com/repos/thebuggeddev/anatomy （repo 中繼資料：簡介、授權、星數、首頁網址）
- https://raw.githubusercontent.com/thebuggeddev/anatomy/HEAD/package.json
- https://raw.githubusercontent.com/thebuggeddev/anatomy/main/app/lib/anatomy-data.ts
- https://raw.githubusercontent.com/thebuggeddev/anatomy/main/app/i18n/config.ts
- https://raw.githubusercontent.com/thebuggeddev/anatomy/main/app/components/AnatomyApp.tsx
- https://raw.githubusercontent.com/thebuggeddev/anatomy/main/app/components/OrganViewer.tsx
- https://github.com/thebuggeddev/anatomy/tree/main/app 、https://github.com/thebuggeddev/anatomy/tree/main/app/components
- https://anatomyatelier.vercel.app （查詢結果：HTTP 402 DEPLOYMENT_DISABLED）
