local ui = {}
local block = {}

function block.new(char)
    local _block = {
        "╭───╮",
        "│ * │",
        "╰───╯",
    }
    _block[2] = _block[2]:gsub("%*", char)
    return _block
end

function block.print(box)
    for _, line in ipairs(box) do
        print(line)
    end
end

function block.chain(blocks)
    local chained = {}
    for _, _block in ipairs(blocks) do
        for idx = 1,3 do
            chained[idx] = (chained[idx] or "").." ".._block[idx].." "
        end
    end
    return chained
end

function block.from_word(word)
    local letters = vim.split(word, "")
    local blocks = {}
    for idx, letter in ipairs(letters) do
        blocks[idx] = block.new(letter)
    end
    blocks = block.chain(blocks)
    return blocks
end

function block.from_letters(letters)
    local blocks = {}
    for idx, letter in ipairs(letters) do
        blocks[idx] = block.new(letter)
    end
    blocks= block.chain(blocks)
    return blocks
end

function block.from_table_letters(tbl)
    local lines = {}
    for idx, letters in ipairs(tbl) do
        lines[idx] = block.from_letters(letters)
    end
    return lines
end

local function position(buffer, line, index)
    local str = vim.api.nvim_buf_get_lines(buffer, line, line+1, true)[1]
    return vim.fn.byteidx(str, index)
end

local highlight = {}

function highlight.register()
    vim.cmd("hi WordleFgUnused guifg=#3a3a3c")
    vim.cmd("hi WordleFgMisplaced guifg=#b6a22f")
    vim.cmd("hi WordleFgCorrect guifg=#39944e")
end

function highlight.border(namespace, buffer, top_line, block, status)
    local group
    if status == 0 then
        group = "WordleFgUnused"
    elseif status == 1 then
        group = "WordleFgMisplaced"
    elseif status == 2 then
        group = "WordleFgCorrect"
    else
        return
    end
    local end_dist = 7*block - 1
    local start_dist = end_dist - 5

    local dist_top_l = position(buffer, top_line, start_dist)
    local dist_top_r = position(buffer, top_line, end_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line, dist_top_l, dist_top_r)
    local dist_mid_l1 = position(buffer, top_line + 1, start_dist)
    local dist_mid_l2 = position(buffer, top_line + 1, start_dist + 1)
    local dist_mid_r1 = position(buffer, top_line + 1, end_dist - 1)
    local dist_mid_r2 = position(buffer, top_line + 1, end_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, dist_mid_l1, dist_mid_l2)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, dist_mid_r1, dist_mid_r2)
    local dist_end_l = position(buffer, top_line + 2, start_dist)
    local dist_end_r = position(buffer, top_line + 2, end_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 2, dist_end_l, dist_end_r)
end

function highlight.char(namespace, buffer, top_line, block, status)
    local group
    if status == 0 then
        group = "WordleFgUnused"
    elseif status == 1 then
        group = "WordleFgMisplaced"
    elseif status == 2 then
        group = "WordleFgCorrect"
    else
        return
    end
    local dist = 7*block - 4
    dist = position(buffer, top_line + 1, dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, dist, dist+1)
end

function highlight.block(namespace, buffer, top_line, block, status)
    highlight.border(namespace, buffer, top_line, block, status)
    highlight.char(namespace, buffer, top_line, block, status)
end

ui.block = block
ui.highlight = highlight

return ui
