local libbazel = require('libbazel')

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

function M.open()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == '' then
        vim.notify('No file in current buffer', vim.log.levels.WARN)
        return
    end

    local cfg = config()
    local build_file = libbazel.find_build_file(current_file, cfg.boundary, cfg.build_files)
    if not build_file then
        vim.notify('No BUILD file found', vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.fnamemodify(current_file, ':t')
    vim.cmd.edit(build_file)

    vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local row = libbazel.parse.find_rule_line(bufnr, filename)
        if row then
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            if cfg.center_on_jump then
                vim.cmd('normal! zz')
            end
        end
    end)
end

return M
