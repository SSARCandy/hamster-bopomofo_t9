# 深入大腦：`rime.lua` (T9 智慧排序) 完全解析

這份文件詳細解釋了 `rime.lua` 腳本的運作原理。這個腳本是專門為了解決 T9 九宮格輸入法中「模糊輸入」與「精確匹配」之間的衝突，並在 v14 版本中引入了效能優化。

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
-- T9 智慧排序 v14 (配置常數化版)

-- 配置常數
local MAX_CANDS = 50        -- 處理候選字的最大數量
local TONE_PATTERN = "[qwxy]$" -- 聲調判斷正則

function t9_sort_filter(input, env)
    -- ...
```

### 1. 配置常數與效能優化
在 v14 版本中，我們將關鍵設定抽離成常數：
- `MAX_CANDS = 50`：這是為了效能考量。RIME 在處理非常模糊的輸入時，可能會產生數百個候選字。為了避免 Lua 腳本處理過久造成打字卡頓，我們只對前 50 個最相關的候選字進行智慧排序。
- `TONE_PATTERN = "[qwxy]$"`：定義了哪些字元代表聲調「定錨」。

### 2. 取得輸入與判斷「定錨 (Anchored)」
```lua
    local context = env.engine.context
    local input_str = context.input
    
    -- 只有當最後一個字元是聲調時，才啟用「強制完美匹配」提拔模式
    local is_anchored = input_str:match(TONE_PATTERN) ~= nil
```
程式碼會先讀取你目前輸入的這串代碼，並檢查最後一個字元是不是聲調鍵（我們定義的 `q, w, x, y` 分別代表一、二、三、四聲）。
- **是 (有聲調 `is_anchored = true`)**：代表使用者敲定了精確音節（例如 `bq` -> `ㄅˉ`），進入「定錨模式」。
- **否 (無聲調 `is_anchored = false`)**：使用者還在連續點擊數字鍵（例如連續按 `14` -> `ㄅ/ㄉ + ㄆ/ㄊ`），保持普通模糊模式。

### 3. 收集與分組 (Buckets)
```lua
    local cands = {}
    local count = 0
    
    -- 1. 收集前 N 個候選字
    for cand in input:iter() do
        count = count + 1
        cands[count] = cand
        if count >= MAX_CANDS then break end
    end
```
首先，腳本會先抓取前 50 個候選字存入記憶體陣列中。

```lua
    for i = 1, count do
        local cand = cands[i]
        local c_end = cand._end or cand["end"] or 0
        local cov = c_end - (cand.start or 0)
        
        -- ... 分組邏輯 ...
        
        -- 核心改動：只有在定錨模式下，且此字詞完美吃滿所有目前輸入代碼，才放入 perfect 陣列
        if is_anchored and c_end == input_len then
            table.insert(b.perfect, cand)
        else
            table.insert(b.others, cand)
        end
    end
```
腳本會遍歷收集到的候選字：
1. 依據字詞「覆蓋了多長的輸入代碼 (`cov`)」進行分組，確保長詞依然優先。
2. 將同一長度的候選詞拆成兩堆：**完美匹配 (perfect)** 與 **一般匹配 (others)**。

### 4. 輸出排序 (Yield)
```lua
    -- 3. 按覆蓋度從大到小輸出
    for i = max_cov, 0, -1 do
        local b = buckets[i]
        if b then
            -- 優先輸出完美匹配
            for _, cand in ipairs(b.perfect) do yield(cand) end
            -- 輸出其他匹配，保持原始 RIME 頻率順序
            for _, cand in ipairs(b.others) do yield(cand) end
        end
    end

    -- 4. 保底：輸出剩餘未處理的候選字
    for cand in input:iter() do
        yield(cand)
    end
```
最後，重新把候選字丟回給螢幕顯示：
1. **優先輸出**：先輸出長詞，且在定錨模式下優先輸出完美匹配字。
2. **保底輸出**：如果一開始因為 `MAX_CANDS` 限制而沒處理到的候選字，會在最後依序輸出，確保不會遺漏任何字。

## 總結

透過 v14 的優化，Lua 腳本能更安全、快速地達成以下效果：

- **當你打出聲調確認單一音節時**：腳本強行把「精確符合拼寫」的字拉到最前面。
- **當你沒有打聲調（長句連打模式）**：腳本完全不干預排序，保留 RIME 預設強大的 Viterbi 高頻連打預測。
- **效能防護**：透過 `MAX_CANDS` 限制，確保即便在極端模糊輸入下，輸入法依然能保持流暢不卡頓。
