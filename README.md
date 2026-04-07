# bazel-build-file.nvim

Navigate from a source file to the Bazel BUILD rule that references it.

Opens the nearest `BUILD.bazel` or `BUILD` file and uses treesitter to jump to the rule containing the current filename (in `srcs`, `hdrs`, etc). Falls back to matching the rule `name` against the file stem.

## Requirements

- Neovim 0.12+
- [libbazel.nvim](https://github.com/rwooster/libbazel.nvim) (brings plenary.nvim and treesitter python parser)

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

<details>
<summary>lazy.nvim spec</summary>

```lua
{
    'rwooster/bazel-build-file.nvim',
    dependencies = {
        'rwooster/libbazel.nvim',
    },
    cmd = 'BazelBuildFile',
    keys = {
        { '<leader>bb', '<cmd>BazelBuildFile<CR>', desc = 'Open Bazel BUILD file' },
    },
}
```

</details>

## Usage

Run `:BazelBuildFile` or press `<leader>bb` (if mapped as above).

## Configuration

Works out of the box with no configuration. The defaults are:

Defaults

```lua
{
    build_files = { 'BUILD.bazel', 'BUILD' }, -- filenames to search for, in priority order
    boundary = 'git',                         -- 'git' | 'workspace' | false
    center_on_jump = true,                    -- center cursor after jumping to rule
}
```

All options can be set via `vim.g` or lazy.nvim `opts`:

<details>
<summary>Configuration examples</summary>

```lua
-- Option 1: vim.g (set before plugin loads or at any time)
vim.g.bazel_build_file_nvim_config = {
    boundary = 'workspace',
}

-- Option 2: lazy.nvim opts (calls setup() automatically)
{
    'rwooster/bazel-build-file.nvim',
    dependencies = {
        'rwooster/libbazel.nvim',
    },
    opts = {
        boundary = 'workspace',
    },
}
```

</details>

### Options

| Option           | Type                           | Default                        | Description                                                                                                                                      |
| ---------------- | ------------------------------ | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `build_files`    | `string[]`                     | `{'BUILD.bazel', 'BUILD'}`     | Filenames to search for when walking up directories                                                                                              |
| `boundary`       | `'git'` \| `'workspace'` \| `false` | `'git'`                        | Where to stop searching. `'git'` stops at the git root, `'workspace'` stops at `WORKSPACE`/`MODULE.bazel`, `false` walks to filesystem root |
| `center_on_jump` | `bool`                         | `true`                         | Run `zz` after jumping to the rule                                                                                                               |
