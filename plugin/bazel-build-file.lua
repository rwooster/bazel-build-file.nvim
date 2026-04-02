if vim.g.loaded_bazel_build_file then
    return
end
vim.g.loaded_bazel_build_file = true

vim.api.nvim_create_user_command('BazelBuildFile', function()
    require('bazel-build-file').open()
end, { desc = 'Navigate to the BUILD rule for the current file' })
