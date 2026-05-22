-- rime.lua
-- T9 智慧排序 v14 (配置常數化版)

-- 配置常數
local MAX_CANDS = 50        -- 處理候選字的最大數量（超過則不排序直接輸出）
local TONE_PATTERN = "[qwxy]$" -- 聲調判斷正則（q:1, w:2, x:3, y:4）

function t9_sort_filter(input, env)
    local context = env.engine.context
    local input_str = context.input
    if not input_str or input_str == "" then return end

    local input_len = #input_str
    -- 只有當最後一個字元是聲調時，才啟用「強制完美匹配」提拔模式
    local is_anchored = input_str:match(TONE_PATTERN) ~= nil

    local cands = {}
    local count = 0
    
    -- 1. 收集前 N 個候選字
    for cand in input:iter() do
        count = count + 1
        cands[count] = cand
        if count >= MAX_CANDS then break end
    end
    
    if count == 0 then return end

    -- 2. 分組與計算覆蓋度
    local buckets = {}
    local max_cov = 0
    
    for i = 1, count do
        local cand = cands[i]
        -- 兼容性處理：有些版本的 RIME 使用 _end，有些使用 end
        local c_end = cand._end or cand["end"] or 0
        local c_start = cand.start or 0
        local cov = c_end - c_start
        
        if cov > max_cov then max_cov = cov end
        
        local b = buckets[cov]
        if not b then 
            b = { perfect = {}, others = {} }
            buckets[cov] = b
        end
        
        -- 核心邏輯：在定錨模式下，提拔完美匹配（吃滿目前所有輸入長度）的候選字
        if is_anchored and c_end == input_len then
            table.insert(b.perfect, cand)
        else
            table.insert(b.others, cand)
        end
    end

    -- 3. 按覆蓋度從大到小輸出
    for i = max_cov, 0, -1 do
        local b = buckets[i]
        if b then
            -- 優先輸出完美匹配
            for _, cand in ipairs(b.perfect) do
                yield(cand)
            end
            -- 輸出其他匹配，保持原始 RIME 頻率順序
            for _, cand in ipairs(b.others) do
                yield(cand)
            end
        end
    end

    -- 4. 保底：輸出剩餘未處理的候選字
    for cand in input:iter() do
        yield(cand)
    end
end
