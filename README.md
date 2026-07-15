# RIME T9 注音九宮格方案

<p align="center">
  <img src="demo/demo.gif" width="30%" />
  <img src="demo/demo-t9.png" width="30%" />
  <img src="demo/demo-numpad.png" width="30%" />
</p>

本項目為 RIME 輸入法引擎量身打造的 T9 (3x4) 九宮格注音輸入方案，特別針對 iOS 上的 **倉輸入法 (Hamster)** 進行了深度優化。

## 🌟 特色功能

- **九宮格佈局**：符合傳統手機使用習慣的注音九宮格排列。
- **純淨繁體字**：內建全繁體高權重字典，無須繁簡轉換器拖慢效能。
- **精確選注音**：長按即可選擇精確注音，實現「所選即所得」。
- **快捷標點號**：空白鍵長按可快速輸入 `，` `。` `？` `！`。
- **獨立聲調鍵**：獨立聲調鍵（ˉ ˊ ˇ ˋ），支援精確過濾。
- **有數字鍵盤**：可以快速切換成九宮格數字鍵盤。

## 📁 目錄結構

```
bopomofo_t9/     RIME 方案本體（元書 RimeUserData 的內容，壓縮此資料夾即可導入）
  ├ bopomofo_t9.schema.yaml   方案
  ├ bopomofo_t9.dict.yaml     字典
  ├ rime.lua                  智慧排序腳本
  └ lua/wanxiang/             自動聯想模組
yuanshu-skin/    元書鍵盤皮膚原始碼（jsonnet，打包成 .cskin）
tests/           迴歸測試台（電腦上跑真實 librime 引擎驗證候選）
demo/            截圖
```

## 🛠️ 安裝步驟（元書輸入法）

> 倉輸入法 (Hamster) 已停止維護，本方案已遷移至同作者的 [元書輸入法](https://apps.apple.com/app/id6744464701)。舊版倉輸入法的安裝方式見文末。

### 1. 導入 RIME 方案
1. 下載兩個外部檔案放進 `bopomofo_t9/` 資料夾（repo 不附大檔）：
   - `zh-hant-t-essay-bgw.gram` (語法模型，[下載](https://github.com/lotem/rime-octagram-data/raw/hant/zh-hant-t-essay-bgw.gram)，強烈建議)
   - `essay.txt` (預設詞彙表，[下載](https://raw.githubusercontent.com/rime/rime-essay/master/essay.txt)；組句品質的關鍵，部分輸入法已內建，一併放入可確保生效)
2. 把整個 `bopomofo_t9/` 資料夾壓縮成 zip（UTF-8 編碼），傳到 iPhone（AirDrop / iCloud），**用元書開啟**，會自動導入到 `RimeUserData/bopomofo_t9/`。
   - 也可改用元書的「WiFi 檔案傳輸」把檔案直接放進 `RimeUserData/bopomofo_t9/`。
3. 在元書「輸入方案」頁 → 右上角 `…` → **方案目錄切換** → 選 `bopomofo_t9`，並重新部署。
4. 選擇輸入方案 **注音九宮格**。

### 2. 安裝鍵盤皮膚
1. 將 `yuanshu-skin/` 打包成皮膚檔：內容須包在一層資料夾裡壓縮成 zip（**檔案不能直接放在 zip 根目錄**），再把副檔名改為 `.cskin`。
   打包前先在 `yuanshu-skin/` 目錄產生編譯產物：`jsonnet -S -m . --tla-code debug=true jsonnet/main.jsonnet`（或導入後在手機上長按皮膚 → 運行 `main.jsonnet`）。
2. 把 `.cskin` 傳到 iPhone 後點開，元書會自動導入。
3. 在元書皮膚列表選用「T9注音九宮格」。

### 3. 自訂皮膚（可選）
- 鍵位與長按：`jsonnet/Buttons/LayoutT9Zhuyin.libsonnet`
- 工具列按鈕、主題色等：`jsonnet/Settings.libsonnet`
- 修改後長按皮膚 → 「運行 main.jsonnet」重新編譯即生效，詳見 `yuanshu-skin/README.md`。

## 🔮 自動聯想

上屏後自動跳出下一個詞的聯想候選，採用[萬象拼音](https://github.com/amzxyz/rime_wanxiang)的
`user_predict.lua`（純 librime-lua 實作，不依賴 librime-predict 插件，
元書／倉輸入法皆可用）。安裝時將 `lua/` 資料夾連同方案檔一併導入即可。

- **從你上屏的詞自動學習**（資料存在使用者目錄 `predict.userdb`）：
  剛安裝時沒有聯想，連續打過的詞組出現幾次後就會浮現，愈用愈準。
  前後兩次上屏間隔 30 秒內都算同一語境（`context_timeout` 可調）；
  整句一次上屏也會以句尾當上文學習接續詞。
- 聯想時直接按注音鍵可繼續打字（此時「上一詞→你接著打的詞」照樣會被
  學進資料庫，聯想猜錯幾次後就會被你常用的接續詞蓋過）；退格清除聯想。
- 方案選單可切換「開啟／關閉預測」；聯想數量與連續輪數可在 schema 底部
  `user_predict:` 區塊調整（`mobile_predict_style: off` 可整組關閉）。

## 🚀 語法模型說明

長句自動斷詞的品質透過 n-gram 語法模型大幅提升（octagram 插件）。`bopomofo_t9.schema.yaml` 已預設啟用 `grammar:` 區塊，只要 `.gram` 模型檔與方案檔一起導入即可生效；若不使用語法模型，把 schema 中的 `grammar:` 區塊與 `translator/contextual_suggestions`、`max_homophones` 註解掉即可。

<details>
<summary>舊版：倉輸入法 (Hamster) 安裝方式（已停止維護）</summary>

1. 在 iOS 設備上安裝 [倉輸入法 (Hamster)](https://apps.apple.com/app/id6446617683)。
2. 將 `bopomofo_t9/` 內的 `bopomofo_t9.schema.yaml`、`bopomofo_t9.dict.yaml`、`rime.lua` 與舊版鍵盤佈局檔 `t9bopomo.yaml` 放入 Hamster 的 RIME 用戶目錄。
   - `t9bopomo.yaml` 已自本倉庫移除（元書改用 `yuanshu-skin/` 皮膚），需要的話請至 git 歷史取得（最後存在於 2026-07-11 之前的版本）。
3. 在 Hamster App 中進入 **鍵盤佈局**，導入並啟用 `t9bopomo.yaml`。
4. 在 Hamster App 首頁點擊 **RIME** -> **重新部署**，並於 **輸入方案設定** 選擇 **注音九宮格**。
5. 語法模型：將 `.gram` 放入 RIME 使用者目錄（與 schema 同層）後重新部署。

</details>

## 🧪 迴歸測試

改動 schema／字典／rime.lua 後，可在電腦上用真實 librime 引擎驗證（詳見 `tests/README.md`）：

```
python tests/setup_bench.py   # 第一次：下載 librime 引擎與詞彙表（~30MB）
python tests/run_tests.py     # 跑全部迴歸測試
python tests/bench.py "6q=吃"  # 臨時查某個鍵序的候選排名
```

## 💡 長句輸入技巧

- 打完整串注音後，若整句猜測不對，直接從候選列挑出正確的**第一段**（候選列前端會輪流出現各種長度的首段選擇），選完 RIME 會對剩餘輸入繼續出候選，一段一段選完自動上屏。
- **在同一次輸入內分段選完**（不要分次上屏），RIME 會把整句記進使用者詞典——下次輸入同樣的編碼，整句會直接出現。
- 多打聲調：聲調鍵同時是「精確過濾」與「斷詞錨點」，斷錯位置的候選會被自動壓到最後。


## 🔗 相關連結
- [元書輸入法 (App Store)](https://apps.apple.com/app/id6744464701)
- [元書輸入法文件（含皮膚格式）](https://ihsiao.com/apps/hamster/v3/docs/guides/skins/structure/)
- [Hamster GitHub](https://github.com/imfuxiao/Hamster)（舊版）
- [RIME 官網](https://rime.im/)
