local M = {}

--- Check if a treesitter call node's arguments contain the given filename.
local function call_references_file(node, bufnr, filename)
    local args = node:named_child(1)
    if not args then
        return false
    end
    local text = vim.treesitter.get_node_text(args, bufnr)
    return text ~= nil and text:find(filename, 1, true) ~= nil
end

--- Check if a treesitter call node has name = "stem" in its arguments.
local function call_has_name(node, bufnr, stem)
    local args = node:named_child(1)
    if not args then
        return false
    end
    for arg in args:iter_children() do
        if arg:type() == 'keyword_argument' then
            local key = arg:named_child(0)
            local val = arg:named_child(1)
            if key and val then
                local key_text = vim.treesitter.get_node_text(key, bufnr)
                local val_text = vim.treesitter.get_node_text(val, bufnr)
                if key_text == 'name' and val_text and val_text:find(stem, 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

--- Iterate top-level call expressions in a BUILD file buffer.
local function iter_top_level_calls(bufnr)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'python')
    if not ok or not parser then
        return function() end
    end
    local tree = parser:parse()[1]
    if not tree then
        return function() end
    end

    local root = tree:root()
    local child_iter = root:iter_children()
    return function()
        while true do
            local child = child_iter()
            if not child then
                return nil
            end
            local node = child
            if node:type() == 'expression_statement' then
                node = node:named_child(0)
            end
            if node and node:type() == 'call' then
                return node
            end
        end
    end
end

--- Find the line of the rule in bufnr that references filename.
--- First checks if the filename appears in any rule's arguments (srcs, hdrs, etc).
--- Falls back to matching the file stem against name = "..." arguments.
--- Returns 0-indexed line number, or nil.
function M.find_rule_line(bufnr, filename)
    for node in iter_top_level_calls(bufnr) do
        if call_references_file(node, bufnr, filename) then
            return node:start()
        end
    end
    local stem = vim.fn.fnamemodify(filename, ':r')
    for node in iter_top_level_calls(bufnr) do
        if call_has_name(node, bufnr, stem) then
            return node:start()
        end
    end
    return nil
end

return M
