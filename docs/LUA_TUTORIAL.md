# 深入大腦：`rime.lua` (T9 智慧排序) 完全解析

這份文件詳細解釋了 `rime.lua` 腳本的運作原理。這個腳本是專門為了解決 T9 九宮格輸入法中「模糊輸入」與「精確匹配」之間的衝突。

## 為什麼需要這個 Lua 腳本？

在 T9 鍵盤上，一個數字按鍵（例如 `1`）同時代表了多個注音符號（如 `ㄅ、ㄉ、ㄚ`）。
RIME 引擎預設是依照「字頻（詞頻）」來排序候選詞。

假設字典中「的 (ㄉ)」的字頻極高。
如果你透過長按 `1` 鍵送出了精確的字母 `b` (代表 `ㄅ`)，並且加上了聲調 `q` (一聲)，你的實際輸入代碼會變成 `bq`。
如果沒有額外的干預，即使你已經精確指定了 `b`，RIME 在模糊運算時，仍有可能因為「的」的字頻太高，而把「的」排在真正符合 `b` 發音的「吧(ㄅ)」前面。這會導致你明明精確輸入了，卻還要往後翻找候選字。

`rime.lua` 腳本就是為了解決這個痛點：**在使用者明確輸入聲調（定錨）時，強行將「完全吻合」的候選字提拔到最前面。**

---

## 腳本原始碼解析

打開專案根目錄的 `rime.lua`，你會看到以下程式碼：

```lua
-- rime.lua
-- T9 智慧排序 v11 (雙模優化版)

function t9_sort_filter(input, env)
    -- ...
```

### 1. 取得輸入與判斷「定錨 (Anchored)」
```lua
    local context = env.engine.context
    local input_str = context.input
    local input_len = #input_str
    
    -- 只有當最後一個字元是聲調時，才啟用「強制完美匹配」提拔模式
    local is_anchored = input_str:match("[qwxy]$") ~= nil
```
程式碼會先讀取你目前輸入的這串代碼，並檢查最後一個字元是不是聲調鍵（我們定義的 `q, w, x, y` 分別代表一、二、三、四聲）。
- **是 (有聲調 `is_anchored = true`)**：代表使用者敲定了精確音節（例如 `bq` -> `ㄅˉ`），進入「定錨模式」。
- **否 (無聲調 `is_anchored = false`)**：使用者還在連續點擊數字鍵（例如連續按 `14` -> `ㄅ/ㄉ + ㄆ/ㄊ`），保持普通模糊模式。

### 2. 收集與分組 (Buckets)
```lua
    local buckets = {}
    local max_cov = 0
    
    for i = 1, #cands do
        local cand = cands[i]
        local c_end = cand._end or cand["end"] or 0
        local cov = c_end - cand.start  -- 計算這個字詞「吃掉」了多少輸入代碼 (cov = 覆蓋長度)
        
        if cov > max_cov then max_cov = cov end
        
        if not buckets[cov] then 
            buckets[cov] = { perfect = {}, others = {} } 
        end
        
        -- 核心改動：只有在定錨模式下，且此字詞完美吃滿所有代碼，才放入 perfect 陣列
        if is_anchored and c_end == input_len then
            table.insert(buckets[cov].perfect, cand)
        else
            -- 模糊連打，或是長度不完美的字，放入 others 陣列
            table.insert(buckets[cov].others, cand)
        end
    end
```
腳本會遍歷 RIME 引擎初步查出來的候選字列表：
1. 依據字詞「覆蓋了多長的輸入代碼 (`cov`)」進行分組，確保長詞依然優先。
2. 將同一長度的候選詞拆成兩堆：**完美匹配 (perfect)** 與 **一般匹配 (others)**。

### 3. 輸出排序 (Yield)
```lua
    -- 輸出邏輯
    for i = max_cov, 1, -1 do
        local b = buckets[i]
        if b then
            -- 定錨模式下，perfect 優先輸出
            for _, cand in ipairs(b.perfect) do yield(cand) end
            
            -- 非定錨模式下，perfect 陣列為空，others 保留 RIME 原始頻率順序輸出
            for _, cand in ipairs(b.others) do yield(cand) end
        end
    end
```
最後，重新把候選字丟回給螢幕顯示。
由於我們在程式邏輯中，強制把 `perfect` 群組排在 `others` 前面輸出，因此能達到以下雙模效果：

- **當你打出聲調確認單一音節時**：腳本強行把「精確符合拼寫」的字拉到最前面。
- **當你沒有打聲調（長句連打模式）**：`perfect` 群組會是空的，所有字都在 `others` 裡，這代表腳本**完全不干預排序**，完美保留 RIME 預設強大的 Viterbi 高頻連打預測。

透過這個 Lua 過濾器，我們成功兼顧了「模糊長句盲打」與「單字精確輸入」的最佳打字體驗！
