# moli

- **分類**：瀏覽器自動化
- **連結**：https://github.com/lexmount/moli

## 原清單說明

（投稿時僅附連結，無原清單說明）

> **查證結果**：依 GitHub 頁面與 README 整理。README 自稱「給 AI agent 用的生產級無頭瀏覽器」，授權為 Apache-2.0 或 MIT 擇一。查詢當下約 21.3k 顆星、574 個 forks。以下效能數據為專案自行測試的結果，尚未獨立驗證。

## 概述

moli 是 Lexmount 以 Rust 撰寫的開源無頭瀏覽器，目標是讓 AI agent 抓取網頁、搜尋與執行瀏覽器任務。它不是包裝 Chromium 的工具，README 明確表示它是獨立的瀏覽器核心，自行實作 JavaScript、DOM、CSS、網路與儲存。

## 核心功能／特色

- **抓取與輸出**：`moli fetch` 可輸出 Markdown、HTML、JSON 或語意文字樹，適合餵給 LLM。
- **單一執行檔**：同時提供 CDP、WebDriver Classic 與 WebDriver BiDi 介面，不需另外安裝 ChromeDriver 或瀏覽器。
- **可接 Playwright**：`moli serve` 啟動自動化伺服器，Playwright 可透過 CDP 連線。
- **選用版面配置**：加上 `--layout` 才計算真實幾何與截圖，預設以 DOM 為主，較省資源。
- **資源控制**：可設定 profile、cookies、proxy，並可選擇是否載入媒體類型。

## 技術架構或運作原理

- 採用 DOM 優先設計，版面與繪製「只在需要時」才執行，因此記憶體佔用低。
- 專案自報的測試：在 192 個公開網址的抓取中，moli 產出 103 份有效頁面，Chrome Headless 為 101 份；中位數 RSS 約 73 MiB，Chrome 約 773 MiB。

## 限制

- 沒有圖形介面、常駐視窗、GPU 合成器，也不保留多幀繪製架構。
- 不追求與 Chrome 的像素級一致，也不提供高擬真的 Canvas／WebGL／媒體播放。
- `--layout` 模式下，部分 Chrome 的截圖或列印模式尚未實作。
- 自報的 Lexbench 結果中，moli 通過率為 81.88%，Chrome 為 99.85%，顯示相容性仍有明顯差距。

## 安裝與使用方式

```sh
curl --proto '\=https' --tlsv1.2 -fsSL \
  https://github.com/lexmount/moli/releases/latest/download/moli-installer.sh | sh

moli fetch --dump markdown --wait-until done https://example.com
moli serve   # 啟動自動化伺服器，供 Playwright 透過 CDP 連線
```

目前安裝指令為 Linux 與 macOS 用；其他平台請參考 README。
