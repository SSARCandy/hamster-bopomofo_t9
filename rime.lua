-- T9 智慧排序：全碼 > 短詞(2-3碼) > 單字(1碼)
function t9_sort_filter(input, env)
    local context = env.engine.context
    local input_str = context.input
    local input_len = #input_str

    if input_len <= 1 then
        for cand in input:iter() do yield(cand) end
        return
    end

    local full_matches = {}
    local single_chars = {}      -- 1 碼
    local short_words_2 = {}     -- 2 碼
    local short_words_3 = {}     -- 3 碼
    local others = {}

    -- 取得目前正在編碼的那一段的起始位置
    local segment = context.composition:back()
    local start_pos = segment.start

    -- 分類收集候選字
    local count = 0
    for cand in input:iter() do
        count = count + 1
        local coverage = cand._end - cand.start
        
        -- 修改：判斷是否為「目前游標位置」開始的候選字
        if cand.start == start_pos then
            if coverage == input_len - start_pos then
                table.insert(full_matches, cand)
            elseif coverage == 1 then
                table.insert(single_chars, cand)
            elseif coverage == 2 then
                table.insert(short_words_2, cand)
            elseif coverage == 3 then
                table.insert(short_words_3, cand)
            else
                table.insert(others, cand)
            end
        else
            table.insert(others, cand)
        end

        -- 增加掃描深度至 2000，確保長輸入時單字能被撈到
        if count > 2000 then break end
    end

    -- 1. 輸出最強的 2 個「全碼整句」
    for i = 1, math.min(#full_matches, 2) do
        yield(full_matches[i])
    end

    -- 2. 輸出「兩字詞」(2碼) (限制 5 個)
    for i = 1, math.min(#short_words_2, 5) do
        yield(short_words_2[i])
    end

    -- 3. 輸出「三字詞」(3碼) (限制 5 個)
    for i = 1, math.min(#short_words_3, 5) do
        yield(short_words_3[i])
    end

    -- 4. 輸出「單字」(1碼)
    -- 作為最後的逐字保底
    for _, cand in ipairs(single_chars) do
        yield(cand)
    end

    -- 5. 墊後區域
    for i = 3, #full_matches do yield(full_matches[i]) end
    for i = 6, #short_words_2 do yield(short_words_2[i]) end
    for i = 6, #short_words_3 do yield(short_words_3[i]) end
    for _, cand in ipairs(others) do yield(cand) end
end
