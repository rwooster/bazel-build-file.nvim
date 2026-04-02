local Path = require('plenary.path')
local treesitter = require('bazel-build-file.treesitter')

local M = {}

local defaults = {
    build_files = { 'BUILD.bazel', 'BUILD' },
    boundary = 'git',
    center_on_jump = true,
}

function M.setup(opts)
    vim.g.bazel_build_file_nvim_config = vim.tbl_deep_extend(
        'force',
        vim.g.bazel_build_file_nvim_config or {},
        opts or {}
    )
end

local function config()
    return vim.tbl_deep_extend('force', defaults, vim.g.bazel_build_file_nvim_config or {})
end

--- Find the search boundary directory based on config.
local function find_boundary(start_path)
    local cfg = config()
    if cfg.boundary == 'git' then
        local git_dir = Path:new(start_path):find_upwards('.git')
        if git_dir then
            return git_dir:parent():absolute()
        end
    elseif cfg.boundary == 'workspace' then
        for _, name in ipairs({ 'WORKSPACE', 'WORKSPACE.bazel', 'MODULE.bazel' }) do
            local ws = Path:new(start_path):find_upwards(name)
            if ws then
                return ws:parent():absolute()
            end
        end
    end
    return nil
end

--- Walk up from start_path looking for a BUILD file, stopping at boundary.
local function find_build_file(start_path, boundary)
    local cfg = config()
    local dir = Path:new(start_path):parent()
    while true do
        local dir_abs = dir:absolute()
        for _, name in ipairs(cfg.build_files) do
            local candidate = dir:joinpath(name)
            if candidate:exists() then
                return candidate:absolute()
            end
        end
        if dir_abs == boundary or dir_abs == '/' then
            break
        end
        dir = dir:parent()
    end
    return nil
end

function M.open()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == '' then
        vim.notify('No file in current buffer', vim.log.levels.WARN)
        return
    end

    local boundary = find_boundary(current_file)
    local build_file = find_build_file(current_file, boundary)
    if not build_file then
        vim.notify('No BUILD file found', vim.log.levels.WARN)
        return
    end

    local cfg = config()
    local filename = vim.fn.fnamemodify(current_file, ':t')
    vim.cmd.edit(build_file)

    vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local row = treesitter.find_rule_line(bufnr, filename)
        if row then
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            if cfg.center_on_jump then
                vim.cmd('normal! zz')
            end
        end
    end)
end

return M
