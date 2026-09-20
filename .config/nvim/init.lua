vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.list = true
opt.listchars = { space = "·", tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.undofile = true
opt.swapfile = false
opt.autoread = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.winborder = "rounded"
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

vim.filetype.add({ filename = { ["git-rebase-todo"] = "gitrebase" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "rust", "c", "cpp" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc", "yaml", "html", "css", "scss", "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" or not vim.bo[ev.buf].modifiable then
      return
    end
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
  end,
})

for _, lhs in ipairs({ "grr", "grn", "gra", "gri", "grt" }) do
  pcall(vim.keymap.del, "n", lhs)
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

local function python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  local venv = vim.fs.find(".venv", { upward = true, path = vim.fn.getcwd(), type = "directory" })[1]
  if venv then
    return venv .. "/bin/python"
  end
  return vim.fn.exepath("python3")
end

require("lazy").setup({
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    config = function()
      require("dracula").setup({ italic_comment = true })
      vim.cmd.colorscheme("dracula")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "cmake", "cpp", "css", "diff", "dockerfile", "git_config",
          "git_rebase", "gitcommit", "gitignore", "html", "javascript", "json",
          "jsonc", "lua", "make", "markdown", "markdown_inline", "python",
          "regex", "rust", "sql", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["a/"] = "@comment.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>a"] = "@parameter.inner" },
            swap_previous = { ["<leader>A"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 4, multiline_threshold = 1, trim_scope = "outer" },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "ff", "<cmd>Telescope find_files<cr>" },
      { "fg", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>" },
      { "fs", "<cmd>Telescope lsp_document_symbols<cr>" },
      { "ft", "<cmd>Telescope treesitter<cr>" },
      { "fb", "<cmd>Telescope buffers<cr>" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
      { "<leader>fr", "<cmd>Telescope resume<cr>" },
      { "<c-p>", "<cmd>Telescope find_files<cr>" },
    },
    opts = {
      defaults = {
        layout_strategy = "flex",
        path_display = { "truncate" },
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case", "--hidden",
          "--glob", "!**/.git/*",
        },
      },
      pickers = {
        find_files = { hidden = true, find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } },
        lsp_references = { initial_mode = "normal", include_declaration = false },
        lsp_definitions = { initial_mode = "normal" },
        lsp_implementations = { initial_mode = "normal" },
        lsp_type_definitions = { initial_mode = "normal" },
        diagnostics = { initial_mode = "normal" },
        lsp_document_symbols = { initial_mode = "normal" },
        treesitter = { initial_mode = "normal" },
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>" },
      { "<leader>o", "<cmd>NvimTreeFindFile<cr>" },
    },
    opts = {
      view = { width = 36 },
      renderer = { group_empty = true },
      filters = { dotfiles = false, custom = { "^.git$" } },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = { ui = { border = "rounded" } },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "saghen/blink.cmp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "basedpyright", "ruff", "clangd", "ts_ls", "eslint",
          "biome", "taplo", "tailwindcss", "bashls", "jsonls", "yamlls",
          "marksman", "neocmake", "dockerls",
        },
        automatic_enable = { exclude = { "rust_analyzer" } },
      })

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities({}, true),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = { diagnosticMode = "openFilesOnly", typeCheckingMode = "standard" },
          },
        },
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = { pythonPath = python_path() }
        end,
      })

      vim.lsp.config("tailwindcss", {
        filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact", "javascript", "typescript", "vue", "svelte" },
      })

      vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", "rust-project.json" },
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
            inlayHints = { chainingHints = { enable = true } },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(lhs, rhs, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, silent = true })
          end
          map("gr", "<cmd>Telescope lsp_references<cr>")
          map("gd", "<cmd>Telescope lsp_definitions<cr>")
          map("gy", "<cmd>Telescope lsp_type_definitions<cr>")
          map("<leader>gi", "<cmd>Telescope lsp_implementations<cr>")
          map("gD", vim.lsp.buf.declaration)
          map("K", vim.lsp.buf.hover)
          map("<leader>rn", vim.lsp.buf.rename)
          map("<leader>ca", vim.lsp.buf.code_action, { "n", "x" })
          map("<leader>k", vim.lsp.buf.signature_help)
          map("<leader>d", vim.diagnostic.open_float)
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end)
          end
        end,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 150 },
        ghost_text = { enabled = true },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = { { "<leader>F", function() require("conform").format({ async = true }) end, mode = { "n", "x" } } },
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        toml = { "taplo" },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
        javascript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        css = { "biome", "prettier", stop_after_first = true },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        markdown = { "markdownlint" },
        dockerfile = { "hadolint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
      current_line_blame_formatter = "      <author>, <author_time:%Y-%m-%d> · <summary>",
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(lhs, rhs)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("]h", function() gs.nav_hunk("next") end)
        map("[h", function() gs.nav_hunk("prev") end)
        map("<leader>hp", gs.preview_hunk)
        map("<leader>hb", function() gs.blame_line({ full = true }) end)
        map("<leader>hr", gs.reset_hunk)
        map("<leader>hd", gs.diffthis)
        map("<leader>tb", gs.toggle_current_line_blame)
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "G", "GBrowse" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>" },
      { "<leader>gb", "<cmd>GBrowse<cr>", mode = { "n", "x" } },
    },
  },

  {
    "cameron-wags/rainbow_csv.nvim",
    ft = { "csv", "tsv", "csv_semicolon", "csv_pipe" },
    cmd = { "RainbowDelim", "RainbowAlign" },
    config = true,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "dracula-nvim", globalstatus = true, section_separators = "", component_separators = "|" },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "BufReadPost",
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>" },
      { "<leader>b.", "<cmd>BufferLineMoveNext<cr>" },
      { "<leader>b,", "<cmd>BufferLineMovePrev<cr>" },
    },
    opts = { options = { diagnostics = "nvim_lsp", separator_style = "thin", show_buffer_close_icons = false } },
  },

  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    keys = {
      { "<leader>q", "<cmd>Bdelete<cr>" },
      { "<leader>Q", "<cmd>Bdelete!<cr>" },
    },
  },

  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "numToStr/Comment.nvim", event = "VeryLazy", config = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "BufReadPost", opts = { scope = { enabled = true } } },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "RRethy/vim-illuminate", event = "BufReadPost" },
}, {
  install = { colorscheme = { "dracula" } },
  change_detection = { notify = false },
})

local map = vim.keymap.set
map("n", "<esc>", "<cmd>nohlsearch<cr>", { silent = true })
map("n", "<leader>w", "<cmd>write<cr>", { silent = true })
map("n", "<s-h>", "<cmd>bprevious<cr>", { silent = true })
map("n", "<s-l>", "<cmd>bnext<cr>", { silent = true })
map("n", "<leader><leader>", "<c-^>")
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", { silent = true })
end
map("n", "<c-h>", "<c-w>h")
map("n", "<c-j>", "<c-w>j")
map("n", "<c-k>", "<c-w>k")
map("n", "<c-l>", "<c-w>l")
map("n", "<leader>\\", "<cmd>vsplit<cr>")
map("n", "<leader>-", "<cmd>split<cr>")
map("t", "<esc><esc>", "<c-\\><c-n>")
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "J", ":m '>+1<cr>gv=gv", { silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { silent = true })
map("n", "<leader>`", "<cmd>botright split | resize 15 | terminal<cr>", { silent = true })

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {})
